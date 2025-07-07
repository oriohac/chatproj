import 'package:chatup/features/chat/interface/chat_bloc/chat_bloc.dart';
import 'package:chatup/features/chat/interface/chat_home_bloc/chat_home_bloc.dart';
import 'package:chatup/firebase_options.dart';
import 'package:chatup/local_notification.dart';
import 'package:chatup/navigation/router.dart';
import 'package:chatup/noti_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main()  async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  LocalNotificationService.initialize();
  NotiService().initNotification();

  runApp(const ChatUp());
}

Future backgroundHandler(RemoteMessage msg) async {}

class ChatUp extends StatefulWidget {
  const ChatUp({super.key});

  @override
  State<ChatUp> createState() => _ChatUpState();
}

class _ChatUpState extends State<ChatUp> {
  // Update the backgroundHandler function
  Future<void> backgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    LocalNotificationService.initialize();

    // Show notification when app is in background
    if (message.notification != null) {
      LocalNotificationService.display(message);
    }

    // You can add additional logic here to handle the notification data
    // For example, you might want to save the message to local storage
  }

  @override
  void initState() {
    super.initState();
    // NotiService().initNotification();
  //   LocalNotificationService.initialize();

    // To initialise the sg
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationNavigation(message);
      }
    });

    // To initialise when app is not terminated
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        LocalNotificationService.display(message);
      }
    });

    // To handle when app is open in
    // user divide and heshe is using it
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationNavigation(message);
    });
  }

  void _handleNotificationNavigation(RemoteMessage message) {
    final roomName = message.data['roomName'];
    final sender = message.data['sender'];

    // Navigate to the chat screen if needed
    // You'll need to implement this based on your routing
    if (roomName != null && sender != null) {
      // Example: context.go('/chat/$roomName');
    }
  }

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
