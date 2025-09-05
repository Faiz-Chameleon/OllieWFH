class ChatMessage {
  final String text;
  final bool isUser;
  final bool isStreaming;
  final Map<String, dynamic>? toolCall; // ADD THIS FOR TOOL SUPPORT

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isStreaming = false,
    this.toolCall, // ADD THIS
  });
}
