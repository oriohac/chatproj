from datetime import datetime
import json
import uuid
from channels.generic.websocket import WebsocketConsumer, AsyncWebsocketConsumer
from django.contrib.auth import get_user_model
from .models import Messages

User = get_user_model()

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.user = self.scope["user"] 
        self.room_name = self.scope["url_route"]["kwargs"]["room_name"]
        self.room_group_name = f"chat_{self.room_name}"

        # Join the WebSocket group
        await self.channel_layer.group_add(self.room_group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        # Leave the WebSocket group
        await self.channel_layer.group_discard(self.room_group_name, self.channel_name)

    async def receive(self, text_data):
        data = json.loads(text_data)
        message = data.get("message")
        sender_email = data.get("sender")

        # Store the message in the database
        if self.user.is_authenticated:
            try:
                message_obj = await self.save_message(self.user, message)
                timestamp = message_obj.time.isoformat()
                message_id = str(message_obj.id)
                
                await self.channel_layer.group_send(
                     self.room_group_name, 
                     {
                         "type": "chat_message", 
                         "id": message_id, 
                         "message": message, 
                         "sender": sender_email,  
                         "sender_id": str(self.user.id),  # Also include ID if needed
                         "time": timestamp
                     }
                 )
            except Exception as e:
                await self.close()
                return
        else:
            timestamp = datetime.now().isoformat()
            message_id = str(uuid.uuid4())
            
        # Send message to WebSocket group
        await self.channel_layer.group_send(
            self.room_group_name, {"type": "chat_message", "id": message_id, "message": message, "sender":sender_email, "time":timestamp}
        )

    async def chat_message(self, event): 
        await self.send(text_data=json.dumps({
            "id": event["id"],
            "message": event["message"],
            "sender": event["sender"],
            "time": event["time"]
        }))
    
    async def save_message(self, user, message):
        """ Save message to database """
        message_obj = await Messages.objects.acreate(
            sender=user,
            message=message,
            room_name=self.room_name)
        return message_obj 