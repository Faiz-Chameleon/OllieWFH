import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:ollie/config/app_config.dart';

class GooglePlacePrediction {
  GooglePlacePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  factory GooglePlacePrediction.fromJson(Map<String, dynamic> json) {
    final formatting =
        json['structured_formatting'] as Map<String, dynamic>? ?? {};
    return GooglePlacePrediction(
      placeId: json['place_id']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      mainText:
          formatting['main_text']?.toString() ??
          json['description']?.toString() ??
          '',
      secondaryText: formatting['secondary_text']?.toString() ?? '',
    );
  }
}

class GooglePlaceDetails {
  GooglePlaceDetails({required this.address, required this.latLng});

  final String address;
  final LatLng latLng;
}

class GooglePlacesService {
  GooglePlacesService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static const String _autocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const String _detailsUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';

  Future<List<GooglePlacePrediction>> autocomplete(String input) async {
    final query = input.trim();
    if (query.isEmpty) {
      return [];
    }

    final uri = Uri.parse(_autocompleteUrl).replace(
      queryParameters: {
        'input': query,
        'key': AppConfig.googlePlacesApiKey,
        'types': 'geocode',
      },
    );

    final response = await _client.get(uri);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final status = body['status']?.toString() ?? '';

    if (status == 'OK') {
      final predictions = body['predictions'] as List<dynamic>? ?? [];
      return predictions
          .map(
            (prediction) => GooglePlacePrediction.fromJson(
              prediction as Map<String, dynamic>,
            ),
          )
          .where((prediction) => prediction.placeId.isNotEmpty)
          .toList();
    }

    if (status == 'ZERO_RESULTS') {
      return [];
    }

    throw Exception(
      body['error_message']?.toString() ?? 'Google Places autocomplete failed.',
    );
  }

  Future<GooglePlaceDetails?> details(String placeId) async {
    if (placeId.trim().isEmpty) {
      return null;
    }

    final uri = Uri.parse(_detailsUrl).replace(
      queryParameters: {
        'place_id': placeId,
        'key': AppConfig.googlePlacesApiKey,
        'fields': 'formatted_address,geometry',
      },
    );

    final response = await _client.get(uri);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final status = body['status']?.toString() ?? '';

    if (status != 'OK') {
      throw Exception(
        body['error_message']?.toString() ?? 'Google Places details failed.',
      );
    }

    final result = body['result'] as Map<String, dynamic>? ?? {};
    final geometry = result['geometry'] as Map<String, dynamic>? ?? {};
    final location = geometry['location'] as Map<String, dynamic>? ?? {};
    final latitude = (location['lat'] as num?)?.toDouble();
    final longitude = (location['lng'] as num?)?.toDouble();

    if (latitude == null || longitude == null) {
      return null;
    }

    return GooglePlaceDetails(
      address: result['formatted_address']?.toString() ?? '',
      latLng: LatLng(latitude, longitude),
    );
  }
}
