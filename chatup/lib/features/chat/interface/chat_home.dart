import 'package:chatup/Core/models/user_details.dart';
import 'package:chatup/Core/services/auth_service.dart';
import 'package:chatup/features/chat/interface/chat_home_bloc/chat_home_bloc.dart';
import 'package:chatup/navigation/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  @override
  State<ChatHome> createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  late Future<Userdetails> userdetails;
  late Future<List<Userdetails>> users;

  @override
  void initState() {
    super.initState();
    context.read<ChatHomeBloc>().add(GetUsers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: MediaQuery.of(context).size.width,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              SizedBox(width: 8),
              Text(
                "Chats",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        title: Text(
          "Chats",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              AuthService.logout();
              context.push(Pages.login);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(),
              ),
              child: Text("Logout"),
            ),
          ),
        ],
        actionsPadding: EdgeInsets.only(right: 16),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: BlocBuilder<ChatHomeBloc, ChatHomeState>(
          builder: (context, state) {
            if (state is ChatHomeInitial) {
              return Center(child: Text("Loading..."));
            } else if (state is ChatHomeSuccess) {
              final users = state.users;
              if (users.isEmpty) {
                return Center(child: Text("No User here"));
              }
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        context.push(Pages.chat, extra: user);
                      },
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(),
                        ),
                        child: ListTile(
                          leading: SvgPicture.asset(
                            "assets/user.svg",
                            height: 32,
                            width: 32,
                          ),
                          title: Text(
                            "${user.lastname}, ${user.firstname}",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(user.email),
                        ),
                      ),
                    ),
                  );
                },
              );
            } else if (state is ChatHomeError) {
              return Center(child: Text('Something is off somewhere'));
            }
            return SizedBox();
          },
        ),
      ),
    );
  }
}
