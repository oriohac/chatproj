import 'package:chatup/features/authentication/interface/login.dart';
import 'package:chatup/features/authentication/interface/signup.dart';
import 'package:chatup/features/chat/interface/chat.dart';
import 'package:chatup/features/chat/interface/chat_home.dart';
import 'package:chatup/navigation/pages.dart';
import 'package:chatup/splash.dart';
import 'package:go_router/go_router.dart';

GoRouter appRouter = GoRouter(
  initialLocation: Pages.splash,
  routes: [
    GoRoute(
      path: Pages.splash,
      name: Pages.splash,
      builder: (context, state) {
        return Splash();
      },
    ),
    GoRoute(
      path: Pages.login,
      name: Pages.login,
      builder: (context, state) {
        return Login();
      },
    ),
    GoRoute(
      path: Pages.signup,
      name: Pages.signup,
      builder: (context, state) {
        return Signup();
      },
    ),
    GoRoute(
      path: Pages.chathome,
      name: Pages.chathome,
      builder: (context, state) {
        return ChatHome();
      },
    ),
    GoRoute(
      path: Pages.chat,
      name: Pages.chat,
      builder: (context, state) {
        final user = state.extra as Userdetails;
        return Chat(user: user,);
      },
    ),
  ],
);
