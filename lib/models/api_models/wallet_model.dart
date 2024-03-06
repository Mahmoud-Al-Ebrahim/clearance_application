// To parse this JSON data, do
//
//     final walletModel = walletModelFromJson(jsonString);

import 'dart:convert';

WalletModel walletModelFromJson(String str) => WalletModel.fromJson(json.decode(str));

String walletModelToJson(WalletModel data) => json.encode(data.toJson());

class WalletModel {
  WalletModel({
    this.limit,
    this.offset,
    this.totalWalletBalance,
    this.totalWalletBalanceFormatted,
    this.totalWalletTransaction,
    this.walletTransactionList,
  });

  int? limit;
  int? offset;
  double? totalWalletBalance;
  String? totalWalletBalanceFormatted;
  int? totalWalletTransaction;
  List<WalletTransactionList>? walletTransactionList;

  factory WalletModel.fromJson(Map<String, dynamic> json) => WalletModel(
    limit: json["limit"],
    offset: json["offset"],
    totalWalletBalance: json["total_wallet_balance"]?.toDouble(),
    totalWalletBalanceFormatted: json["total_wallet_balance_formatted"],
    totalWalletTransaction: json["total_wallet_transaction"],
    walletTransactionList: json["wallet_transaction_list"] == null ? [] : List<WalletTransactionList>.from(json["wallet_transaction_list"]!.map((x) => WalletTransactionList.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "limit": limit,
    "offset": offset,
    "total_wallet_balance": totalWalletBalance,
    "total_wallet_balance_formatted": totalWalletBalanceFormatted,
    "total_wallet_transaction": totalWalletTransaction,
    "wallet_transaction_list": walletTransactionList == null ? [] : List<dynamic>.from(walletTransactionList!.map((x) => x.toJson())),
  };
}

class WalletTransactionList {
  WalletTransactionList({
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
    this.statusPayment,
    this.creditFormatted,
    this.debitFormatted,
    this.balanceFormatted,
  });

  int? id;
  int? userId;
  dynamic orderId;
  int? transactionId;
  double? credit;
  double? debit;
  double? adminBonus;
  double? balance;
  String? transactionType;
  String? reference;
  dynamic paymentMethodCustomer;
  double? returnedToCreditCart;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? statusPayment;
  String? creditFormatted;
  String? debitFormatted;
  String? balanceFormatted;

  factory WalletTransactionList.fromJson(Map<String, dynamic> json) => WalletTransactionList(
    id: json["id"],
    userId: json["user_id"],
    orderId: json["order_id"],
    transactionId: json["transaction_id"],
    credit: json["credit"]?.toDouble(),
    debit: json["debit"].toDouble(),
    adminBonus: json["admin_bonus"].toDouble(),
    balance: json["balance"]?.toDouble(),
    transactionType: json["transaction_type"],
    reference: json["reference"],
    paymentMethodCustomer: json["payment_method_customer"],
    returnedToCreditCart: json["returned_to_credit_cart"].toDouble(),
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    statusPayment: json["status_payment"],
    creditFormatted: json["credit_formatted"],
    debitFormatted: json["debit_formatted"],
    balanceFormatted: json["balance_formatted"],
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
    "status_payment": statusPayment,
    "credit_formatted": creditFormatted,
    "debit_formatted": debitFormatted,
    "balance_formatted": balanceFormatted,
  };
}
