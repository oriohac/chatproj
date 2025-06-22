import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:chatup/Core/services/apiservice.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  late WebSocketChannel _channel;
  late String currentUserEmail;
  late String _roomName;
  static const String _messagesKey = 'chat_messages';

  Future<void> _saveMessages(List<Map<String, dynamic>> messages) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('chat_$_roomName', json.encode(messages));
  }

  Future<List<Map<String, dynamic>>> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getString('chat_$_roomName');
    if (messagesJson != null) {
      final List<dynamic> messages = json.decode(messagesJson);
      return messages.cast<Map<String, dynamic>>();
    }
    return [];
  }

  List<Map<String, dynamic>> _mergeMessages(
    List<Map<String, dynamic>> local,
    List<Map<String, dynamic>> server,
  ) {
    // Create a map of local messages by ID for O(1) lookups
    final localMessagesById = {for (final msg in local) msg['id']: msg};

    // Start with all local messages
    final merged = List<Map<String, dynamic>>.from(local);

    // Add server messages that don't exist locally
    for (final serverMsg in server) {
      if (!localMessagesById.containsKey(serverMsg['id'])) {
        merged.add(serverMsg);
      }
    }

    // Sort by timestamp
    return merged
      ..sort((a, b) => (a['time'] as String).compareTo(b['time'] as String));
  }

  ChatBloc() : super(ChatInitial()) {
    on<ChatStarted>((event, emit) async {
      _channel = event.channel;
      currentUserEmail = event.currentUserEmail;
      _roomName = event.roomName;

      emit(ChatLoading());

      try {
        final localMessages = await _loadMessages();
        emit(ChatLoaded(messages: localMessages));
        // Use your existing ApiService
        final response = await Apiservice.instance.request(
          'api/messages/$_roomName/',
          DioMethod.get,
        );

        final serverMessages =
            (response.data as List)
                .map(
                  (msg) => {
                    'id':
                        msg['id']?.toString() ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    'sender': msg['sender'],
                    'message': msg['message'],
                    'time': msg['time'],
                  },
                )
                .toList();
        final allMessages = _mergeMessages(localMessages, serverMessages);

        await _saveMessages(allMessages);

        emit(ChatLoaded(messages: allMessages));

        _channel.stream.listen(
          (event) {
            try {
              final data = jsonDecode(event);
              add(
                ChatMessageReceived(
                  id: data['id'].toString(),
                  sender: data['sender'],
                  message: data['message'],
                  time: data['time'],
                ),
              );
            } catch (e) {
              add(ChatErrorOccurred(error: "Failed to parse message: $e"));
            }
          },
          onError: (error) => add(ChatErrorOccurred(error: error.toString())),
          onDone: () => add(ChatDisconnected()),
        );
      } catch (e) {
        emit(ChatError(error: "Failed to load messages: ${e.toString()}"));
      }
    });

    on<ChatMessageReceived>((event, emit) async {
      if (state is ChatLoaded) {
        final currentMessages = (state as ChatLoaded).messages;

        // Check if this is an update to a temporary message
        final tempIndex = currentMessages.indexWhere(
          (m) =>
              m['id'].toString().startsWith('temp_') &&
              m['sender'] == event.sender &&
              m['message'] == event.message,
        );

        final updatedMessages = [...currentMessages];

        if (tempIndex != -1) {
          // Replace temporary message with confirmed message
          updatedMessages[tempIndex] = {
            'id': event.id,
            'sender': event.sender,
            'message': event.message,
            'time': event.time,
          };
        } else if (!updatedMessages.any((m) => m['id'] == event.id)) {
          // Add new message if not a duplicate
          updatedMessages.add({
            'id': event.id,
            'sender': event.sender,
            'message': event.message,
            'time': event.time,
          });
        }
        // Save to local storage
        await _saveMessages(updatedMessages);
        emit(ChatLoaded(messages: updatedMessages));
      }
    });

    on<ChatMessageSent>((event, emit) {
      final message = jsonEncode({
        'message': event.message,
        'sender': event.sender,
      });
      _channel.sink.add(message);
      // Optimistically add to local state

      if (state is ChatLoaded) {
        final currentState = (state as ChatLoaded).messages;
        final newMessage = {
          'id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
          'sender': event.sender,
          'message': event.message,
          'time': DateTime.now().toIso8601String(),
        };
        emit(ChatLoaded(messages: [...currentState, newMessage]));
      }
    });

    on<ChatErrorOccurred>((event, emit) {
      emit(ChatError(error: event.error));
    });
  }

  @override
  Future<void> close() {
    _channel.sink.close();
    return super.close();
  }
}
