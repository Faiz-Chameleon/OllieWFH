import 'dart:io';
import 'dart:convert';

void main() async {
  const String apiKey = 'sk_9397cfffae1c9e05795c482352f9b1d546ab90a3f2308fcd';

  print('🧪 Testing ElevenLabs Agent List');
  print('================================');
  print('🔑 API Key: ${apiKey.substring(0, 10)}...\n');

  try {
    // First, let's check what agents are available
    print('🔍 Checking available agents...');

    final response = await HttpClient().getUrl(Uri.parse('https://api.elevenlabs.io/v1/convai/agents'));

    response.headers.set('xi-api-key', apiKey);
    response.headers.set('Content-Type', 'application/json');

    final httpResponse = await response.close();
    final responseBody = await httpResponse.transform(utf8.decoder).join();

    print('📋 Response status: ${httpResponse.statusCode}');
    print('📋 Response body: $responseBody');

    if (httpResponse.statusCode == 200) {
      final agents = jsonDecode(responseBody);
      print('✅ Found ${agents.length} agents');

      for (var agent in agents) {
        print('🤖 Agent: ${agent['name']} (${agent['agent_id']})');
      }
    } else {
      print('❌ Failed to get agents: ${httpResponse.statusCode}');
    }
  } catch (e) {
    print('❌ Error: $e');
  }

  print('\n🎉 Test completed!');
}
