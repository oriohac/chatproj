import 'package:equatable/equatable.dart';

class Pages extends Equatable {
  const Pages._();
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const chathome = '/chathome';
  static const chat = '/chat';

  @override
  List<Object?> get props => [splash, login, signup, chathome, chat];
}
