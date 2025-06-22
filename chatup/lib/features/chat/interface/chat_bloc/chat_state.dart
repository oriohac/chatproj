part of 'chat_bloc.dart';

@immutable
sealed class ChatState {}

final class ChatInitial extends ChatState {}

final class ChatLoading extends ChatState {}

final class ChatLoaded extends ChatState {
  final List<Map<String, dynamic>> messages;

  ChatLoaded({ required this.messages});
}

final class ChatError extends ChatState {
   final String error;

   ChatError({required this.error});

  @override
  List<Object> get props => [error];
}
