class AssistanceAttachment {
  String? url;
  String? type;

  AssistanceAttachment({this.url, this.type});

  AssistanceAttachment.fromJson(Map<String, dynamic> json) {
    url = json['url']?.toString();
    type = json['type']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {'url': url, 'type': type};
  }
}
