import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String imageUrl;
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime timeStamp;

  Post({
    required this.text,
    required this.id,
    required this.imageUrl,
    required this.userId,
    required this.userName,
    required this.timeStamp,
  });

  Post copyWith({String? imageUrl}) {
    return Post(
      text: text,
      id: id,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId,
      userName: userName,
      timeStamp: timeStamp,
    );
  }

  // post -> json
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'id': id,
      'imageUrl': imageUrl,
      'userId': userId,
      'userName': userName,
      'timeStamp': timeStamp.toIso8601String(),
    };
  }

  // json -> post
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      text: json['text'],
      id: json['id'],
      imageUrl: json['imageUrl'],
      userId: json['userId'],
      userName: json['userName'],
      timeStamp: DateTime.parse(json['timeStamp']), // Convert String to DateTime
    );
  }
}
