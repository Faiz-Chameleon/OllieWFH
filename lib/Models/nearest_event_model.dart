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
