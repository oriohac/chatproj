import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final bool isSender;
  final String message;
  final bool sent;
  final bool delivered =false ;
  final bool read = false;
  final Widget time; 
  const ChatBubble({
    super.key,
    required this.isSender,
    required this.message,
    required this.sent,
    required this.time,
    });
    

  @override
  Widget build(BuildContext context,) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75, // Limit max width
        ),
        decoration: BoxDecoration(
          color: isSender ? Colors.blue : Colors.green,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: isSender ? Radius.circular(16) : Radius.zero,
            bottomRight: isSender ? Radius.zero : Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                time,
                SizedBox(width: 4),
                sent ? Icon(Icons.check, size: 14, color: Colors.white) : 
                       Icon(Icons.timer, size: 14, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
    // Padding(
    //   padding: const EdgeInsets.only(top: 6, left: 16),
    //   child: Container(
    //     padding: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
    //     decoration: BoxDecoration(color: isSender ? Colors.blue : Colors.green, borderRadius: isSender ? BorderRadius.only(topLeft: Radius.circular(16),topRight: Radius.circular(16),bottomLeft: Radius.circular(16)) : BorderRadius.only(topLeft: Radius.circular(16),topRight: Radius.circular(16),bottomRight: Radius.circular(16)) ),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       mainAxisSize: MainAxisSize.min,
    //       children: [
    //         message,
    //         SizedBox(height: 2,),
    //         Row(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             time,
    //             SizedBox(width: 2,),
    //             sent 
    //             ? Icon(Icons.check) 
    //             : Icon(Icons.timer),
    //           ],
    //         )
    //       ],
    //     ),
    //   ),
    // );
  }
} 