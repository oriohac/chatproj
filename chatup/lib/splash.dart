import 'package:chatup/Core/services/auth_service.dart';
import 'package:chatup/features/authentication/interface/login.dart';
import 'package:chatup/features/chat/interface/chat_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Future.delayed(Duration(seconds: 2)),
        builder:
            (context, timer) =>
                timer.connectionState == ConnectionState.done
                    ? FutureBuilder(
                      future: AuthService.getToken(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return snapshot.hasData ? ChatHome() : Login();
                        }
                        return CircularProgressIndicator();
                      },
                    )
                    : Container(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Animate(
                              effects: [FadeEffect()],
                              child: SvgPicture.asset(
                                'assets/user.svg',
                                width: 50,
                                height: 50,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "ChatUP",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
      ),
    );
  }
}
