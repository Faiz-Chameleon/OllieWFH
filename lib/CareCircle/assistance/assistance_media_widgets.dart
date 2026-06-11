import 'package:flutter/material.dart';
import 'package:ollie/CareCircle/interests/video_player_widget.dart';
import 'package:ollie/Models/assistance_attachment.dart';
import 'package:url_launcher/url_launcher.dart';

bool _isImageAttachment(AssistanceAttachment attachment) {
  final type = attachment.type?.toLowerCase() ?? '';
  final url = attachment.url?.toLowerCase() ?? '';
  return type.startsWith('image') ||
      url.endsWith('.jpg') ||
      url.endsWith('.jpeg') ||
      url.endsWith('.png') ||
      url.endsWith('.gif') ||
      url.endsWith('.webp');
}

bool _isVideoAttachment(AssistanceAttachment attachment) {
  final type = attachment.type?.toLowerCase() ?? '';
  final url = attachment.url?.toLowerCase() ?? '';
  return type.startsWith('video') ||
      url.endsWith('.mp4') ||
      url.endsWith('.mov') ||
      url.endsWith('.m4v') ||
      url.endsWith('.avi') ||
      url.endsWith('.webm');
}

Future<void> _openAttachment(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

class AssistanceMediaStrip extends StatelessWidget {
  const AssistanceMediaStrip({
    super.key,
    required this.attachments,
    this.height = 72,
  });

  final List<AssistanceAttachment> attachments;
  final double height;

  @override
  Widget build(BuildContext context) {
    final visibleAttachments = attachments
        .where((attachment) => attachment.url?.isNotEmpty == true)
        .toList();
    if (visibleAttachments.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: visibleAttachments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final attachment = visibleAttachments[index];
          final url = attachment.url!;
          return InkWell(
            onTap: () => _openAttachment(url),
            borderRadius: BorderRadius.circular(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: height,
                height: height,
                child: _isImageAttachment(attachment)
                    ? Image.network(url, fit: BoxFit.cover)
                    : Container(
                        color: const Color(0xFFF6EEDC),
                        child: Icon(
                          _isVideoAttachment(attachment)
                              ? Icons.play_circle_outline
                              : Icons.insert_drive_file,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AssistanceMediaGallery extends StatelessWidget {
  const AssistanceMediaGallery({super.key, required this.attachments});

  final List<AssistanceAttachment> attachments;

  @override
  Widget build(BuildContext context) {
    final visibleAttachments = attachments
        .where((attachment) => attachment.url?.isNotEmpty == true)
        .toList();
    if (visibleAttachments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(visibleAttachments.length, (index) {
        final attachment = visibleAttachments[index];
        final url = attachment.url!;

        if (_isImageAttachment(attachment)) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                url,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          );
        }

        if (_isVideoAttachment(attachment)) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 220,
                width: double.infinity,
                child: VideoPlayerWidget(videoUrl: url),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _openAttachment(url),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF6EEDC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.insert_drive_file),
                  SizedBox(width: 10),
                  Expanded(child: Text("Open attachment")),
                  Icon(Icons.open_in_new, size: 18),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
