import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ollie/Constants/constants.dart';
import 'package:ollie/services/elevenlabs_service.dart';
import 'ollie_controller.dart';

class TTSSettingsScreen extends StatefulWidget {
  @override
  _TTSSettingsScreenState createState() => _TTSSettingsScreenState();
}

class _TTSSettingsScreenState extends State<TTSSettingsScreen> {
  final OllieController controller = Get.find<OllieController>();
  final ElevenLabsService _elevenLabsService = ElevenLabsService();

  List<Map<String, dynamic>> voices = [];
  bool isLoadingVoices = false;

  @override
  void initState() {
    super.initState();
    _loadVoices();
  }

  Future<void> _loadVoices() async {
    setState(() {
      isLoadingVoices = true;
    });

    try {
      final availableVoices = await _elevenLabsService.getVoices();
      setState(() {
        voices = availableVoices;
        isLoadingVoices = false;
      });
    } catch (e) {
      setState(() {
        isLoadingVoices = false;
      });
      Get.snackbar('Error', 'Failed to load voices: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BGcolor,
      appBar: AppBar(
        backgroundColor: BGcolor,
        elevation: 0,
        title: Text(
          'TTS Settings',
          style: TextStyle(color: Black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TTS Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
              ),
              child: Row(
                children: [
                  Icon(Icons.volume_up, color: buttonColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Text-to-Speech',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Black),
                        ),
                        Text('Enable voice responses from Ollie', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  Obx(() => Switch(value: controller.enableTTS.value, onChanged: (value) => controller.toggleTTS(), activeColor: buttonColor)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Voice Selection
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.record_voice_over, color: buttonColor),
                      const SizedBox(width: 12),
                      Text(
                        'Voice Selection',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Black),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (isLoadingVoices)
                    Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(buttonColor)))
                  else if (voices.isEmpty)
                    Text('No voices available', style: TextStyle(color: Colors.grey[600]))
                  else
                    Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.selectedVoiceId.value,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: voices.map((voice) {
                          return DropdownMenuItem<String>(value: voice['voice_id'], child: Text(voice['name'] ?? 'Unknown Voice'));
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            controller.setVoice(value);
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Test Voice Button
            Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (controller.enableTTS.value) {
                    await controller.speakWelcomeMessage();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'Test Voice',
                  style: TextStyle(color: white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // API Key Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Setup Required',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.orange[800]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'To use ElevenLabs TTS, you need to:\n'
                    '1. Get an API key from elevenlabs.io\n'
                    '2. Replace "YOUR_ELEVENLABS_API_KEY" in lib/services/elevenlabs_service.dart\n'
                    '3. Restart the app',
                    style: TextStyle(fontSize: 14, color: Colors.orange[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
