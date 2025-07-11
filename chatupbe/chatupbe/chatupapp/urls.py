from django.urls import path 
from .views import home, signup,  messages, login, test_db_write, user_list, userDetail


urlpatterns = [
    path('', home, name='home'),
    path("api/messages/<str:room_name>/", messages, name="messages"),
    path('signup/',signup,name='signup'),
    path('login/',login,name='login'),
    path('users/<int:id>',userDetail,name='users'),
    path('users/list',user_list,name='user_list'),
    path('test_db_write/', test_db_write, name='test_db_write'),
]
