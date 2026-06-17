class SupplementModel {
  final bool? success;
  final String? message;
  final List<SupplementData> data;

  SupplementModel({this.success, this.message, required this.data});

  factory SupplementModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final rawList = rawData is List
        ? rawData
        : rawData is Map && rawData['supplements'] is List
        ? rawData['supplements'] as List
        : const [];

    return SupplementModel(
      success: json['success'],
      message: json['message']?.toString(),
      data: rawList
          .whereType<Map>()
          .map(
            (item) => SupplementData.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList(),
    );
  }
}

class SupplementData {
  final String? id;
  final String? name;
  final String? dosage;
  final bool reminderEnabled;
  final String? reminderTime;

  SupplementData({
    this.id,
    this.name,
    this.dosage,
    this.reminderEnabled = false,
    this.reminderTime,
  });

  factory SupplementData.fromJson(Map<String, dynamic> json) {
    return SupplementData(
      id:
          json['id']?.toString() ??
          json['_id']?.toString() ??
          json['supplementId']?.toString(),
      name: json['name']?.toString(),
      dosage: json['dosage']?.toString(),
      reminderEnabled: json['reminderEnabled'] == true,
      reminderTime: json['reminderTime']?.toString(),
    );
  }
}
