import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/features/post/domain/entities/comment.dart';

class Post {
  final String imageUrl;
  final String id;
  final String userId;
  final String userName;
  final String text;
  final DateTime timeStamp;
  final List<String> likes;
  final List<Comment> comments;

  Post({
    required this.text,
    required this.id,
    required this.imageUrl,
    required this.userId,
    required this.userName,
    required this.timeStamp,
    required this.likes,
    required this.comments,
  });

  Post copyWith({String? imageUrl}) {
    return Post(
      text: text,
      id: id,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId,
      userName: userName,
      timeStamp: timeStamp,
      likes: likes,
      comments: comments,
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
      'likes': likes,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }

  // json -> post
  factory Post.fromJson(Map<String, dynamic> json) {
    //prepare comments
    final List<Comment> comments =
        (json['comments'] as List<dynamic>?)
            ?.map((commentJson) => Comment.fromJson(commentJson))
            .toList() ??
            [];


    return Post(
      text: json['text'],
      id: json['id'],
      imageUrl: json['imageUrl'],
      userId: json['userId'],
      userName: json['userName'],
      timeStamp: DateTime.parse(
        json['timeStamp'],
      ), // Convert String to DateTime
      likes: List<String>.from(json['likes'] ?? []),
      comments: comments,
    );
  }
}
