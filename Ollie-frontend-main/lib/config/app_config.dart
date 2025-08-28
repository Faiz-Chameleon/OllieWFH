class AppConfig {
  static String get elevenLabsApiKey {
    return const String.fromEnvironment('ELEVENLABS_API_KEY', defaultValue: '');
  }

  static String get elevenLabsAgentId {
    return const String.fromEnvironment('ELEVENLABS_AGENT_ID', defaultValue: 'agent_01jx7s6f6afgea3c44dz0r4r68');
  }

  // Helper to check if API key is configured
  static bool get isApiKeyConfigured {
    final key = elevenLabsApiKey;
    return key.isNotEmpty && key != 'sk_9397cfffae1c9e05795c482352f9b1d546ab90a3f2308fcd';
  }
}
