import 'dart:convert';

import 'package:chatup/Core/models/user_details.dart';
import 'package:chatup/Core/services/auth_service.dart';
import 'package:chatup/features/chat/interface/chat_bloc/chat_bloc.dart';
import 'package:chatup/features/chat/interface/chat_home.dart';
import 'package:chatup/features/chat/interface/widget/chat_bubble.dart';
import 'package:chatup/navigation/pages.dart';
import 'package:chatup/noti_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Chat extends StatefulWidget {
  final Userdetails user;
  const Chat({super.key, required this.user});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController messageTextController = TextEditingController();
  final DateTime timeSent = DateTime.now();
  late WebSocketChannel channel;

  List<Map<String, String>> messages = [];
  String formatTimeStamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp).toLocal();
    return DateFormat('MMM-d-yy hh:mm a').format(dateTime);
  }

  Future<void> _initWebSocket() async {
    final currentUserEmail = await AuthService.getUserEmail();
    final token = await AuthService.getToken();
    final roomName = getChatRoomName(
      currentUserEmail.toString(),
      widget.user.email,
    );

    setState(() {
      channel = IOWebSocketChannel.connect(
        Uri.parse("ws://10.0.2.2:8000/ws/chat/$roomName/"),
        headers: {'Authorization': 'Token $token'},
      );
    });

    final chatBloc = context.read<ChatBloc>();
    chatBloc.add(
      ChatStarted(
        channel: channel,
        currentUserEmail: currentUserEmail.toString(),
        roomName: roomName,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _initWebSocket();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
              GestureDetector(
                onTap: () {
                  context.pop(Pages.chathome);
                },
                child: Icon(Icons.arrow_back_ios),
              ),
              SizedBox(width: 8),
              SvgPicture.asset("assets/user.svg", width: 40, height: 40),
              SizedBox(width: 12),
              Text(
                "${widget.user.firstname}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        child: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            if (state is ChatLoaded) {
              final messages = state.messages;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: Duration(microseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });
              return ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(0, 0, 0, 80),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isSent =
                      message["sender"] ==
                      context.read<ChatBloc>().currentUserEmail;

                  return Align(
                    alignment:
                        isSent ? Alignment.centerRight : Alignment.centerLeft,
                    child: ChatBubble(
                      isSender: isSent,
                      message: message["message"]!,
                      sent:
                          isSent
                              ? Icon(Icons.check, size: 14, color: Colors.white)
                              : SizedBox.shrink(),
                      time: Text(
                        formatTimeStamp(
                          message["time"] ?? DateTime.now().toIso8601String(),
                        ),
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),

      bottomSheet: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Form(
                    child: TextFormField(
                      decoration: InputDecoration(
                        hintText: "Send message...",
                        prefixIcon: Transform.rotate(
                          angle: 1.6,
                          child: IconButton(
                            onPressed: () {
                              bottomSheetShow();
                            },
                            icon: Icon(Icons.attachment),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      controller: messageTextController,
                      maxLines: 4,
                      minLines: 1,
                    ),
                  ),
                ),
                SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    sendMessage();
                  },
                  child: Icon(Icons.send, color: Colors.blue, size: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage() async {
    final message = messageTextController.text.trim();
    final currentUserEmail = await AuthService.getUserEmail();
    if (message.isNotEmpty) {
      context.read<ChatBloc>().add(
        ChatMessageSent(sender: currentUserEmail.toString(), message: message),
      );
      messageTextController.clear();
    }
  }

  void bottomSheetShow() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(12.0),
          height: 160,
          child: Column(
            children: [
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(Icons.image, size: 22),
                    SizedBox(width: 12),
                    Text("Image", style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
              SizedBox(height: 12),
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(Icons.video_call, size: 22),
                    SizedBox(width: 12),
                    Text("Video", style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
              SizedBox(height: 12),
              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(Icons.attachment, size: 22),
                    SizedBox(width: 12),
                    Text("Document", style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      showDragHandle: true,
      isScrollControlled: true,
    );
  }

  String getChatRoomName(String email1, String email2) {
    final emails = [email1, email2]..sort();
    return 'chat_${emails[0]}_${emails[1]}'
        .replaceAll('@', '_at_')
        .replaceAll('.', '_dot_');
  }
}
