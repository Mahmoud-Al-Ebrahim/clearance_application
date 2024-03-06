// To parse this JSON data, do
//
//     final bannersModel = bannersModelFromJson(jsonString);

import 'dart:convert';

TransactionData bannersModelFromJson(String str) => TransactionData.fromJson(json.decode(str));

String bannersModelToJson(TransactionData data) => json.encode(data.toJson());

class LinkTransactionModel {
  LinkTransactionModel({
    this.message,
    this.data,
  });

  String? message;
  TransactionData? data;

  factory LinkTransactionModel.fromJson(Map<String, dynamic> json) => LinkTransactionModel(
    message: json["message"],
    data: TransactionData.fromJson(json["data"][0])
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data?.toJson(),
  };
}

class TransactionData {
  TransactionData({
    this.title,
    this.photo,
    this.bannerType,
    this.url,
    this.resourceType,
    this.resourceId,
    this.searchKeyword,
  });

  String? title;
  String? photo;
  String? bannerType;
  String? url;
  String? resourceType;
  int? resourceId;
  String? searchKeyword;

  factory TransactionData.fromJson(Map<String, dynamic> json) => TransactionData(
    title: json["title"],
    photo: json["photo"],
    bannerType: json["banner_type"],
    url: json["url"],
    resourceType: json["resource_type"],
    resourceId: json["resource_id"],
    searchKeyword: json["search_keyword"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "photo": photo,
    "banner_type": bannerType,
    "url": url,
    "resource_type": resourceType,
    "resource_id": resourceId,
    "search-keyword": searchKeyword,
  };
}
