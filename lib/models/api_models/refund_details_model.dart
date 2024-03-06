// To parse this JSON data, do
//
//     final refundDetailsModel = refundDetailsModelFromJson(jsonString);

import 'dart:convert';

RefundDetailsModel refundDetailsModelFromJson(String str) => RefundDetailsModel.fromJson(json.decode(str));

String refundDetailsModelToJson(RefundDetailsModel data) => json.encode(data.toJson());

class RefundDetailsModel {
  RefundDetailsModel({
    this.message,
    this.data,
  });

  String? message;
  Data? data;

  factory RefundDetailsModel.fromJson(Map<String, dynamic> json) => RefundDetailsModel(
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
    this.quantity,
    this.productPrice,
    this.productPriceFormatted,
    this.productTotalDiscount,
    this.productTotalDiscountFormatted,
    this.productTotalTax,
    this.productTotalTaxFormatted,
    this.subtotal,
    this.subtotalFormatted,
    this.couponDiscount,
    this.couponDiscountFormatted,
    this.refundAmount,
    this.refundAmountFormatted,
    this.refundPaymentMethodStatus,
    this.refundRequest,
  });

  int? quantity;
  int? productPrice;
  String? productPriceFormatted;
  int? productTotalDiscount;
  String? productTotalDiscountFormatted;
  int? productTotalTax;
  String? productTotalTaxFormatted;
  int? subtotal;
  String? subtotalFormatted;
  int? couponDiscount;
  String? couponDiscountFormatted;
  int? refundAmount;
  String? refundAmountFormatted;
  String? refundPaymentMethodStatus;
  RefundRequest? refundRequest;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    quantity: json["quantity"],
    productPrice: json["product_price"],
    productPriceFormatted: json["product_price_formatted"],
    productTotalDiscount: json["product_total_discount"],
    productTotalDiscountFormatted: json["product_total_discount_formatted"],
    productTotalTax: json["product_total_tax"],
    productTotalTaxFormatted: json["product_total_tax_formatted"],
    subtotal: json["subtotal"],
    subtotalFormatted: json["subtotal_formatted"],
    couponDiscount: json["coupon_discount"],
    couponDiscountFormatted: json["coupon_discount_formatted"],
    refundAmount: json["refund_amount"],
    refundAmountFormatted: json["refund_amount_formatted"],
    refundPaymentMethodStatus: json["refund_payment_method_status"],
    refundRequest: json["refund_request"] == null ? null : RefundRequest.fromJson(json["refund_request"]),
  );

  Map<String, dynamic> toJson() => {
    "quantity": quantity,
    "product_price": productPrice,
    "product_price_formatted": productPriceFormatted,
    "product_total_discount": productTotalDiscount,
    "product_total_discount_formatted": productTotalDiscountFormatted,
    "product_total_tax": productTotalTax,
    "product_total_tax_formatted": productTotalTaxFormatted,
    "subtotal": subtotal,
    "subtotal_formatted": subtotalFormatted,
    "coupon_discount": couponDiscount,
    "coupon_discount_formatted": couponDiscountFormatted,
    "refund_amount": refundAmount,
    "refund_amount_formatted": refundAmountFormatted,
    "refund_payment_method_status": refundPaymentMethodStatus,
    "refund_request": refundRequest == null ? null : refundRequest!.toJson(),
  };
}

class RefundRequest {
  RefundRequest({
    this.id,
    this.orderDetailsId,
    this.customerId,
    this.status,
    this.amount,
    this.productId,
    this.orderId,
    this.refundReason,
    this.paymentMethodCustomer,
    this.images,
    this.createdAt,
    this.updatedAt,
    this.approvedNote,
    this.rejectedNote,
    this.resolvedNote,
    this.refusedNote,
    this.paymentInfo,
    this.changeBy,
    this.walletTransactionId,
    this.approvedShippingType,
    this.approvedDeliveryType,
    this.approvedDeliveryServiceName,
    this.approvedThirdPartyDeliveryTrackingId,
    this.rejectedShippingType,
    this.rejectedDeliveryType,
    this.rejectedDeliveryServiceName,
    this.rejectedThirdPartyDeliveryTrackingId,
    this.refundedLocation,
    this.refundTransaction,
    this.walletTransaction,
  });

  int? id;
  int? orderDetailsId;
  int? customerId;
  String? status;
  double? amount;
  int? productId;
  int? orderId;
  String? refundReason;
  String? paymentMethodCustomer;
  List<String>? images;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? approvedNote;
  dynamic rejectedNote;
  dynamic resolvedNote;
  dynamic refusedNote;
  String? paymentInfo;
  String? changeBy;
  int? walletTransactionId;
  dynamic approvedShippingType;
  dynamic approvedDeliveryType;
  String? approvedDeliveryServiceName;
  String? approvedThirdPartyDeliveryTrackingId;
  dynamic rejectedShippingType;
  dynamic rejectedDeliveryType;
  dynamic rejectedDeliveryServiceName;
  dynamic rejectedThirdPartyDeliveryTrackingId;
  String? refundedLocation;
  RefundTransaction? refundTransaction;
  WalletTransaction? walletTransaction;

