import 'package:chatup/noti_service.dart';
import 'package:flutter/material.dart';

class Shownotification extends StatelessWidget {
  const Shownotification({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            NotiService().showNotification();
          },
          child: Text("Show Notification"),
        ),
      ),
    );
  }
}
