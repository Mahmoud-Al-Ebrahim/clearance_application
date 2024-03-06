import 'dart:convert';

CheckAvailabilityModel checkAvailabilityModelFromJson(String str) => CheckAvailabilityModel.fromJson(json.decode(str));

String checkAvailabilityModelToJson(CheckAvailabilityModel data) => json.encode(data.toJson());

class CheckAvailabilityModel {
  CheckAvailabilityModel({
    this.message,
    this.data,
  });

  String ?message;
  List<CheckedProduct>? data;

  factory CheckAvailabilityModel.fromJson(Map<String, dynamic> json) => CheckAvailabilityModel(
    message: json["message"],
    data: List<CheckedProduct>.from(json["data"].map((x) => CheckedProduct.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class CheckedProduct {
  CheckedProduct({
    this.id,
    this.name,
    this.imageUrl,
    this.cause,
     this.cartPosition
  });

  int? id;
  String? name;
  String? imageUrl;
  String? cause;
  int? cartPosition;

  factory CheckedProduct.fromJson(Map<String, dynamic> json) => CheckedProduct(
    id: json["id"],
    cartPosition: json["cart_position"],
    name: json["name"],
    imageUrl: json["picture_url"],
    cause: json["cause"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "cart_position": cartPosition,
    "name": name,
    "picture_url": imageUrl,
    "cause": cause,
  };
}