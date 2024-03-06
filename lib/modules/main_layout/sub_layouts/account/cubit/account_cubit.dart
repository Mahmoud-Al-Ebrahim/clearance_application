import 'dart:io';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:clearance/models/api_models/my_settings_model.dart';
import 'package:clearance/models/api_models/payment_destinations_model.dart';
import 'package:clearance/models/api_models/refund_details_model.dart';
import 'package:clearance/models/api_models/refund_reasons_model.dart';
import 'package:clearance/models/api_models/return_request_display_data_model.dart';
import 'package:clearance/modules/auth_screens/cubit/cubit_auth.dart';
import 'package:clearance/modules/main_layout/sub_layouts/cart/cubit/cart_cubit.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime_type/mime_type.dart';
import 'package:clearance/core/main_cubits/cubit_main.dart';
import 'package:clearance/models/api_models/home_Section_model.dart';
import 'package:clearance/models/api_models/wish_list.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../../../../core/cache/cache.dart';
import '../../../../../core/constants/networkConstants.dart';
import '../../../../../core/main_functions/main_funcs.dart';
import '../../../../../core/network/dio_helper.dart';
import '../../../../../models/api_models/contact_us_model.dart';
import '../../../../../models/api_models/orders-model.dart';
import '../../../../../models/api_models/product_details_for_refund_model.dart';
import '../../../../../models/api_models/wallet_model.dart';
import '../../../../auth_screens/cubit/states_auth.dart';
import 'account_state.dart';

class AccountCubit extends Cubit<AccountStates> {
  AccountCubit() : super(AccountInitial());

  static AccountCubit get(context) => BlocProvider.of(context);

  WishList? wishListModel;
  String addressType = 'home';
  int addressIdForPayment = 0;
  String currentOrderDetailsViewId = '0';
  String phoneNum = '55';
  String currentEvaluatingProductId = '0';
  double currentRating = 3.0;
  List<Product>? wishListProducts;
  OrdersModel? ordersModel;
  List<OrderItemModel>? orders;
  List<OrderItemModel>? currentOrderList;
  ContactUsModel? contactUsModel;
  bool isLocationSelected = false;
  bool cancellingOrder = false;
  int currentProductToChangeQuantity = -1;
  bool displayMyOrder = false;
  OrderDetailsForRefundModel? orderDetailsForRefundModel;
  ReturnRequestDisplayDataModel? returnRequestDisplayDataModel;
  RefundDetailsModel? refundDetailsModel;
  Map<String, int> currentImageToUpload = {};
  Map<String, List<String>> imagesForRefund = {};
  bool enableChooseImages = true;
  bool enableRequestRefund = true;
  WalletModel? walletModel;
  List<WalletTransactionList> walletTransactions = [];
  int walletOffset = 0;
  PaymentDestinationsModel? paymentDestinationsModel;
  RefundReasonsModel? refundReasonsModel;
  MySettingsModel? mySettingsModel;
  Map<String, String> returnRequestsIds = {};
  String currentKeyToWork = "";

  void getRefundReasons() async {
    emit(GetRefundReasonsLoadingState());

    await MainDioHelper.getData(
            url: getRefundReasonsEP, token: getCachedToken())
        .then((value) {
      logg('refund reasons got');
      refundReasonsModel = RefundReasonsModel.fromJson(value.data);
      emit(GetRefundReasonsSuccessState());
    }).catchError((error) {
      logg('refund reasons an error occurred');
      logg(error.toString());
      emit(GetRefundReasonsFailureState());
    });
  }

  void getPaymentDestinations() async {
    emit(GetPaymentDestinationsLoadingState());

    await MainDioHelper.getData(
            url: getPaymentDestinationsEP, token: getCachedToken())
        .then((value) {
      logg('payment destinations got');
      paymentDestinationsModel = PaymentDestinationsModel.fromJson(value.data);
      emit(GetPaymentDestinationsSuccessState());
    }).catchError((error) {
      logg('payment destinations an error occurred');
      logg(error.toString());
      emit(GetPaymentDestinationsFailureState());
    });
  }

