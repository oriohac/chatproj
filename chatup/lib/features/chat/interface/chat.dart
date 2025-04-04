import 'dart:convert';

import 'package:chatup/features/chat/interface/chat_home.dart';
import 'package:chatup/features/chat/interface/widget/chat_bubble.dart';
import 'package:chatup/navigation/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// import 'chat_home.dart';

class Chat extends StatefulWidget {
  final Userdetails user;
  const Chat({super.key, required this.user});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController messageTextController = TextEditingController();
  final DateTime timeSent = DateTime.now();
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('ws://10.0.2.2:8000/ws/chat/room1/'),
  );

  List<Map<String, String>> messages = [];
  // late Future<Userdetails> userdetails;
  String formatTimeStamp(DateTime timestamp) {
    return DateFormat('MMM-d-yy hh:mm a').format(timestamp);
  }

  @override
  void initState() {
    super.initState();
    // userdetails = getUser();
    channel.stream.listen(
      (event) {
        final data = jsonDecode(event);
        print("WebSocket Message Received: $event");
        setState(() {
          messages.add({"sender": data["sender"], "message": data["message"]});
        });
      },
      onError: (error) {
        print("WebSocket Error: $error");
      },
    );
  }

  @override
  void dispose() {
    channel.sink.close();
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
                  context.push(Pages.chathome);
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            return Align(
              alignment:
                  message["sender"] == widget.user.email
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
              child: ChatBubble(
                isSender: message["sender"] == widget.user.email,
                message: message["message"]!,
                sent: true,
                time: Text(
                  formatTimeStamp(timeSent),
                  style: TextStyle(fontSize: 12),
                ),
              ),
            );
          },
        ),
      ),

      // Stack(
      //   children: [
      //     Positioned(
      //       right: 5,
      //       child: StreamBuilder(
      //         stream: channel.stream,
      //         builder: (context, snapshot) {
      //           return ChatBubble(
      //             isSender: true,
      //             message: Container(
      //               width: 260,
      //               child: Text(
      //                 snapshot.hasData ? '${snapshot.data}' : '',
      //                 maxLines: 20,
      //               ),
      //             ),
      //             sent: true,
      //             time: DateTime.now(),
      //           );
      //         },
      //       ),
      //     ),
      //   ],
      // ),
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
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                          borderRadius: BorderRadius.circular(12),
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

  void sendMessage() {
    if (messageTextController.text.isNotEmpty) {
      final message = jsonEncode({
        'message': messageTextController.text.trim(),
        'sender': widget.user.email,
      });
      channel.sink.add(message);
      messageTextController.clear();
    }
  }
}
