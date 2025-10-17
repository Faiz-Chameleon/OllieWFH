class AssistanceReasonsModel {
  bool? success;
  String? message;
  List<AssistanceReasonsData>? data;

  AssistanceReasonsModel({this.success, this.message, this.data});

  AssistanceReasonsModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <AssistanceReasonsData>[];
      json['data'].forEach((v) {
        data!.add(new AssistanceReasonsData.fromJson(v));
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

class AssistanceReasonsData {
  String? id;
  String? name;
  String? adminId;

  AssistanceReasonsData({this.id, this.name, this.adminId});

  AssistanceReasonsData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    adminId = json['adminId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['adminId'] = this.adminId;
    return data;
  }
}