  removePic(int index) {
    emit(SuccessPickedFiles());
  }

  void initReturnRequest() {
    enableChooseImages = true;
    imagesForRefund = {};
    enableRequestRefund = true;
    currentImageToUpload = {};
  }

  openImages() async {}

  void resetSelectedImages() {}

  void setCurrentEvaluatingProductId(String newCurrentEvaluatingProductId) {
    currentEvaluatingProductId = newCurrentEvaluatingProductId;
    logg('updated currentEvaluatingProductId: ' + currentEvaluatingProductId);
  }

  Future<void> removeFromFav(String itemId) async {
    emit(LoadingWishListDataState());
    await MainDioHelper.postData(
        url: removeProductFromWishListEnd,
        token: getCachedToken(),
        data: {
          'product_id': itemId,
        }).then((value) {
      getWishListProducts();

      emit(OrderCanceledSuccess());
    }).catchError((error) {
      logg('an error occurred');
      logg(error.toString());
    });
  }

  void setNewRating(double newRating) {
    currentRating = newRating;
    logg('updated newRating: ' + currentRating.toString());
  }

  void removePictureFromServer(int imageIndex, int productId,
      int returnRequestProductId, String image) async {
    emit(RemoveImageFromServerLoading());
    await MainDioHelper.getData(
            url: removeImageFromServerEP,
            query: {
              "return_request_product_id": returnRequestProductId,
              "image": image
            },
            token: getCachedToken())
        .then((value) {
      emit(RemoveImageFromServerSuccess(
          imageIndex: imageIndex, productId: productId));
    }).catchError((error) {
      emit(RemoveImageFromServerFailure());
    });
  }

  Future<void> sendAndSaveReview(String commentText) async {}

  Future<void> updateProfile(
      {required String code,
      required String dial,
      required String firstName,
      required String lastName,
      required String email,
      required String phoneNumber,
      required BuildContext context}) async {
    emit(LoadingState());
    logg(' Updating Profile ');
    await MainDioHelper.postData(
        url: updateProfileEP,
        token: getCachedToken(),
        data: {
          'f_name': firstName,
          'l_name': lastName,
          'email': email,
          'country_dial_code': dial,
          'phone': phoneNumber
        }).then((value) {
      logg('Profile updated');
      var authCubit = AuthCubit.get(context);
      authCubit.userInfoModel!.data!.fName = firstName;
      authCubit.userInfoModel!.data!.lName = lastName;
      authCubit.userInfoModel!.data!.email = email;
      authCubit.userInfoModel!.data!.phone = phoneNumber;
      saveCacheName(firstName);
      saveCacheEmail(email);
      saveCachePhoneDialCode(dial);
      saveCachePhoneCode(code);
      saveCachePhoneNumber(phoneNumber.substring(dial.length));
      MainCubit.get(context).getMainCacheUserData();
      emit(UpdateProfileSuccess());
      authCubit.emit(CheckingAuthStateDone());
    }).catchError((error) {
      logg(error.response.toString());
      emit(ErrorUpdateProfile(message: error.response.data['message']));
    });
  }

  Future<void> cancelOrder(String orderId, {bool? returnMoneyToCard}) async {
    emit(OrderCancelLoading(fromWallet: returnMoneyToCard ?? false));
    cancellingOrder = true;
    await MainDioHelper.postData(
        url: cancelOrderEnd,
        token: getCachedToken(),
        data: {
          'order_id': orderId,
          "return_money_to_card": returnMoneyToCard
        }).then((value) {
      cancellingOrder = false;
      logg('response value' + value.toString());
      getOrders().then((value) => applyOrdersListFilter('pending'));

      emit(OrderCanceledSuccess());
    }).catchError((error) {
      cancellingOrder = false;
      emit(OrderCanceledError());
      logg('an error occurred');
      logg(error.toString());
    });
  }

