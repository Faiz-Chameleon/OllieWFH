class Comment {
  final String id;
  final String user;
  final String userName;
  final String? avatar;
  final String message;
  final int likes;
  final bool isLiked;
  final List<Comment> replies;
  final DateTime createdAt;
  final bool isExpanded;

  Comment({
    required this.id,
    required this.user,
    required this.userName,
    this.avatar,
    required this.message,
    this.likes = 0,
    this.isLiked = false,
    this.replies = const [],
    required this.createdAt,
    this.isExpanded = false,
  });

  Comment copyWith({
    String? id,
    String? user,
    String? userName,
    String? avatar,
    String? message,
    int? likes,
    bool? isLiked,
    List<Comment>? replies,
    DateTime? createdAt,
    bool? isExpanded,
  }) {
    return Comment(
      id: id ?? this.id,
      user: user ?? this.user,
      userName: userName ?? this.userName,
      avatar: avatar ?? this.avatar,
      message: message ?? this.message,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      replies: replies ?? this.replies,
      createdAt: createdAt ?? this.createdAt,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'userName': userName,
      'avatar': avatar,
      'message': message,
      'likes': likes,
      'isLiked': isLiked,
      'replies': replies.map((reply) => reply.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isExpanded': isExpanded,
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      user: json['user'],
      userName: json['userName'],
      avatar: json['avatar'],
      message: json['message'],
      likes: json['likes'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      replies:
          (json['replies'] as List<dynamic>?)
              ?.map((reply) => Comment.fromJson(reply))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
      isExpanded: json['isExpanded'] ?? false,
    );
  }
}
