from rest_framework import serializers
from django.contrib.auth import authenticate
from .models import Messages, User
class MessageSerializer(serializers.ModelSerializer):
    sender = serializers.CharField(source='sender.email',read_only = True)
    time = serializers.DateTimeField(format='iso-8601')
    class Meta:
        model = Messages
        fields = ['id','message','time','room_name','sender']
        
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        # fields = '__all__'
        fields = ['id','email', 'first_name', 'last_name', 'password']
        extra_kwargs = {
            'password': {'write_only': True}
        }
        
    def create(self, validated_data):
        user = User.objects.create_user(
            email = validated_data['email'],
            first_name = validated_data['first_name'],
            last_name = validated_data['last_name'],
            password = validated_data['password'],
            username=validated_data['email'] 
        )
        return user
class LoginSerializer(serializers.Serializer):
    email = serializers.CharField()
    password = serializers.CharField()
    def validate(self, attrs):
        user = authenticate(email=attrs['email'],password=attrs['password'])
        if user and user.is_active:
            return user
        raise serializers.ValidationError("Invalid credentials.")
