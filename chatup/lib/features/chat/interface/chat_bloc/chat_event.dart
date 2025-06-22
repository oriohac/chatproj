part of 'chat_bloc.dart';

@immutable
sealed class ChatEvent {}

class ChatMessageReceived extends ChatEvent {
  final String id;
  final String sender;
  final String message;
  final String time;
  ChatMessageReceived({
    required this.id,
    required this.sender,
    required this.message,
    required this.time,
  });
}

class ChatMessageSent extends ChatEvent {
  final String sender;
  final String message;
  ChatMessageSent({required this.sender, required this.message});
}

class ChatStarted extends ChatEvent {
  final WebSocketChannel channel;
  final String currentUserEmail;
  final String roomName;
  ChatStarted({
    required this.channel,
    required this.currentUserEmail,
    required this.roomName,
  });
}

class ChatLoadHistory extends ChatEvent {
  final String roomName;

  ChatLoadHistory({required this.roomName});
}

class ChatErrorOccurred extends ChatEvent {
  final String error;
  ChatErrorOccurred({required this.error});
}

class ChatDisconnected extends ChatEvent {}
