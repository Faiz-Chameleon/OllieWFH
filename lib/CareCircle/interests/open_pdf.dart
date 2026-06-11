// ignore_for_file: unused_import

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:ollie/common/common.dart';

Future<void> openPdf(String pdfPathOrUrl) async {
  try {
    String localPath = pdfPathOrUrl;

    // If it's a URL, download to temp directory first
    if (pdfPathOrUrl.startsWith('http')) {
      final response = await http.get(Uri.parse(pdfPathOrUrl));
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/temp.pdf');
        await file.writeAsBytes(response.bodyBytes);
        localPath = file.path;
      } else {
        throw Exception('Failed to download PDF');
      }
    }

    final result = await OpenFilex.open(localPath);
    if (result.type != ResultType.done) {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to open PDF: ${result.message}')));
      appSnackbar('Error', 'Unable to open PDF: ${result.message}');
    }
  } catch (e) {
    debugPrint('❌ Error opening PDF: $e');
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error opening PDF')));
    appSnackbar('Error', 'Error opening PDF');
  }
}
