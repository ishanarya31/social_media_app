class Comment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String text;
  final DateTime timeStamp;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.postId,
    required this.text,
    required this.timeStamp,
  });

  // Convert Comment to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'text': text,
      'timeStamp': timeStamp.toIso8601String(),
    };
  }

  // Create Comment from JSON
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['postId'],
      userId: json['userId'],
      userName: json['userName'],
      text: json['text'],
      timeStamp: DateTime.parse(json['timeStamp']),
    );
  }
}
