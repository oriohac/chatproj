import 'package:chatup/navigation/router.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ChatUp());
}

class ChatUp extends StatelessWidget {
  const ChatUp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(colorScheme: ColorScheme.dark()),
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routerConfig: appRouter,
      
    );
  }
}

