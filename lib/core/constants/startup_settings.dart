import 'dart:io';

import 'package:clearance/core/cache/cache.dart';
import 'package:clearance/core/constants/countries.dart';
import 'package:clearance/models/api_models/starting_setting_model.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:convert' as convert;

import 'package:flutter/services.dart';
import 'package:image_downloader/image_downloader.dart';

import '../main_functions/main_funcs.dart';

const String appVersionName='1.3.4';
const int appVersionCode=35;
const String backEndVersion='v9';
late Color mainBackgroundColor ;
late Color titleColor;
 Color primaryColor = const Color(0xffcc3333);
late Color subCategoriesColor ;
late Color buyNowButtonColor ;
late Color priceColor ;
late Color shareButtonColor ;
late Color includingTaxColor ;
late Color giftBackColor ;
late Color categoryHeaderColor ;
late Color newSoftGreyColor ;
late Color mainGreyColor ;
late Color mainCatGreyColor;
late Color newSoftGreyColorAux ;
late Color firstOfferBackColor;
late Color firstOfferForeColor;
late Color secondOfferBackColor;
late Color secondOfferForeColor;
late Color thirdOfferBackColor;
late Color thirdOfferForeColor;
late Color fourthOfferBackColor;
late Color fourthOfferForeColor;
late Color flashDealForeColor;
late Color flashDealBackColor;
late Color applyCouponButtonColor;
late String messageEndWorkTime;
late List<String> orderStatusCanCancelled;
late List<String> orderStatusCanRemoved;
late StartingSettings settings;
late bool enableCrashlytics;
late bool enableFirebaseMessaging;
late bool returnMoneyWithWallet;
late bool returnMoneyWithCard;
int? closedHour;
bool? showCollectionGrid;
bool? showPaymentUsingCards;
bool? showCashPayment;
bool? showPaymentWithPostpay;
bool? showFlashDeals;
bool? showNotifications;
bool? showFeedBack;
bool? showWhatsAppContact;
int countOfRequestToSave=60;
String? lastEndPointUrl;
String? lastScreen;
String? lastClickedButton;
String? deviceId;
late bool enableVerificationByWhatsapp;
late bool enableForgetPasswordByEmail;
late bool showSubCategoryTitle;
late bool thereData;
late int? version;
List<String> screenTrace=[];
 setStartingSettings()async{
   String? cachedData= await CacheHelper.getData(key: 'StartingSettings');
   thereData=(cachedData!=null);
   if(thereData) {
     if(convert.jsonDecode(cachedData!).containsKey('is_system_support_email')) {
       settings = StartingSettings.fromJson(convert.jsonDecode(cachedData));
     }
     else {
       thereData=false;
     }
   }
   print('there data '+thereData.toString());
   firstOfferBackColor =  Color(thereData ? int.parse(settings.offersTheme.everyThingMustGo.backgroundColor) : 0xffCC3333);
   firstOfferBackColor =  Color(thereData ? int.parse(settings.offersTheme.everyThingMustGo.backgroundColor) : 0xffCC3333);
   firstOfferForeColor =  Color(thereData ? int.parse(settings.offersTheme.everyThingMustGo.foregroundColor) : 0xffF6F6F7);
   secondOfferBackColor =  Color(thereData ? int.parse(settings.offersTheme.hardClearance.backgroundColor) : 0xFFFF5722);
   secondOfferForeColor =  Color(thereData ? int.parse(settings.offersTheme.hardClearance.foregroundColor) : 0xffF6F6F7);
   thirdOfferBackColor =  Color(thereData ? int.parse(settings.offersTheme.clearanceSale.backgroundColor) : 0xffFFC107);
   thirdOfferForeColor =  Color(thereData ? int.parse(settings.offersTheme.clearanceSale.foregroundColor) : 0xff000000);
   fourthOfferBackColor =  Color(thereData ? int.parse(settings.offersTheme.freshSale.backgroundColor) : 0xFF43A047);
   fourthOfferForeColor =  Color(thereData ? int.parse(settings.offersTheme.freshSale.foregroundColor) : 0xffF6F6F7);
  mainBackgroundColor =  Color(thereData ? int.parse(settings.mainBackgroundColor) : 0xffF6F6F7);
  titleColor =  Color(thereData ? int.parse(settings.titleColor) : 0xff57636F);
  primaryColor =  Color( thereData ? int.parse(settings.primaryColor) : 0xffCC3333);
  applyCouponButtonColor =  Color( thereData ? int.parse(settings.applyCouponButtonColor) : 0xffDBD7D7);
  subCategoriesColor =  Color(thereData ? int.parse(settings.subCategoriesColor) : 0xfffc808f);
  buyNowButtonColor =  Color(thereData ? int.parse(settings.buyNowButtonColor) : 0xffFFC107);
  priceColor =  Color(thereData ? int.parse(settings.priceColor) : 0xff43A047);
  shareButtonColor =  Color(thereData ? int.parse(settings.shareButtonColor) : 0xff4CAF50);
  includingTaxColor =  Color(thereData ? int.parse(settings.includingTaxColor) : 0xff00BCD4);
   giftBackColor =  Color(thereData ? int.parse(settings.giftBackColor) : 0xffD9FFF5);
   categoryHeaderColor = Color(thereData ? int.parse(settings.categoryHeaderColor) : 0xffAB00FF);
   newSoftGreyColor = Color(thereData ? int.parse(settings.newSoftGreyColor) : 0xffCCCCCC);
   mainGreyColor = Color(thereData ? int.parse(settings.mainGreyColor) : 0xffC4E4FF);
   mainCatGreyColor = Color(thereData ? int.parse(settings.mainCatGreyColor) : 0xffDBD7D7);
   newSoftGreyColorAux = Color(thereData ? int.parse(settings.newSoftGreyColorAux) : 0xffe2e1e1);

   flashDealForeColor =  Color(thereData ? int.parse(settings.flashDealForeColor) : 0xffffffff);
   flashDealBackColor =  Color(thereData ? int.parse(settings.flashDealBackColor) : 0xffCC3333);
   closedHour=thereData ? settings.closedHour : 14;
   showCollectionGrid=thereData ? settings.showCollectionGrid :false;
   version=thereData ? (Platform.isAndroid ? settings.androidMinVersion : settings.iosMinVersion) : 31;
   showPaymentUsingCards=thereData ? settings.showPaymentUsingCards : true;
   showCashPayment=thereData ?settings.showCashPayment : true;
   showPaymentWithPostpay=thereData ?settings.showPaymentWithPostpay : true;
   showNotifications=thereData ? settings.showNotifications : false;
   showFlashDeals=thereData ? settings.showFlashDeals : true;
   showFeedBack=thereData ? settings.showFeedBack : true;
   showWhatsAppContact=thereData ? settings.showWhatsAppContact : true;
   countOfRequestToSave = thereData ? settings.countOfRequestToSave :60;
   messageEndWorkTime = thereData ? settings.messageEndWorkTime ?? '':'';
   enableCrashlytics = thereData ? settings.enableCrashlytics : false;
   enableFirebaseMessaging = thereData ? settings.enableFirebaseMessaging : false;
   returnMoneyWithWallet = thereData ? settings.returnMoneyWithWallet : true;
   returnMoneyWithCard = thereData ? settings.returnMoneyWithCard : true;
   enableForgetPasswordByEmail = thereData ? settings.isSystemSupportEmail : true;
   enableVerificationByWhatsapp = thereData ? settings.enableVerificationByWhatsapp : false;
   showSubCategoryTitle = thereData ? settings.showSubCategoryTitle : false;
   orderStatusCanCancelled = thereData ? settings.orderStatusCanCancelled : [];
   orderStatusCanRemoved = thereData ? settings.orderStatusCanRemoved : [];
   logg('*version*: '+version.toString());

   if(thereData) {
     if(getCachedPhoneDialCode()==null){
       saveCachePhoneDialCode(settings.defaultCountryDialCode);

       logg('iso: ' +countries.firstWhere((element) => element.dialCode ==settings.defaultCountryDialCode).code.toString());
       saveCachePhoneCode(countries.firstWhere((element) => element.dialCode ==settings.defaultCountryDialCode).code);
     }
     if (convert.jsonDecode(cachedData!).containsKey('download_images')) {
       if (convert.jsonDecode(cachedData)['download_images']) {
         await downloadImage(imageName: 'squareCurvedLogoUrl',
             imageUrl: settings.squareCurvedLogoUrl);
         await downloadImage(
             imageName: 'rectangularCurvedLogoUrl',
             imageUrl: settings.rectangularCurvedLogoUrl
         );
       }
     }
   }
}

Future<String> changeSvgColor(String svgPath) async {
  String svgCode =await rootBundle.loadString(svgPath);
  if(thereData ) {
    svgCode=svgCode.replaceAll("CC3333", settings.primaryColor.substring(4).toUpperCase());
  }
  return svgCode;
}

downloadImage({required String imageName , required String imageUrl})async{
  try {
    logg('fetch image\n');
    var imageId = await ImageDownloader.downloadImage(imageUrl , destination: AndroidDestinationType.custom(directory: 'clearance_images')
      ..inExternalFilesDir()
      ..subDirectory("clearance_images/$imageName.png"));
    if (imageId == null) {
    }
    logg('image id :  ' + imageId!);
    String? path = await ImageDownloader.findPath(imageId );
    CacheHelper.saveData(key: imageName, value: path);
    logg('path : '  + path!);
  }  catch (error) {
  }
}

Future<void> setCurrentScreen({required String screenName}) async {
  logg('_setCurrentScreen');
  await FirebaseAnalytics.instance.setCurrentScreen(
      screenName: screenName, screenClassOverride: screenName);
  screenTrace.insert(0, screenName);
}
Future<void> setCurrentAction({required String buttonName}) async {
  screenTrace.insert(0, buttonName);
}
