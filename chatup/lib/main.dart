import 'package:chatup/features/chat/interface/chat_bloc/chat_bloc.dart';
import 'package:chatup/features/chat/interface/chat_home_bloc/chat_home_bloc.dart';
import 'package:chatup/navigation/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const ChatUp());
}

class ChatUp extends StatelessWidget {
  const ChatUp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ChatHomeBloc()),
        BlocProvider(create: (context) => ChatBloc()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        darkTheme: ThemeData(colorScheme: ColorScheme.dark()),
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
