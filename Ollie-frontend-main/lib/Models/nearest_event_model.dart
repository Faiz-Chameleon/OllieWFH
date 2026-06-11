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
        data!.add(NearestEventsData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
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
    image = json['image'];
    createdById = json['createdById'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    if (json['eventParticipants'] != null) {
      eventParticipants = <EventParticipants>[];
      json['eventParticipants'].forEach((v) {
        eventParticipants!.add(EventParticipants.fromJson(v));
      });
    }
    isMark = json['isMark'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['eventName'] = eventName;
    data['eventDescription'] = eventDescription;
    data['eventDateAndTime'] = eventDateAndTime;
    data['eventAddress'] = eventAddress;
    data['eventStates'] = eventStates;
    data['eventCity'] = eventCity;
    data['eventCountry'] = eventCountry;
    data['eventParticipant'] = eventParticipant;
    data['image'] = image;
    data['createdById'] = createdById;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    if (eventParticipants != null) {
      data['eventParticipants'] = eventParticipants!
          .map((v) => v.toJson())
          .toList();
    }
    data['isMark'] = isMark;
    return data;
  }
}

class EventParticipants {
  bool? isMark;

  EventParticipants({this.isMark});

  EventParticipants.fromJson(Map<String, dynamic> json) {
    isMark = json['isMark'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isMark'] = isMark;
    return data;
  }
}
