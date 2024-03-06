// To parse this JSON data, do
//
//     final returnRequestDisplayDataModel = returnRequestDisplayDataModelFromJson(jsonString);

import 'dart:convert';

ReturnRequestDisplayDataModel returnRequestDisplayDataModelFromJson(String str) => ReturnRequestDisplayDataModel.fromJson(json.decode(str));

String returnRequestDisplayDataModelToJson(ReturnRequestDisplayDataModel data) => json.encode(data.toJson());

class ReturnRequestDisplayDataModel {
  String? message;
  Data? data;

  ReturnRequestDisplayDataModel({
    this.message,
    this.data,
  });

  factory ReturnRequestDisplayDataModel.fromJson(Map<String, dynamic> json) => ReturnRequestDisplayDataModel(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  int? orderId;
  int? returnRequestId;
  String? status;
  double? totalReturnableAmount;
  String? totalReturnableAmountFormatted;
  int? customerReturnRequestDestinationId;
  int? adminReturnRequestDestinationId;
  String? deliveryServiceName;
  String? trackingId;
  DateTime? createdAt;
  List<ProductsReturned>? productsReturned;

  Data({
    this.orderId,
    this.returnRequestId,
    this.status,
    this.totalReturnableAmount,
    this.totalReturnableAmountFormatted,
    this.customerReturnRequestDestinationId,
    this.adminReturnRequestDestinationId,
    this.deliveryServiceName,
    this.trackingId,
    this.createdAt,
    this.productsReturned,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    orderId: json["order_id"],
    returnRequestId: json["return_request_id"],
    status: json["status"],
    totalReturnableAmount: json["total_returnable_amount"]?.toDouble(),
    totalReturnableAmountFormatted: json["total_returnable_amount_formatted"],
    customerReturnRequestDestinationId: json["customer_return_request_destination_id"],
    adminReturnRequestDestinationId: json["admin_return_request_destination_id"],
    deliveryServiceName: json["delivery_service_name"],
    trackingId: json["tracking_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    productsReturned: json["products_returned"] == null ? [] : List<ProductsReturned>.from(json["products_returned"]!.map((x) => ProductsReturned.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "order_id": orderId,
    "return_request_id": returnRequestId,
    "status": status,
    "total_returnable_amount": totalReturnableAmount,
    "total_returnable_amount_formatted": totalReturnableAmountFormatted,
    "customer_return_request_destination_id": customerReturnRequestDestinationId,
    "admin_return_request_destination_id": adminReturnRequestDestinationId,
    "delivery_service_name": deliveryServiceName,
    "tracking_id": trackingId,
    "created_at": createdAt?.toIso8601String(),
    "products_returned": productsReturned == null ? [] : List<dynamic>.from(productsReturned!.map((x) => x.toJson())),
  };
}

class ProductsReturned {
  String? productName;
  String? productImageUrl;
  String? productVariant;
  int? quantity;
  String? status;
  double? returnableAmount;
  String? returnableAmountFormatted;
  int? reasonId;
  String? details;
  List<String>? imagesUrl;

  ProductsReturned({
    this.productName,
    this.productImageUrl,
    this.productVariant,
    this.quantity,
    this.status,
    this.returnableAmount,
    this.returnableAmountFormatted,
    this.reasonId,
    this.details,
    this.imagesUrl,
  });

  factory ProductsReturned.fromJson(Map<String, dynamic> json) => ProductsReturned(
    productName: json["product_name"],
    productImageUrl: json["product_image_url"],
    productVariant: json["product_variant"],
    quantity: json["quantity"],
    status: json["status"],
    returnableAmount: json["returnable_amount"]?.toDouble(),
    returnableAmountFormatted: json["returnable_amount_formatted"],
    reasonId: json["reason_id"],
    details: json["details"],
    imagesUrl: json["images_url"] == null ? [] : List<String>.from(json["images_url"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "product_name": productName,
    "product_image_url": productImageUrl,
    "product_variant": productVariant,
    "quantity": quantity,
    "status": status,
    "returnable_amount": returnableAmount,
    "returnable_amount_formatted": returnableAmountFormatted,
    "reason_id": reasonId,
    "details": details,
    "images_url": imagesUrl == null ? [] : List<dynamic>.from(imagesUrl!.map((x) => x)),
  };
}
