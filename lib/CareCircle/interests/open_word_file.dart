import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

Future<void> openDocFile(String pathOrUrl) async {
  try {
    String localPath = pathOrUrl;

    // If it's a URL, download to temp first
    if (pathOrUrl.startsWith('http')) {
      final res = await http.get(Uri.parse(pathOrUrl));
      if (res.statusCode != 200) throw Exception('Download failed: ${res.statusCode}');
      final dir = await getTemporaryDirectory();
      // keep original name if possible:
      final name = pathOrUrl.split('/').last.split('?').first;
      final file = File('${dir.path}/$name');
      await file.writeAsBytes(res.bodyBytes);
      localPath = file.path;
    }

    final result = await OpenFilex.open(localPath); // hands off to OS
    if (result.type != ResultType.done) {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to open: ${result.message}')));
      Get.snackbar('Error', 'Unable to open document: ${result.message}');
    }
  } catch (e) {
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error opening document')));
    Get.snackbar('Error', 'Error opening document');
    debugPrint('❌ Error opening document: $e');
  }
}