  factory RefundRequest.fromJson(Map<String, dynamic> json) => RefundRequest(
    id: json["id"],
    orderDetailsId: json["order_details_id"],
    customerId: json["customer_id"],
    status: json["status"],
    amount: json["amount"]?.toDouble(),
    productId: json["product_id"],
    orderId: json["order_id"],
    refundReason: json["refund_reason"],
    paymentMethodCustomer: json["payment_method_customer"],
    images: json["images"] == null ? [] : List<String>.from(json["images"]!.map((x) => x)),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    approvedNote: json["approved_note"],
    rejectedNote: json["rejected_note"],
    resolvedNote: json["resolved_note"],
    refusedNote: json["refused_note"],
    paymentInfo: json["payment_info"],
    changeBy: json["change_by"],
    walletTransactionId: json["wallet_transaction_id"],
    approvedShippingType: json["approved_shipping_type"],
    approvedDeliveryType: json["approved_delivery_type"],
    approvedDeliveryServiceName: json["approved_delivery_service_name"],
    approvedThirdPartyDeliveryTrackingId: json["approved_third_party_delivery_tracking_id"],
    rejectedShippingType: json["rejected_shipping_type"],
    rejectedDeliveryType: json["rejected_delivery_type"],
    rejectedDeliveryServiceName: json["rejected_delivery_service_name"],
    rejectedThirdPartyDeliveryTrackingId: json["rejected_third_party_delivery_tracking_id"],
    refundedLocation: json["refunded_location"],
    refundTransaction: json["refund_transaction"] == null ? null : RefundTransaction.fromJson(json["refund_transaction"]),
    walletTransaction: json["wallet_transaction"] == null ? null : WalletTransaction.fromJson(json["wallet_transaction"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_details_id": orderDetailsId,
    "customer_id": customerId,
    "status": status,
    "amount": amount,
    "product_id": productId,
    "order_id": orderId,
    "refund_reason": refundReason,
    "payment_method_customer": paymentMethodCustomer,
    "images": images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "approved_note": approvedNote,
    "rejected_note": rejectedNote,
    "resolved_note": resolvedNote,
    "refused_note": refusedNote,
    "payment_info": paymentInfo,
    "change_by": changeBy,
    "wallet_transaction_id": walletTransactionId,
    "approved_shipping_type": approvedShippingType,
    "approved_delivery_type": approvedDeliveryType,
    "approved_delivery_service_name": approvedDeliveryServiceName,
    "approved_third_party_delivery_tracking_id": approvedThirdPartyDeliveryTrackingId,
    "rejected_shipping_type": rejectedShippingType,
    "rejected_delivery_type": rejectedDeliveryType,
    "rejected_delivery_service_name": rejectedDeliveryServiceName,
    "rejected_third_party_delivery_tracking_id": rejectedThirdPartyDeliveryTrackingId,
    "refunded_location": refundedLocation,
    "refund_transaction": refundTransaction?.toJson(),
    "wallet_transaction": walletTransaction?.toJson(),
  };
}

class RefundTransaction {
  RefundTransaction({
    this.id,
    this.orderId,
    this.paymentFor,
    this.payerId,
    this.paymentReceiverId,
    this.paidBy,
    this.paidTo,
    this.paymentMethod,
    this.paymentStatus,
    this.amount,
    this.transactionType,
    this.orderDetailsId,
    this.createdAt,
    this.updatedAt,
    this.refundId,
  });

  int? id;
  int? orderId;
  String? paymentFor;
  int? payerId;
  int? paymentReceiverId;
  String? paidBy;
  String? paidTo;
  String? paymentMethod;
  String? paymentStatus;
  double? amount;
  String? transactionType;
  int? orderDetailsId;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? refundId;

  factory RefundTransaction.fromJson(Map<String, dynamic> json) => RefundTransaction(
    id: json["id"],
    orderId: json["order_id"],
    paymentFor: json["payment_for"],
    payerId: json["payer_id"],
    paymentReceiverId: json["payment_receiver_id"],
    paidBy: json["paid_by"],
    paidTo: json["paid_to"],
    paymentMethod: json["payment_method"],
    paymentStatus: json["payment_status"],
    amount: json["amount"]?.toDouble(),
    transactionType: json["transaction_type"],
    orderDetailsId: json["order_details_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    refundId: json["refund_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "payment_for": paymentFor,
    "payer_id": payerId,
    "payment_receiver_id": paymentReceiverId,
    "paid_by": paidBy,
    "paid_to": paidTo,
    "payment_method": paymentMethod,
    "payment_status": paymentStatus,
    "amount": amount,
    "transaction_type": transactionType,
    "order_details_id": orderDetailsId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "refund_id": refundId,
  };
}

class WalletTransaction {
  WalletTransaction({
    this.id,
    this.userId,
    this.orderId,
    this.transactionId,
    this.credit,
    this.debit,
    this.adminBonus,
    this.balance,
    this.transactionType,
    this.reference,
    this.paymentMethodCustomer,
    this.returnedToCreditCart,
    this.createdAt,
    this.updatedAt,
  });

  int? id;
  int? userId;
  int? orderId;
  int? transactionId;
  double? credit;
  int? debit;
  int? adminBonus;
  double? balance;
  String? transactionType;
  String? reference;
  String? paymentMethodCustomer;
  int? returnedToCreditCart;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) => WalletTransaction(
    id: json["id"],
    userId: json["user_id"],
    orderId: json["order_id"],
    transactionId: json["transaction_id"],
    credit: json["credit"]?.toDouble(),
    debit: json["debit"],
    adminBonus: json["admin_bonus"],
    balance: json["balance"]?.toDouble(),
    transactionType: json["transaction_type"],
    reference: json["reference"],
    paymentMethodCustomer: json["payment_method_customer"],
    returnedToCreditCart: json["returned_to_credit_cart"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "order_id": orderId,
    "transaction_id": transactionId,
    "credit": credit,
    "debit": debit,
    "admin_bonus": adminBonus,
    "balance": balance,
    "transaction_type": transactionType,
    "reference": reference,
    "payment_method_customer": paymentMethodCustomer,
    "returned_to_credit_cart": returnedToCreditCart,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
