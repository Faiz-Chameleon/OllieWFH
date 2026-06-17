import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ollie/Volunteers/chat_repository.dart';
import 'package:url_launcher/url_launcher.dart';

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

  bool _isImage(Map<String, dynamic> item) {
    final type = item['attachmentType']?.toString().toLowerCase() ?? '';
    final url = item['attachmentUrl']?.toString().toLowerCase() ?? '';
    return type.contains('image') ||
        url.endsWith('.jpg') ||
        url.endsWith('.jpeg') ||
        url.endsWith('.png') ||
        url.endsWith('.webp');
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
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: url.isEmpty ? null : () => _openUrl(url),
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
                child: _isImage(item) && url.isNotEmpty
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