  void applyOrdersListFilter(String filter) {
    logg('applying filter: ' + filter);
    if (orders == null) {
      logg('getting orders in applyOrdersListFilter');
      getOrders().then((value) => currentOrderList =
          orders!.where((element) => element.orderStatus == filter).toList());
    } else {
      currentOrderList =
          orders!.where((element) => element.orderStatus == filter).toList();
    }

    logg(currentOrderList.toString());
    emit(FilterApplied());
  }

  void resetOrdersModel() {
    ordersModel = null;
  }

  void changeAddressType(String newAddressType) {
    if (newAddressType != addressType) {
      addressType = newAddressType;
      emit(AddressTypeChanged());
    }
  }

  void changeCurrentOrderDetailsViewId(String newCurrentOrderDetailsViewId) {
    currentOrderDetailsViewId = newCurrentOrderDetailsViewId;
    emit(AddressTypeChanged());
  }

  Future<void> getWishListProducts() async {
    emit(LoadingWishListDataState());

    await MainDioHelper.getData(url: getWishListEnd, token: getCachedToken())
        .then((value) {
      logg('WishList got');
      wishListModel = WishList.fromJson(value.data);
      wishListProducts = wishListModel!.data;

      emit(WishListDataSuccessState());
    }).catchError((error) {
      logg('an error occurred');
      logg(error.toString());
      emit(ErrorWishListDataState());
    });
  }

  Future<void> getOrders() async {
    emit(LoadingOrdersState());

    await MainDioHelper.getData(url: getOrdersList, token: getCachedToken())
        .then((value) {
      logg('ordersList got');
      logg(value.toString());
      ordersModel = OrdersModel.fromJson(value.data);

      orders = ordersModel!.data;

      emit(OrdersListSuccessState());
    }).catchError((error) {
      logg('an error occurred');
      logg(error.toString());
      emit(ErrorLoadingDataState(msg: error.toString()));
    });
  }

  void updatePhoneNum(PhoneNumber newVal) {
    phoneNum = newVal.toString();
    logg('phoneNum:' + phoneNum);
  }

  Future<void> addNewAddress({
    required BuildContext context,
    required String contactPersonNAme,
    required String address,
    required String address2,
    required String city,
    required String phone,
    required String email,
    required String state,
    required String country,
  }) async {
    emit(SavingAddressState());
    await MainDioHelper.postData(
        url: addAddressEnd,
        token: getCachedToken(),
        data: {
          'contact_person_name': contactPersonNAme,
          'address_type': addressType,
          'address': address,
          'city': city,
          'zip': '752',
          'phone': phone,
          'email': email,
          'state': state,
          'country': country,
          'is_billing': '0',
          'is_default': '1'
        }).then((value) async {
      logg(value.toString());
      addressIdForPayment = value.data['data']['id'];
      await MainCubit.get(context).getAddresses();
      CartCubit.get(context).getCartDetails(updateAllList: true);

      emit(AddingAddressSuccessState(msg: value.data['message'].toString()));
    }).catchError((error) {
      logg('an error occurred');
      logg(error.toString());
      emit(ErrorLoadingDataState(msg: error.toString()));
    });
  }

  void getContactUsInformation() async {
    emit(LoadingContactUsDataState());
    await MainDioHelper.getData(
            url: getContactUsInfoEP, token: getCachedToken())
        .then((value) {
      contactUsModel = ContactUsModel.fromJson(value.data);
      emit(SuccessContactUsDataState());
    }).catchError((error) {
      logg('error in contact us');
      logg(error.toString());
      emit(FailureContactUsDataState());
    });
  }

