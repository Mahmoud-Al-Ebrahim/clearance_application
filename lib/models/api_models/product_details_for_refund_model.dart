// To parse this JSON data, do
//
//     final orderDetailsForRefundModel = orderDetailsForRefundModelFromJson(jsonString);

import 'dart:convert';

OrderDetailsForRefundModel orderDetailsForRefundModelFromJson(String str) => OrderDetailsForRefundModel.fromJson(json.decode(str));

String orderDetailsForRefundModelToJson(OrderDetailsForRefundModel data) => json.encode(data.toJson());

class OrderDetailsForRefundModel {
  String? message;
  Data? data;

  OrderDetailsForRefundModel({
    this.message,
    this.data,
  });

  factory OrderDetailsForRefundModel.fromJson(Map<String, dynamic> json) => OrderDetailsForRefundModel(
    message: json["message"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  List<Refund>? refunds;
  double? totalRefundableAmount;
  String? totalRefundableAmountFormatted;
  int? returnRequestDestinationId;
  Data({
    this.refunds,
    this.totalRefundableAmount,
    this.totalRefundableAmountFormatted,
    this.returnRequestDestinationId
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    refunds: json["order_details"] == null ? [] : List<Refund>.from(json["order_details"]!.map((x) => Refund.fromJson(x))),
      totalRefundableAmount:json["total_returnable_amount"]?.toDouble(),
      totalRefundableAmountFormatted:json["total_returnable_amount_formatted"],
      returnRequestDestinationId: json["return_request_destination_id"]
  );

  Map<String, dynamic> toJson() => {
    "order_details": refunds == null ? [] : List<dynamic>.from(refunds!.map((x) => x.toJson())),
  };
}

class Refund {
  int? detailId;
  int? productId;
  int? returnRequestId;
  int? quantity;
  String? imageUrl;
  String? name;
  String? variant;
  double? productPrice;
  String? productPriceFormatted;
  double? subtotal;
  String? subtotalFormatted;
  bool? alreadyReturn;
  int? returnRequestProductQuantity;
  int? returnRequestProductId;
  int? returnRequestProductReasonId;
  String? returnRequestProductDetails;
  List<String>? imagesUrl;
  List<String>? img;

  Refund({
    this.detailId,
    this.productId,
    this.returnRequestId,
    this.quantity,
    this.imageUrl,
    this.name,
    this.variant,
    this.productPrice,
    this.productPriceFormatted,
    this.subtotal,
    this.subtotalFormatted,
    this.alreadyReturn,
    this.returnRequestProductQuantity,
    this.returnRequestProductReasonId,
    this.returnRequestProductDetails,
    this.returnRequestProductId,
    this.imagesUrl,
    this.img,
  });

  factory Refund.fromJson(Map<String, dynamic> json) => Refund(
    detailId: json["detail_id"],
    productId: json["product_id"],
    returnRequestId: json["return_request_id"],
    quantity: json["quantity"],
    imageUrl: json["image_url"],
    name: json["name"],
    variant: json["variant"],
    productPrice: json["product_price"]?.toDouble(),
    productPriceFormatted: json["product_price_formatted"],
    returnRequestProductId: json["return_request_product_id"],
    subtotal: json["subtotal"]?.toDouble(),
    subtotalFormatted: json["subtotal_formatted"],
    alreadyReturn: json["already_return"],
    returnRequestProductQuantity: json["return_request_product_quantity"],
    returnRequestProductReasonId: json["return_request_product_reason_id"],
    returnRequestProductDetails: json["return_request_product_details"],
    imagesUrl: json["images_url"] == null ? [] : List<String>.from(json["images_url"]!.map((x) => x)),
    img: json["img"] == null ? [] : List<String>.from(json["img"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "detail_id": detailId,
    "product_id": productId,
    "return_request_id": returnRequestId,
    "quantity": quantity,
    "image_url": imageUrl,
    "name": name,
    "variant": variant,
    "product_price": productPrice,
    "product_price_formatted": productPriceFormatted,
    "subtotal": subtotal,
    "subtotal_formatted": subtotalFormatted,
    "already_return": alreadyReturn,
    "return_request_product_quantity": returnRequestProductQuantity,
    "return_request_product_reason_id": returnRequestProductReasonId,
    "return_request_product_details": returnRequestProductDetails,
    "images_url": imagesUrl == null ? [] : List<dynamic>.from(imagesUrl!.map((x) => x)),
    "img": img == null ? [] : List<dynamic>.from(img!.map((x) => x)),
  };
}
