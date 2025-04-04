"""
ASGI config for chatupbe project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/5.1/howto/deployment/asgi/
"""

import os
from django.core.asgi import get_asgi_application
from channels.routing import get_default_application, ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack
from chatupapp.routing import  application as chat_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'chatupbe.settings')
django_asgi_app = get_asgi_application()
# application = get_asgi_application()
application = ProtocolTypeRouter({
    "http": get_asgi_application(),
    "websocket": AuthMiddlewareStack(
       
            chat_application
       
    )
})
