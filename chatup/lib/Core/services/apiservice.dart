import 'dart:ffi';
import 'dart:io';

import 'package:chatup/Core/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DioMethod{post, put, delete, get}

class AuthHolder {
  static String? token;
  static int? id;
}

class Apiservice {
  Apiservice._singleton();
//   static Future<List<Map<String, dynamic>>> getChatMessages(String roomName) async {
//   try {
//     final response = await instance.request(
//       'api/messages/$roomName/',
//       DioMethod.get,
//     );
    
//     return (response.data as List).map((msg) => {
//       'sender': msg['sender'],
//       'message': msg['message'],
//       'time': msg['time'],
//     }).toList();
//   } catch (e) {
//     debugPrint("Error fetching messages: $e");
//     rethrow;
//   }
// }
  static final Apiservice instance = Apiservice._singleton();
  String get baseurl {
    if (kDebugMode) {
      return "http://10.0.2.2:8000/";
    }
    return "http://10.0.2.2:8000/";
  }

  Future<Response> request(
    String endpoint,
    DioMethod method, {
    Map<String, dynamic>? param,
    String? contentType,
    dynamic formData,
  }) async {
     final dio = Dio(
        BaseOptions(
          baseUrl: baseurl,
          headers:  {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
          contentType: contentType ?? Headers.jsonContentType,
          // headers: {HttpHeaders.authorizationHeader: 'Bearer'},
          responseType: ResponseType.json,
        ),
      );
    final options = Options(
      contentType: Headers.jsonContentType,
      headers: {'Accept': 'application/json'},
    );
     final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token != null) {
    dio.options.headers['Authorization'] = 'Token $token';
  }
    try {
      switch (method) {
        case DioMethod.post:
          return dio.post(
            endpoint, data: param ?? formData,
            options: options);
          case DioMethod.get:
        return await dio.get(endpoint, queryParameters: param);
      case DioMethod.put:
        return await dio.put(endpoint, data: param ?? formData);
      case DioMethod.delete:
        return await dio.delete(endpoint, data: param ?? formData);
      default:
        return await dio.post(endpoint, data: param ?? formData);
      }
      
    } on DioException catch (e) {
    // Better error handling
    if (e.response != null) {
      print(e.response?.data);
      print(e.response?.headers);
      print(e.response?.requestOptions);
    } else {
      print(e.requestOptions);
      print(e.message);
    }
    rethrow;
  }
  }
}
