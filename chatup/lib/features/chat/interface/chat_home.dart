import 'dart:convert';

import 'package:chatup/Core/services/apiservice.dart';
import 'package:chatup/Core/services/auth_service.dart';
import 'package:chatup/navigation/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Userdetails {
  final int id;
  final String firstname;
  final String lastname;
  final String email;
  Userdetails({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
  });
  factory Userdetails.fromJson(Map<String, dynamic> json) {
    return Userdetails(
      id: json['id'],
      email: json['email'],
      firstname: json['first_name'],
      lastname: json['last_name'],
    );
  }
}

class ChatHome extends StatefulWidget {
  const ChatHome({super.key});

  @override
  State<ChatHome> createState() => _ChatHomeState();
}
  Future<Userdetails> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final id = prefs.getInt('id');

    if (token == null || id == null) {
      throw Exception('No auth token or user ID found');
    }
    final response = await Apiservice.instance.request(
      "http://10.0.2.2:8000/users/$id",
      DioMethod.get,
    );
    if (response.statusCode == 200) {
      return Userdetails.fromJson(response.data);
    } else {
      throw Exception('Data not retrieved.');
    }
  }

class _ChatHomeState extends State<ChatHome> {
  late Future<Userdetails> userdetails;
  late Future<List<Userdetails>> users;

  @override
  void initState() {
    super.initState();
    userdetails = getUser();
    users = getUsers();
  }

  Future<List<Userdetails>> getUsers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('No auth token found');
    }

    final response = await Apiservice.instance.request(
      "http://10.0.2.2:8000/users/list",
      DioMethod.get,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      return data.map((json) => Userdetails.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch users');
    }
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
                  context.pop();
                },
                child: Icon(Icons.arrow_back_ios),
              ),
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
        child:
            FutureBuilder(
              future: users,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: Text("Loading..."));
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No users available"));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final user = snapshot.data![index];
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

                
              },
            ),
          
      ),
    );
  }
}
