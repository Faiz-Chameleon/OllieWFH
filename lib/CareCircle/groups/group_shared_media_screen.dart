import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ollie/Volunteers/chat_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class GroupSharedMediaScreen extends StatefulWidget {
  final String chatRoomId;

  const GroupSharedMediaScreen({super.key, required this.chatRoomId});

  @override
  State<GroupSharedMediaScreen> createState() => _GroupSharedMediaScreenState();
}

class _GroupSharedMediaScreenState extends State<GroupSharedMediaScreen> {
  final ChatRepository _repository = ChatRepository();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _items = [];
  String? _selectedType;
  int _page = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  static const int _limit = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMedia(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 300) {
      return;
    }

    if (!_isLoading && !_isLoadingMore && _page < _totalPages) {
      _loadMedia();
    }
  }

  Future<void> _loadMedia({bool reset = false}) async {
    if (_isLoading || _isLoadingMore) return;

    setState(() {
      if (reset) {
        _page = 1;
        _totalPages = 1;
        _items.clear();
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }
      _errorMessage = null;
    });

    final nextPage = reset ? 1 : _page + 1;
    final result = await _repository.getGroupSharedMedia(
      widget.chatRoomId,
      page: nextPage,
      limit: _limit,
      attachmentType: _selectedType,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      final data = result['data'];
      final items = data is Map && data['items'] is List
          ? data['items'] as List
          : const [];
      final pagination = data is Map ? data['pagination'] : null;

      setState(() {
        _items.addAll(
          items.whereType<Map>().map(
            (item) => item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        );
        _page = nextPage;
        _totalPages = _parseInt(
          pagination is Map ? pagination['totalPages'] : null,
          fallback: nextPage,
        );
        _isLoading = false;
        _isLoadingMore = false;
      });
      return;
    }

    setState(() {
      _errorMessage =
          result['message']?.toString() ?? 'Unable to load shared media';
      _isLoading = false;
      _isLoadingMore = false;
    });
  }

  int _parseInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  void _selectType(String? type) {
    if (_selectedType == type) return;
    setState(() => _selectedType = type);
    _loadMedia(reset: true);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      Get.snackbar('Error', 'Unable to open this file');
    }
  }

  void _openImagePreview(Map<String, dynamic> item) {
    final imageItems = _items.where(_isImage).toList();
    final urls = imageItems
        .map((imageItem) => imageItem['attachmentUrl']?.toString() ?? '')
        .where((url) => url.isNotEmpty)
        .toList();
    if (urls.isEmpty) return;

    final tappedUrl = item['attachmentUrl']?.toString() ?? '';
    final initialIndex = urls.indexOf(tappedUrl);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SharedMediaImagePreviewScreen(
          urls: urls,
          initialIndex: initialIndex == -1 ? 0 : initialIndex,
        ),
      ),
    );
  }

  void _openVideoPreview(Map<String, dynamic> item) {
    final url = item['attachmentUrl']?.toString() ?? '';
    if (url.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SharedMediaVideoPreviewScreen(url: url),
      ),
    );
  }

  bool _isImage(Map<String, dynamic> item) {
    final type = item['attachmentType']?.toString().toLowerCase() ?? '';
    final url = item['attachmentUrl']?.toString().toLowerCase() ?? '';
    return type.contains('image') ||
        url.endsWith('.jpg') ||
        url.endsWith('.jpeg') ||
        url.endsWith('.png') ||
        url.endsWith('.webp');
  }

  bool _isVideo(Map<String, dynamic> item) {
    final type = item['attachmentType']?.toString().toLowerCase() ?? '';
    final url = item['attachmentUrl']?.toString().toLowerCase() ?? '';
    return type.contains('video') ||
        url.endsWith('.mp4') ||
        url.endsWith('.mov') ||
        url.endsWith('.m4v') ||
        url.endsWith('.webm') ||
        url.endsWith('.avi');
  }

  IconData _iconFor(Map<String, dynamic> item) {
    final type = item['attachmentType']?.toString().toLowerCase() ?? '';
    if (type.contains('video')) return Icons.play_circle_fill_rounded;
    if (type.contains('pdf')) return Icons.picture_as_pdf_rounded;
    return Icons.insert_drive_file_rounded;
  }

  String _senderName(Map<String, dynamic> item) {
    final sender = item['sender'];
    if (sender is Map) {
      final first = sender['firstName']?.toString().trim() ?? '';
      final last = sender['lastName']?.toString().trim() ?? '';
      final fullName = [first, last].where((part) => part.isNotEmpty).join(' ');
      if (fullName.isNotEmpty) return fullName;
      final name = sender['name']?.toString().trim();
      if (name != null && name.isNotEmpty) return name;
    }
    return 'Unknown sender';
  }

  String _createdAt(Map<String, dynamic> item) {
    final value = item['createdAt']?.toString();
    final parsed = DateTime.tryParse(value ?? '');
    if (parsed == null) return '';
    return DateFormat('MMM d, yyyy').format(parsed.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6E8),
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Shared Media'),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          _filterChip('All', null),
          _filterChip('Images', 'image'),
          _filterChip('Videos', 'video'),
          _filterChip('PDFs', 'pdf'),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String? type) {
    final selected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => _selectType(type),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_errorMessage!, textAlign: TextAlign.center),
        ),
      );
    }

    if (_items.isEmpty) {
      return const Center(child: Text('No shared media found'));
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: _items.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildMediaCard(_items[index]);
      },
    );
  }

  Widget _buildMediaCard(Map<String, dynamic> item) {
    final url = item['attachmentUrl']?.toString() ?? '';
    final isImage = _isImage(item);
    final isVideo = _isVideo(item);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: url.isEmpty
          ? null
          : () => isImage
                ? _openImagePreview(item)
                : isVideo
                ? _openVideoPreview(item)
                : _openUrl(url),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8D8BB)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: isImage && url.isNotEmpty
                    ? Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _filePreview(item),
                      )
                    : _filePreview(item),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _senderName(item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _createdAt(item),
                    maxLines: 1,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filePreview(Map<String, dynamic> item) {
    return Container(
      color: const Color(0xFFF4E4C3),
      alignment: Alignment.center,
      child: Icon(_iconFor(item), size: 46, color: Colors.brown.shade500),
    );
  }
}

