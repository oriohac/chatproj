from django.db import models
from django.contrib.auth.models import AbstractUser, User
# Create your models here.

class User(AbstractUser):
    # first_name = models.CharField(max_length=50)
    # last_name = models.CharField(max_length=50)
    email = models.EmailField(max_length=254, unique=True)
    # password = models.CharField(max_length=100)
    created_at = models.DateTimeField(auto_now_add=True,  null=True)
    
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['id','first_name','last_name','password']
    def __str__(self):
        return self.last_name
    class Meta:
        db_table = 'auth_user'
        
class Messages(models.Model):
    sender = models.ForeignKey(User,on_delete=models.CASCADE, related_name='messages')
    message = models.TextField()
    time = models.DateTimeField(auto_now_add=True, null=True)
    room_name = models.CharField(max_length=200, null=True)

