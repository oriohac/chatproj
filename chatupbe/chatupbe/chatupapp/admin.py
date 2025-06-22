from django.contrib import admin
from .models import Messages, User

# Register your models here.
# admin.site.register(Messages)
admin.site.register(User)

@admin.register(Messages)
class MessagesAdmin(admin.ModelAdmin):
    list_display = ('sender', 'room_name', 'time', 'message_short')
    list_filter = ('room_name', 'sender')
    search_fields = ('message', 'sender__email')

    def message_short(self, obj):
        return obj.message[:50]
    message_short.short_description = 'Message'