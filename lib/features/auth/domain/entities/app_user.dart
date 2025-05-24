import 'dart:convert';

class AppUser {
  final String uid;
  final String email;
  final String name;

  AppUser({required this.uid, required this.email, required this.name});

  //convert user to json format
  Map<String, dynamic> toJson() {
    return {'uid': uid, 'email': email, 'name': name};
  }

  //convert back to user
  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
      uid: jsonUser['uid'],
      email: jsonUser['email'],
      name: jsonUser['name'],
    );
  }
}