  void setProductNewQuantity(int orderId, int qty, int detailsId,
      {bool? returnMoneyToCard}) async {
    currentProductToChangeQuantity = detailsId;
    emit(ProductQuantityChanging());
    await MainDioHelper.postData(url: changeProductQuantityEP, data: {
      "order_id": orderId,
      "qty": qty,
      "return_money_to_card": returnMoneyToCard,
      "detail_id": detailsId,
    }).then((value) {
      bool isRemoved = false;
      orders = List.of(orders!.map((e) {
        if (e.id == orderId) {
          e.details!.firstWhere((element) => element.id == detailsId).qty = max(
              0,
              e.details!.firstWhere((element) => element.id == detailsId).qty! -
                  qty);
          if (e.details!.firstWhere((element) => element.id == detailsId).qty ==
              0) {
            isRemoved = true;
          }
        }
        return e;
      }));
      emit(ProductQuantityChanged(isProductRemoved: isRemoved));
    }).catchError((error) {
      emit(ProductQuantityChangingError());
    });
  }

  void getOrderInfoForRefund(int orderId) async {
    emit(GetProductInfoForRefundLoadingState());
    await MainDioHelper.getData(
            url: getOrderInfoForRefundEP,
            query: {"return_request_id": returnRequestsIds[orderId.toString()]})
        .then((value) {
      logg(value.data.toString());
      orderDetailsForRefundModel =
          OrderDetailsForRefundModel.fromJson(value.data);
      emit(GetProductInfoForRefundSuccessState());
    }).catchError((error) {
      emit(GetProductInfoForRefundErrorState());
    });
  }

  void getRefundDetails(int detailsId) async {
    emit(GetRefundDetailsLoadingState());
    await MainDioHelper.getData(
        url: getRefundDetailsEP,
        query: {"order_details_id": detailsId.toString()}).then((value) {
      refundDetailsModel = RefundDetailsModel.fromJson(value.data);
      emit(GetRefundDetailsSuccessState());
    }).catchError((error) {
      logg(error.toString());
      emit(GetRefundDetailsErrorState());
    });
  }

  void initialStoreRefundRequest(
      int orderId, int isForExchange, int isDraft) async {
    await MainDioHelper.getData(url: storeRefundRequestInfoEP, query: {
      "order_id": orderId.toString(),
      "is_for_exchange": isForExchange.toString(),
      "is_draft": isDraft.toString(),
    }).then((value) {
      returnRequestsIds[orderId.toString()] =
          value.data['data']['return_request_id'].toString();
      getOrderInfoForRefund(orderId);
    }).catchError((error) {
      emit(GetProductInfoForRefundErrorState());
    });
  }

  void storeRefundRequest(
    String key,
    int isForExchange,
    int orderId,
    int detailsId,
    Refund refund,
    Map<String, Reason?> refundReasons,
    Map<String, String?> refundReasonsDescription,
  ) async {
    emit(RefundRequestLoadingState());
    await MainDioHelper.postData(url: storeRefundRequestProductInfoEP, data: {
      "order_detail_id": detailsId.toString(),
      "product_id": key,
      "return_request_id": returnRequestsIds[orderId.toString()],
      "is_for_exchange": isForExchange,
      "quantity": refund.quantity,
      "return_request_reason_id": refundReasons[key]!.id,
      "details": refundReasonsDescription[key],
      "images": imagesForRefund[key]!.toList(),
    }).then((value) {
      logg(value.data.toString());
      emit(RefundRequestSuccessState(key: key));
      currentImageToUpload = {};
      imagesForRefund = {};
      enableChooseImages = true;
      currentKeyToWork = '';
      getOrderInfoForRefund(orderId);
      getOrders();
    }).catchError((error) {
      logg(error.toString());
      emit(RefundRequestErrorState());
    });
    enableRequestRefund = true;
  }

  void cancelProductReturnRequest(
      String key, int returnRequestProductId, int orderId, int index) {
    currentKeyToWork = key;
    enableRequestRefund = false;
    emit(RefundRequestCancelingLoadingState());
    MainDioHelper.getData(
        url: cancelRefundRequestProductInfoEP,
        token: getCachedToken(),
        query: {
          "return_request_product_id": returnRequestProductId.toString()
        }).then((value) {
      enableRequestRefund = true;
      emit(RefundRequestCancelingSuccessState(key: key, index: index));

      getOrderInfoForRefund(orderId);
      getOrders();
    }).catchError((error) {
      enableRequestRefund = true;
      logg(error.toString());
      emit(RefundRequestCancelingErrorState());
    });
  }