class _SharedMediaImagePreviewScreen extends StatefulWidget {
  const _SharedMediaImagePreviewScreen({
    required this.urls,
    required this.initialIndex,
  });

  final List<String> urls;
  final int initialIndex;

  @override
  State<_SharedMediaImagePreviewScreen> createState() =>
      _SharedMediaImagePreviewScreenState();
}

class _SharedMediaImagePreviewScreenState
    extends State<_SharedMediaImagePreviewScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.urls.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: widget.urls.length > 1
            ? Text('${_currentIndex + 1}/${widget.urls.length}')
            : null,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.urls.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 1,
            maxScale: 4,
            child: Center(
              child: Image.network(
                widget.urls[index],
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image_rounded,
                  color: Colors.white,
                  size: 56,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SharedMediaVideoPreviewScreen extends StatefulWidget {
  const _SharedMediaVideoPreviewScreen({required this.url});

  final String url;

  @override
  State<_SharedMediaVideoPreviewScreen> createState() =>
      _SharedMediaVideoPreviewScreenState();
}

class _SharedMediaVideoPreviewScreenState
    extends State<_SharedMediaVideoPreviewScreen> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
      );
      await controller.initialize();
      await controller.play();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : _error != null || controller == null
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'Unable to play video',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              )
            : AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(controller),
                    _SharedMediaVideoControls(controller: controller),
                  ],
                ),
              ),
      ),
    );
  }
}

class _SharedMediaVideoControls extends StatefulWidget {
  const _SharedMediaVideoControls({required this.controller});

  final VideoPlayerController controller;

  @override
  State<_SharedMediaVideoControls> createState() =>
      _SharedMediaVideoControlsState();
}

class _SharedMediaVideoControlsState extends State<_SharedMediaVideoControls> {
  bool _isSeeking = false;
  double? _dragValue;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    final minutes = ((totalSeconds ~/ 60) % 60).toString().padLeft(2, '0');
    final hours = totalSeconds ~/ 3600;
    if (hours > 0) return '$hours:$minutes:$seconds';
    return '$minutes:$seconds';
  }

  Future<void> _seekBy(Duration offset) async {
    final value = widget.controller.value;
    final duration = value.duration;
    final target = value.position + offset;
    final safeTarget = target < Duration.zero
        ? Duration.zero
        : target > duration
        ? duration
        : target;
    await widget.controller.seekTo(safeTarget);
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.value;
    final isPlaying = value.isPlaying;
    final duration = value.duration;
    final position = value.position > duration ? duration : value.position;
    final maxMilliseconds = duration.inMilliseconds.toDouble();
    final sliderValue =
        _dragValue ??
        position.inMilliseconds.toDouble().clamp(0, maxMilliseconds);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (isPlaying) {
          widget.controller.pause();
        } else {
          widget.controller.play();
        }
      },
      child: Stack(
        children: [
          Center(
            child: AnimatedOpacity(
              opacity: isPlaying ? 0 : 1,
              duration: const Duration(milliseconds: 150),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 56,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 7,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14,
                      ),
                      activeTrackColor: const Color(0xFFF4BD2A),
                      inactiveTrackColor: Colors.white30,
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      min: 0,
                      max: maxMilliseconds <= 0 ? 1 : maxMilliseconds,
                      value: sliderValue.toDouble(),
                      onChangeStart: (_) => setState(() => _isSeeking = true),
                      onChanged: (value) => setState(() => _dragValue = value),
                      onChangeEnd: (value) async {
                        await widget.controller.seekTo(
                          Duration(milliseconds: value.round()),
                        );
                        if (mounted) {
                          setState(() {
                            _isSeeking = false;
                            _dragValue = null;
                          });
                        }
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _formatDuration(
                          Duration(
                            milliseconds:
                                (_isSeeking
                                        ? sliderValue
                                        : position.inMilliseconds)
                                    .round(),
                          ),
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _seekBy(const Duration(seconds: -10)),
                        icon: const Icon(
                          Icons.replay_10_rounded,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (isPlaying) {
                            widget.controller.pause();
                          } else {
                            widget.controller.play();
                          }
                        },
                        icon: Icon(
                          isPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_fill_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _seekBy(const Duration(seconds: 10)),
                        icon: const Icon(
                          Icons.forward_10_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDuration(duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
