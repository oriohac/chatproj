import json
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
        sender = data.get("sender")
        # sender = self.user.email if self.user.is_authenticated else "Anonymous"

        # Store the message in the database
        if self.user.is_authenticated:
            await self.save_message(self.user, message)
            
        # Send message to WebSocket group
        await self.channel_layer.group_send(
            self.room_group_name, {"type": "chat_message", "message": message, "sender":sender}
        )

    async def chat_message(self, event):
        # await self.send(text_data=event["message"])  
        await self.send(text_data=json.dumps({
            "message": event["message"],
            "sender": event["sender"]
        }))
    
    async def save_message(self, user, message):
        """ Save message to database """
        await Messages.objects.acreate(sender=user, message=message, room_name=self.room_name)