  void confirmReturnRequest(int orderId, int returnRequestDestinationId) {
    int? previousDestination =
        orderDetailsForRefundModel!.data!.returnRequestDestinationId;
    orderDetailsForRefundModel!.data!.returnRequestDestinationId =
        returnRequestDestinationId;
    emit(ConfirmReturnRequestLoading());
    MainDioHelper.postData(
        url: confirmReturnRequestProductEP,
        token: getCachedToken(),
        data: {
          "return_request_id": returnRequestsIds[orderId.toString()].toString(),
          "return_request_destination_id":
              returnRequestDestinationId.toString(),
        }).then((value) {
      orderDetailsForRefundModel!.data!.returnRequestDestinationId =
          returnRequestDestinationId;
      emit(ConfirmReturnRequestSuccess());
    }).catchError((error) {
      orderDetailsForRefundModel!.data!.returnRequestDestinationId =
          previousDestination;
      logg(error.response.toString());
      emit(ConfirmReturnRequestFailure());
    });
  }

  void cancelOrderReturnRequest(int? returnRequestId) async {
    emit(CancelOrderReturnRequestLoading());
    await MainDioHelper.getData(url: cancelOrderReturnRequestEP , token: getCachedToken() , query: {
      'return_request_id': returnRequestId.toString()
    })
        .then((value) {
      emit(CancelOrderReturnRequestSuccess());
      getOrders();
    })
        .catchError((error) {
      emit(CancelOrderReturnRequestFailure());

    });
  }
  void getReturnRequestDataForDisplay(String? returnRequestId) async {
    emit(GetOrderReturnRequestDataLoading());
    await MainDioHelper.getData(url: getReturnRequestDataForDisplayEP , token: getCachedToken() , query: {
      'return_request_id': returnRequestId.toString()
    })
        .then((value) {
      returnRequestDisplayDataModel=ReturnRequestDisplayDataModel.fromJson(value.data);
      emit(GetOrderReturnRequestDataSuccess());
      getOrders();
    })
        .catchError((error) {
      emit(GetOrderReturnRequestDataFailure());

    });
  }

  void updateProductReturnRequest(
    String key,
    int orderId,
    Refund refund,
    Map<String, Reason?> refundReasons,
    Map<String, String?> refundReasonsDescription,
  ) {
    currentKeyToWork = key;
    enableRequestRefund = false;
    emit(RefundRequestUpdatingLoadingState());
    MainDioHelper.postData(
        url: updateRefundRequestProductInfoEP,
        token: getCachedToken(),
        data: {
          "id": refund.returnRequestProductId.toString(),
          "quantity": refund.quantity,
          "return_request_reason_id": refundReasons[key]!.id,
          "details": refundReasonsDescription[key],
          "images": imagesForRefund[key]!.toList(),
        }).then((value) {
      enableRequestRefund = true;
      emit(RefundRequestUpdatingSuccessState(key: key));

      getOrderInfoForRefund(orderId);
      getOrders();
    }).catchError((error) {
      enableRequestRefund = true;
      logg(error.toString());
      emit(RefundRequestUpdatingErrorState());
    });
  }

