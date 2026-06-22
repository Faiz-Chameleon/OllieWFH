// ignore_for_file: prefer_collection_literals, unnecessary_this, unnecessary_new

class LatesEventModel {
  bool? success;
  String? message;
  LatestEventsData? data;

  LatesEventModel({this.success, this.message, this.data});

  LatesEventModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null
        ? new LatestEventsData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class LatestEventsData {
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
  bool? isMark;

  LatestEventsData({
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
    this.isMark,
  });

  LatestEventsData.fromJson(Map<String, dynamic> json) {
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

class EventGalleryImage {
  String? url;
  String? type;

  EventGalleryImage({this.url, this.type});

  EventGalleryImage.fromJson(Map<String, dynamic> json) {
    url = json['url']?.toString();
    type = json['type']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['url'] = this.url;
    data['type'] = this.type;
    return data;
  }
}
