// ignore_for_file: unnecessary_this, prefer_collection_literals, unnecessary_new

import 'package:ollie/Models/latest_events_model.dart';

class NearestEventModel {
  bool? success;
  String? message;
  List<NearestEventsData>? data;

  NearestEventModel({this.success, this.message, this.data});

  NearestEventModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <NearestEventsData>[];
      json['data'].forEach((v) {
        data!.add(new NearestEventsData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NearestEventsData {
  String? id;
  String? eventName;
  String? eventDescription;
  String? eventDateAndTime;
  String? eventAddress;
  String? eventStates;
  String? eventCity;
  String? eventCountry;
  int? eventParticipant;
  String? image;
  List<EventGalleryImage>? imageGallery;
  String? createdById;
  String? createdAt;
  String? updatedAt;
  List<EventParticipants>? eventParticipants;
  bool? isMark;

  NearestEventsData({
    this.id,
    this.eventName,
    this.eventDescription,
    this.eventDateAndTime,
    this.eventAddress,
    this.eventStates,
    this.eventCity,
    this.eventCountry,
    this.eventParticipant,
    this.image,
    this.imageGallery,
    this.createdById,
    this.createdAt,
    this.updatedAt,
    this.eventParticipants,
    this.isMark,
  });

  NearestEventsData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    eventName = json['eventName'];
    eventDescription = json['eventDescription'];
    eventDateAndTime = json['eventDateAndTime'];
    eventAddress = json['eventAddress'];
    eventStates = json['eventStates'];
    eventCity = json['eventCity'];
    eventCountry = json['eventCountry'];
    eventParticipant = json['eventParticipant'];
    image = json['image']?.toString();
    if (json['imageGallery'] is List) {
      imageGallery = (json['imageGallery'] as List)
          .whereType<Map>()
          .map(
            (item) => EventGalleryImage.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .where((item) => item.url != null && item.url!.trim().isNotEmpty)
          .toList();
    }
    createdById = json['createdById'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    if (json['eventParticipants'] != null) {
      eventParticipants = <EventParticipants>[];
      json['eventParticipants'].forEach((v) {
        eventParticipants!.add(new EventParticipants.fromJson(v));
      });
    }
    isMark = json['isMark'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['eventName'] = this.eventName;
    data['eventDescription'] = this.eventDescription;
    data['eventDateAndTime'] = this.eventDateAndTime;
    data['eventAddress'] = this.eventAddress;
    data['eventStates'] = this.eventStates;
    data['eventCity'] = this.eventCity;
    data['eventCountry'] = this.eventCountry;
    data['eventParticipant'] = this.eventParticipant;
    data['image'] = this.image;
    if (this.imageGallery != null) {
      data['imageGallery'] = this.imageGallery!.map((v) => v.toJson()).toList();
    }
    data['createdById'] = this.createdById;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.eventParticipants != null) {
      data['eventParticipants'] = this.eventParticipants!
          .map((v) => v.toJson())
          .toList();
    }
    data['isMark'] = this.isMark;
    return data;
  }

  List<String> get galleryUrls {
    final urls =
        imageGallery
            ?.map((item) => item.url?.trim())
            .whereType<String>()
            .where((url) => url.isNotEmpty)
            .toList() ??
        <String>[];

    if (urls.isNotEmpty) return urls;

    final fallback = image?.trim();
    return fallback == null || fallback.isEmpty ? <String>[] : [fallback];
  }

  String? get primaryImageUrl {
    final urls = galleryUrls;
    return urls.isEmpty ? null : urls.first;
  }
}

class EventParticipants {
  bool? isMark;

  EventParticipants({this.isMark});

  EventParticipants.fromJson(Map<String, dynamic> json) {
    isMark = json['isMark'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isMark'] = this.isMark;
    return data;
  }
}
