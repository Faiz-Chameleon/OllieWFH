// ignore_for_file: unnecessary_string_interpolations, depend_on_referenced_packages

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:ollie/app_urls.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
// For better MIME type detection

class ApiService {
  static Future<Map<String, dynamic>> postMethod(
    String endpoint,
    Map<String, dynamic> data, {
    String? token,
  }) async {
    var headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    var request = http.Request(
      'POST',
      Uri.parse('${ApiUrls.baseUrl}$endpoint'),
    );

    request.body = json.encode(data);
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();

      final parsed = json.decode(responseString);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': parsed['data'],
          'message': parsed['message'] ?? '',
        };
      } else {
        return {
          'success': false,
          'message': parsed['message'] ?? 'Something went wrong',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final uri = Uri.parse('${ApiUrls.baseUrl}$endpoint');
      final response = await http.get(uri);
      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Something went wrong',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getMethod(
    String endpoint, {
    String? token,
  }) async {
    var headers = {
      'Content-Type': 'application/json',
      if (token != null) 'x-access-token': '$token',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    var request = http.Request('GET', Uri.parse('${ApiUrls.baseUrl}$endpoint'));

    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();

      final parsed = json.decode(responseString);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': parsed['data'],
          'message': parsed['message'] ?? '',
        };
      } else {
        return {
          'success': false,
          'message': parsed['message'] ?? 'Something went wrong',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> putMethod(
    String endpoint, {
    Map<String, dynamic> data = const {},
    String? token,
  }) async {
    var headers = {
      'Content-Type': 'application/json',
      if (token != null) 'x-access-token': '$token',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    var request = http.Request('PUT', Uri.parse('${ApiUrls.baseUrl}$endpoint'));

    request.body = json.encode(data);
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();
      final parsed = json.decode(responseString);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': parsed['data'],
          'message': parsed['message'] ?? '',
        };
      } else {
        return {
          'success': false,
          'message': parsed['message'] ?? 'Something went wrong',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> postMultipart(
    String endpoint,
    Map<String, dynamic> data,
    File? file, {
    String? token,
  }) async {
    var headers = {if (token != null) 'x-access-token': token};

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiUrls.baseUrl}$endpoint'),
    );

    // Add fields to the request
    data.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    // Add file to the request if available
    if (file != null) {
      final mime = lookupMimeType(file.path) ?? 'image/jpeg';
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          file.path,
          contentType: MediaType.parse(mime),
        ),
      );
    }

    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();

      final parsed = _decodeJsonObject(responseString);
      if (parsed == null) {
        return {
          'success': false,
          'message': _nonJsonResponseMessage(
            response.statusCode,
            responseString,
          ),
        };
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': parsed['data'],
          'message': parsed['message'] ?? '',
        };
      } else {
        return {
          'success': false,
          'message': parsed['message'] ?? 'Something went wrong',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> postMultipartWithFiles(
    String endpoint,
    Map<String, dynamic> data,
    File? imageFile,
    XFile? videoFile,
    XFile? documentFile, {
    String? token,
  }) async {
    var headers = {if (token != null) 'x-access-token': '$token'};

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiUrls.baseUrl}$endpoint'),
    );

    // Add fields to the request
    data.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        request.fields[key] = value.toString();
      }
    });

    // Add image file if available
    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    // Add video file if available
    if (videoFile != null) {
      final mime = lookupMimeType(videoFile.path) ?? 'video/mp4';
      // iOS .mov => 'video/quicktime' (lookupMimeType will usually return that)
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // <- your backend field
          videoFile.path,
          contentType: MediaType.parse(mime),
        ),
      );
    }
    if (documentFile != null) {
      final mime =
          lookupMimeType(documentFile.path) ?? 'application/octet-stream';
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // match your backend
          documentFile.path,
          contentType: MediaType.parse(mime),
        ),
      );
    }

    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();

      final parsed = json.decode(responseString);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': parsed['data'],
          'message': parsed['message'] ?? '',
        };
      } else {
        return {
          'success': false,
          'message': parsed['message'] ?? 'Something went wrong',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> postMultipartWithAttachments(
    String endpoint,
    Map<String, dynamic> data,
    List<XFile> attachments, {
    String? token,
  }) async {
    var headers = {
      if (token != null) 'Authorization': 'Bearer $token',
      if (token != null) 'x-access-token': token,
    };

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiUrls.baseUrl}$endpoint'),
    );

    data.forEach((key, value) {
      if (value == null) return;
      if (value is Iterable || value is Map) {
        request.fields[key] = json.encode(value);
      } else {
        request.fields[key] = value.toString();
      }
    });

    for (final attachment in attachments.take(10)) {
      final mime =
          lookupMimeType(attachment.path) ?? 'application/octet-stream';
      request.files.add(
        await http.MultipartFile.fromPath(
          'attachments',
          attachment.path,
          contentType: MediaType.parse(mime),
        ),
      );
    }

    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();

      final parsed = _decodeJsonObject(responseString);
      if (parsed == null) {
        return {
          'success': false,
          'message': _nonJsonResponseMessage(
            response.statusCode,
            responseString,
          ),
        };
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': parsed['data'],
          'message': parsed['message'] ?? '',
        };
      } else {
        return {
          'success': false,
          'message': parsed['message'] ?? 'Something went wrong',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> putMultipart(
    String endpoint, {
    Map<String, String>? fields,
    String? fileKey,
    String? filePath,
    String? token,
  }) async {
    try {
      // Create MultipartRequest
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiUrls.baseUrl}$endpoint'),
      );

      // Add headers
      if (token != null) {
        request.headers.addAll({'x-access-token': token});
      }

      // Add fields if any
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add file if provided
      if (fileKey != null && filePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            fileKey,
            filePath,
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      // Send request
      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();

      final parsed = json.decode(responseString);

      // Check status
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': parsed['data'],
          'message': parsed['message'] ?? '',
        };
      } else {
        return {
          'success': false,
          'message': parsed['message'] ?? 'Something went wrong',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> deleteMethod(
    String endpoint, {
    Map<String, dynamic> data = const {},
    String? token,
  }) async {
    var headers = {
      'Content-Type': 'application/json',
      if (token != null) 'x-access-token': token,
    };

    var request = http.Request(
      'DELETE',
      Uri.parse('${ApiUrls.baseUrl}$endpoint'),
    );
    request.body = json.encode(data);
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();
      final parsed = json.decode(responseString);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'data': parsed['data'],
          'message': parsed['message'] ?? '',
        };
      } else {
        return {
          'success': false,
          'message': parsed['message'] ?? 'Something went wrong',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Map<String, dynamic>? _decodeJsonObject(String responseBody) {
    try {
      final decoded = json.decode(responseBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  static String _nonJsonResponseMessage(int statusCode, String responseBody) {
    final plainText = responseBody
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (plainText.isEmpty) {
      return 'Server returned status $statusCode with an empty response';
    }

    final preview = plainText.length > 180
        ? '${plainText.substring(0, 180)}...'
        : plainText;
    return 'Server returned status $statusCode: $preview';
  }
}
