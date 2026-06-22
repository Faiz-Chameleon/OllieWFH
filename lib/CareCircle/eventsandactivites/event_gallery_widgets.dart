import 'package:flutter/material.dart';

const String kEventImageFallback =
    "https://skala.or.id/wp-content/uploads/2024/01/dummy-post-square-1-1.jpg";

class EventGalleryImageView extends StatefulWidget {
  const EventGalleryImageView({
    super.key,
    required this.imageUrls,
    required this.height,
    this.width = double.infinity,
    this.borderRadius = BorderRadius.zero,
    this.enableSwipe = true,
  });

  final List<String> imageUrls;
  final double height;
  final double width;
  final BorderRadius borderRadius;
  final bool enableSwipe;

  @override
  State<EventGalleryImageView> createState() => _EventGalleryImageViewState();
}

class _EventGalleryImageViewState extends State<EventGalleryImageView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls.isEmpty
        ? <String>[kEventImageFallback]
        : widget.imageUrls;

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.enableSwipe && urls.length > 1
              ? PageView.builder(
                  itemCount: urls.length,
                  onPageChanged: (index) => setState(() {
                    _currentIndex = index;
                  }),
                  itemBuilder: (context, index) => _EventNetworkImage(
                    url: urls[index],
                    height: widget.height,
                    width: widget.width,
                  ),
                )
              : _EventNetworkImage(
                  url: urls.first,
                  height: widget.height,
                  width: widget.width,
                ),
          if (urls.length > 1)
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  "${widget.enableSwipe ? _currentIndex + 1 : 1}/${urls.length}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EventNetworkImage extends StatelessWidget {
  const _EventNetworkImage({
    required this.url,
    required this.height,
    required this.width,
  });

  final String url;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      height: height,
      width: width,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          width: width,
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: const Icon(
            Icons.broken_image_outlined,
            color: Colors.black45,
            size: 42,
          ),
        );
      },
    );
  }
}
