import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:chatup/Core/models/user_details.dart';
import 'package:chatup/Core/services/apiservice.dart';
import 'package:chatup/features/chat/interface/chat_home.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'chat_home_event.dart';
part 'chat_home_state.dart';

class ChatHomeBloc extends Bloc<ChatHomeEvent, ChatHomeState> {
  ChatHomeBloc() : super(ChatHomeState()) {
    on<GetUsers>((event, emit) async {
      emit(ChatHomeInitial());
      // await Future.delayed(Duration(seconds: 2));
      try {
        final user = await getUsers();
        emit(ChatHomeSuccess(users: user));
      } catch (state) {
        emit(ChatHomeError());
      }
    });
  }
}

Future<List<Userdetails>> getUsers() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) {
    throw Exception('No auth token found');
  }
  final baseurl = Apiservice.instance.baseurl;
  final response = await Apiservice.instance.request(
    "${baseurl}users/list",
    DioMethod.get,
  );

  if (response.statusCode == 200) {
    List<dynamic> data = response.data;
    return data.map((json) => Userdetails.fromJson(json)).toList();
  } else {
    throw Exception('Failed to fetch users');
  }
}
