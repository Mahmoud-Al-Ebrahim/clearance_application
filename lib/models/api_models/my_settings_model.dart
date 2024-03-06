// To parse this JSON data, do
//
//     final mySettingsModel = mySettingsModelFromJson(jsonString);

import 'dart:convert';

MySettingsModel mySettingsModelFromJson(String str) => MySettingsModel.fromJson(json.decode(str));

String mySettingsModelToJson(MySettingsModel data) => json.encode(data.toJson());

class MySettingsModel {
  MySettingsModel({
    this.message,
    this.data,
  });

  String? message;
  Data? data;

  factory MySettingsModel.fromJson(Map<String, dynamic> json) => MySettingsModel(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  Data({
    this.isStopWhatsappMessages,
  });

  String? isStopWhatsappMessages;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    isStopWhatsappMessages: json["is_stop_whatsapp_messages"],
  );

  Map<String, dynamic> toJson() => {
    "is_stop_whatsapp_messages": isStopWhatsappMessages,
  };
}
