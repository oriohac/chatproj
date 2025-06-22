import uuid
from django.db import models
from django.contrib.auth.models import AbstractUser
# Create your models here.

from django.contrib.auth.base_user import BaseUserManager

class CustomUserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError("The Email field must be set")
        email = self.normalize_email(email)
        extra_fields.setdefault("username", email)  # required for AbstractUser compatibility
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        extra_fields.setdefault("is_active", True)
        extra_fields.setdefault("username", email)  # required for AbstractUser compatibility

        if extra_fields.get("is_staff") is not True:
            raise ValueError("Superuser must have is_staff=True.")
        if extra_fields.get("is_superuser") is not True:
            raise ValueError("Superuser must have is_superuser=True.")

        return self.create_user(email, password, **extra_fields)


class User(AbstractUser):
    email = models.EmailField(max_length=254, unique=True)
    created_at = models.DateTimeField(auto_now_add=True,  null=True)
    
    
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['first_name','last_name']
    objects = CustomUserManager()
    def __str__(self):
        return self.email
    class Meta:
        db_table = 'auth_user'
        
class Messages(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    sender = models.ForeignKey(User,on_delete=models.CASCADE, related_name='messages')
    message = models.TextField()
    time = models.DateTimeField(auto_now_add=True, null=True)
    room_name = models.CharField(max_length=200, null=True)
    read = models.BooleanField(default=False)
    
    
    class Meta:
        ordering = ['time']
        indexes = [
            models.Index(fields=['room_name']),
            models.Index(fields=['sender']),
        ]
        
    def __str__(self):
        return f"{self.sender.email} in {self.room_name}: {self.message[:20]}"