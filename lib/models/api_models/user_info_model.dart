import 'dart:convert';

UserInfoModel userInfoModelFromJson(String str) => UserInfoModel.fromJson(json.decode(str));

String userInfoModelToJson(UserInfoModel data) => json.encode(data.toJson());

class UserInfoModel {
  UserInfoModel({
    this.message,
    this.data,
  });

  String ?message;
  User? data;

  factory UserInfoModel.fromJson(Map<String, dynamic> json) => UserInfoModel(
    message: json["message"],
    data: User.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data!.toJson(),
  };
}

class User {
  User({
    this.id,
    this.name,
    this.fName,
    this.lName,
    this.email,
    this.phone,
    this.isVerifiedPhone,
    this.isVerifiedEmail,
    this.dialCode,
    this.image,
    required this.canInviteFriends,
  });

  int? id;
  String? name;
  String ?fName;
  String? lName;
  String? email;
  String? phone;
  int? isVerifiedPhone;
  int? isVerifiedEmail;
  String? dialCode;
  String? image;
  bool canInviteFriends;
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    name: json["name"],
    fName: json["f_name"],
    lName: json["l_name"],
    email: json["email"],
    dialCode: json["country_dial_code"],
    isVerifiedPhone: json["is_phone_verified"],
    canInviteFriends: json.containsKey('can_invite_friends') ?  json["can_invite_friends"] : true,
    isVerifiedEmail: json["is_email_verified"],
    phone:json["phone"]!= null ?json["phone"][0]=='+' ?json["phone"]:('+'+json["phone"]):null,
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "f_name": fName,
    "l_name": lName,
    "country_dial_code": dialCode,
    "is_phone_verified": isVerifiedPhone,
    "is_email_verified" : isVerifiedEmail,
    "can_invite_friends" : canInviteFriends,
    "phone": phone,
    "email": email,
    "image": image,
  };
}