  void uploadImages(
      String key,
      int isForExchange,
      int orderId,
      Map<String, List<File>> files,
      int detailsId,
      Refund refund,
      Map<String, Reason?> refundReasons,
      Map<String, String?> refundReasonsDescription,
      {String type = 'add'}) async {
    enableChooseImages = false;
    currentKeyToWork = key;
    enableRequestRefund = false;
    bool stopUploading = false;

    if (currentImageToUpload[key] == null) {
      currentImageToUpload[key] = 0;
      imagesForRefund[key] = [];
    }
    if (currentImageToUpload[key] != files[key]!.length) {
      for (int j = currentImageToUpload[key]!; j < files[key]!.length; j++) {
        emit(UploadImageLoading());
        String fileName = files[key]![j].path.split('/').last;
        String mimeType = mime(fileName) ?? '';
        String mimee = mimeType.split('/')[0];
        String type = mimeType.split('/')[1];
        await MainDioHelper.postData(
            url: uploadImageEP,
            formData: FormData.fromMap({
              "image": await MultipartFile.fromFile(
                files[key]![j].path,
                filename: fileName,
                contentType: MediaType(mimee, type),
              ),
              "path": 'return_request_products',
            })).then((value) {
          logg(value.data.toString());
          logg(value.data['data'].toString());
          imagesForRefund[key]!.add(value.data['data']);
          currentImageToUpload[key] = currentImageToUpload[key]! + 1;
          emit(UploadImageSuccess());
        }).catchError((error) {
          logg(error.toString());
          stopUploading = true;
          emit(UploadImageFailure());
        });
        if (stopUploading) break;
      }
      bool finished = true;
      finished = currentImageToUpload[key] == files[key]!.length;
      if (finished) {
        if (type == 'add') {
          storeRefundRequest(key, isForExchange, orderId, detailsId, refund,
              refundReasons, refundReasonsDescription);
        } else {
          updateProductReturnRequest(
              key, orderId, refund, refundReasons, refundReasonsDescription);
        }
      }
    } else {
      if (type == 'add') {
        storeRefundRequest(key, isForExchange, orderId, detailsId, refund,
            refundReasons, refundReasonsDescription);
      } else {
        updateProductReturnRequest(
            key, orderId, refund, refundReasons, refundReasonsDescription);
      }
    }
  }

  void getWalletDetails({int limit = 10}) {
    walletOffset += 1;
    emit(GetWalletLoadingState());

    MainDioHelper.getData(
            url: getWalletInfoEP + '?limit=$limit&offset=$walletOffset',
            token: getCachedToken())
        .then((value) {
      logg('wallet data got');
      walletModel = WalletModel.fromJson(value.data);

      walletTransactions.addAll(walletModel!.walletTransactionList!);
      emit(GetWalletSuccessState());
    }).catchError((error) {
      logg('an error occurred');
      logg(error.toString());
      emit(GetWalletErrorState());
    });
  }

  void checkMaxQuantityReached(void Function() changeQuantity, int enteredQty,
      int orderId, int detailsId) {
    int qty = orders!
        .firstWhere((element) => element.id == orderId)
        .details!
        .firstWhere((element) => element.id == detailsId)
        .qty!;
    if (enteredQty == 0) {
      changeQuantity.call();
    }
    if (enteredQty > qty) {
      changeQuantity.call();
      emit(SetQuantityFailure());
    }
  }

  void stopWhatsAppNotification(int customerId, int stopWhatsApp) async {
    emit(SetSettingsLoadingState());
    await MainDioHelper.postData(
            url: stopWhatsAppNotificationEP,
            data: {"id": customerId, "is_stop_whatsapp_messages": stopWhatsApp})
        .then((value) {
      logg(value.data.toString());
      mySettingsModel!.data!.isStopWhatsappMessages = stopWhatsApp.toString();
      emit(SetSettingsSuccessState());
    }).catchError((error) {
      logg(error.toString());
      emit(SetSettingsFailureState());
    });
  }

  void getUserSettings() async {
    emit(GetSettingsLoadingState());
    await MainDioHelper.getData(
      url: mySettingsEP,
    ).then((value) {
      logg(value.data.toString());
      mySettingsModel = MySettingsModel.fromJson(value.data);
      emit(GetSettingsSuccessState());
    }).catchError((error) {
      logg(error.toString());
      emit(GetSettingsFailureState());
    });
  }
}
