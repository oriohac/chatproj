from django.shortcuts import render
from django.contrib.auth.models import User, auth
from django.contrib.auth import authenticate, get_user_model
from .serializer import LoginSerializer, MessageSerializer, UserSerializer
from .models import Messages, User


from rest_framework.generics import ListAPIView
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import serializers,status, permissions
from rest_framework.authtoken.models import Token
from django.views.decorators.csrf import csrf_exempt

User = get_user_model()
# Create your views here.
def home(request):
    return render(request, 'index.html')

@api_view(['GET'])
def messages(request, room_name):
    messages = Messages.objects.filter(room_name=room_name).order_by("-timestamp")
    serializer = MessageSerializer(messages, many=True)
    return Response(serializer.data)
    
@csrf_exempt   
@api_view(['POST'])
def signup(request):
    serializer = UserSerializer(data=request.data)
    if serializer.is_valid():
        user = serializer.save()
        token, created = Token.objects.get_or_create(user=user)
        return Response({'token':token.key, 'success':'User created successfully'},status=status.HTTP_201_CREATED)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
def login(request):
    serializer = LoginSerializer(data=request.data)
    if serializer.is_valid():
        # user = authenticate(username=serializer.validated_data['username'], password=serializer.validated_data['password'])
        user = serializer.validated_data
        if user:
            token, created = Token.objects.get_or_create(user=user)
            return Response({'token': token.key, 'success': 'Login Successful','id':user.id,'email':user.email}, status=status.HTTP_200_OK)
        else:
            return Response({'Message': 'Invalid Username or Password'}, status=status.HTTP_400_BAD_REQUEST)
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout(request):
    request.user.auth_token.delete()
    return Response(status=status.HTTP_204_NO_CONTENT)

@api_view(['GET'])
def userDetail(request,id):
    queryset = User.objects.get(id=id)
    serializer = UserSerializer(queryset)
    return Response(serializer.data)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_list(request):
    users = User.objects.exclude(id=request.user.id)  # Exclude the logged-in user
    serializer = UserSerializer(users, many=True)
    return Response(serializer.data)