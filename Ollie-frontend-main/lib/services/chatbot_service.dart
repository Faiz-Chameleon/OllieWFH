import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  // You can replace this with your preferred AI service
  // Examples: OpenAI, Claude, or your own AI backend
  //wsec_09f408131472d6767be8084ef61c284785e9c3f05e540ed8b9ebc02a337bfdaf

  static const String _apiKey = 'sk_9397cfffae1c9e05795c482352f9b1d546ab90a3f2308fcd';
  // sk_17ea44ebc250eed72a654a1a7f167bec8ecb9b3132dc5466'; // Replace with your AI service API key
  static const String _apiUrl = 'https://api.openai.com/v1/chat/completions'; // Example OpenAI endpoint

  // Simple response system for demonstration
  static final Map<String, List<String>> _responses = {
    'greeting': [
      "Hello! I'm Ollie, your helpful companion. How can I assist you today?",
      "Hi there! I'm here to help you stay organized and manage your tasks.",
      "Welcome! I'm Ollie, ready to help you with whatever you need.",
    ],
    'tasks': [
      "I can help you manage your daily tasks. Would you like me to show you what's on your schedule?",
      "Let me check your task list for today. I'll make sure you stay on track!",
      "I can help you organize your tasks and set reminders. What would you like to do?",
    ],
    'weather': [
      "I can help you check the weather! Let me get that information for you.",
      "Would you like to know the weather forecast? I can provide that for you.",
      "I can access weather information to help you plan your day better.",
    ],
    'reminder': [
      "I can set reminders for you. What would you like me to remind you about?",
      "Setting reminders is one of my specialties! Just tell me what and when.",
      "I'll help you set up reminders so you never miss important things.",
    ],
    'default': [
      "I'm here to help! You can ask me about tasks, reminders, or anything else you need assistance with.",
      "That's interesting! I'm always learning and here to support you.",
      "I'm your companion Ollie, ready to help with whatever you need.",
    ],
  };

  // Get response based on user input
  static String getResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('hello') || message.contains('hi') || message.contains('hey')) {
      return _getRandomResponse('greeting');
    } else if (message.contains('task') || message.contains('todo') || message.contains('schedule')) {
      return _getRandomResponse('tasks');
    } else if (message.contains('weather') || message.contains('forecast')) {
      return _getRandomResponse('weather');
    } else if (message.contains('remind') || message.contains('reminder')) {
      return _getRandomResponse('reminder');
    } else {
      return _getRandomResponse('default');
    }
  }

  static String _getRandomResponse(String category) {
    final responses = _responses[category] ?? _responses['default']!;
    responses.shuffle();
    return responses.first;
  }

  // For integration with actual AI services (OpenAI example)
  static Future<String?> getAIResponse(String userMessage) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Authorization': 'Bearer $_apiKey', 'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are Ollie, a friendly and helpful assistant who helps users stay organized and manage their tasks. Keep responses concise and friendly.',
            },
            {'role': 'user', 'content': userMessage},
          ],
          'temperature': 0.7,
          'max_tokens': 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        print('AI API Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error calling AI service: $e');
      return null;
    }
  }

  // Hybrid approach: try AI first, fallback to simple responses
  static Future<String> getHybridResponse(String userMessage) async {
    try {
      final aiResponse = await getAIResponse(userMessage);
      if (aiResponse != null) {
        return aiResponse;
      }
    } catch (e) {
      print('AI service failed, using fallback: $e');
    }

    return getResponse(userMessage);
  }
}
