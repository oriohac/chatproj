part of 'chat_home_bloc.dart';

class ChatHomeState extends Equatable {
  const ChatHomeState();
  @override
  List<Object?> get props => [];
}

class ChatHomeInitial extends ChatHomeState {}

class ChatHomeSuccess extends ChatHomeState {
  final List<Userdetails> users;
  const ChatHomeSuccess({
    required this.users
  });
  @override
  List<Object?> get props => [users];
}

class ChatHomeError extends ChatHomeState {}
