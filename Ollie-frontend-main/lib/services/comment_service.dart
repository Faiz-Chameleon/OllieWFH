import '../Models/comment_model.dart';

class CommentService {
  // Singleton pattern
  static final CommentService _instance = CommentService._internal();
  factory CommentService() => _instance;
  CommentService._internal();

  // In a real app, this would be replaced with API calls
  Future<List<Comment>> getComments(String blogId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return sample data with single-level replies - replace with actual API call
    return [
      Comment(
        id: '1',
        user: 'user1',
        userName: 'Julia Michael',
        avatar: 'https://i.pravatar.cc/150?img=1',
        message:
            'I left my shoes outside, and my pup decided they were the perfect snack. Guess who went to work in slippers?',
        likes: 634,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        replies: [
          Comment(
            id: '1-1',
            user: 'user2',
            userName: 'Shelley',
            avatar: 'https://i.pravatar.cc/150?img=2',
            message: 'Haha! That\'s hilarious!',
            likes: 45,
            isLiked: false,
            createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          ),
          Comment(
            id: '1-2',
            user: 'user3',
            userName: 'Mike',
            avatar: 'https://i.pravatar.cc/150?img=3',
            message: 'My dog did the same thing last week!',
            likes: 12,
            isLiked: false,
            createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
        ],
      ),
      Comment(
        id: '2',
        user: 'user1',
        userName: 'Julia Michael',
        avatar: 'https://i.pravatar.cc/150?img=1',
        message:
            'I love hearing these stories! Pets are the best little troublemakers. Keep \'em coming!',
        likes: 634,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        replies: [],
      ),
    ];
  }

  Future<Comment> addComment(String blogId, String message) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));

    // In a real app, this would be an API call
    return Comment(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      user: 'currentUser',
      userName: 'You',
      avatar: 'https://i.pravatar.cc/150?img=6',
      message: message,
      likes: 0,
      isLiked: false,
      createdAt: DateTime.now(),
    );
  }

  Future<Comment> addReply(String commentId, String message) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));

    // In a real app, this would be an API call
    return Comment(
      id: '${commentId}-${DateTime.now().millisecondsSinceEpoch}',
      user: 'currentUser',
      userName: 'You',
      avatar: 'https://i.pravatar.cc/150?img=6',
      message: message,
      likes: 0,
      isLiked: false,
      createdAt: DateTime.now(),
    );
  }

  Future<bool> toggleLike(String commentId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 200));

    // In a real app, this would be an API call
    return true;
  }

  Future<int> getCommentCount(String blogId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 100));

    // In a real app, this would be an API call
    return 15; // Sample count
  }
}
