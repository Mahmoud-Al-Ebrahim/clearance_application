import 'package:clearance/core/constants/networkConstants.dart';
import 'package:clearance/core/error_screens/show_error_message.dart';
import 'package:clearance/core/styles_colors/styles_colors.dart';
import 'package:clearance/main.dart';
import 'package:clearance/modules/auth_screens/cubit/cubit_auth.dart';
import 'package:clearance/modules/main_layout/sub_layouts/cart/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:clearance/core/constants/startup_settings.dart';
import 'package:clearance/core/main_cubits/states_main.dart';
import 'package:clearance/core/shared_widgets/shared_widgets.dart';
import 'package:restart_app/restart_app.dart';
import '../../../../../appMainInitial.dart';
import '../../../../../core/cache/cache.dart';
import '../../../../../core/main_cubits/cubit_main.dart';
import '../../../../../core/main_functions/main_funcs.dart';
import '../../../../../l10n/l10n.dart';
import '../account_shared_widgets/account_shared_widgets.dart';
import '../cubit/account_cubit.dart';
import '../cubit/account_state.dart';

class DeveloperSettingsView extends StatefulWidget {
  const DeveloperSettingsView({Key? key}) : super(key: key);
  static String routeName = 'developerSettingsView';

  @override
  State<DeveloperSettingsView> createState() => _DeveloperSettingsViewState();
}

class _DeveloperSettingsViewState extends State<DeveloperSettingsView> {
  @override
  void initState() {
    serverUrlController=TextEditingController();
    saveCacheServerUrl(baseLink);
    serverUrlController.text=baseLink;
    super.initState();
  }
late final TextEditingController serverUrlController ;
  @override
  Widget build(BuildContext context) {
    var localizationStrings = AppLocalizations.of(context);
    var mainCubit = MainCubit.get(context);
    logg(getCachedServerUrl().toString());
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(56.0.h),
          child: DefaultAppBarWithTitleAndBackButton(
              title: localizationStrings!.setting),
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          child: SingleChildScrollView(
            child: Column(children: [
              15.verticalSpace,
              Container(
                  height: 65.h,
                  decoration: BoxDecoration(
                    color: const Color(0xffffffff),
                    border: Border.all(width: 1.0, color: primaryColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Switch(
                          value: showCollectionGrid!,
                          activeColor: Colors.green,
                          onChanged: (bool value) {
                            showCollectionGrid = !showCollectionGrid!;
                            setState(() {});
                          }),
                      10.horizontalSpace,
                      Flexible(
                        child: Text(
                          localizationStrings.lbl_collection,
                          maxLines: 2,
                          style: mainStyle(18, FontWeight.w500),
                        ),
                      )
                    ],
                  )),
              10.verticalSpace,
              Container(
                  height: 65.h,
                  decoration: BoxDecoration(
                    color: const Color(0xffffffff),
                    border: Border.all(width: 1.0, color: primaryColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Switch(
                          value: showFlashDeals!,
                          activeColor: Colors.green,
                          onChanged: (bool value) {
                            showFlashDeals = !showFlashDeals!;
                            setState(() {});
                          }),
                      10.horizontalSpace,
                      Text(
                        localizationStrings.flash_deal,
                        style: mainStyle(18, FontWeight.w500),
                      )
                    ],
                  )),
              10.verticalSpace,
              Container(
                  height: 65.h,
                  decoration: BoxDecoration(
                    color: const Color(0xffffffff),
                    border: Border.all(width: 1.0, color: primaryColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Switch(
                          value: returnMoneyWithWallet,
                          activeColor: Colors.green,
                          onChanged: (bool value) {
                            returnMoneyWithWallet = !returnMoneyWithWallet;
                            setState(() {});
                          }),
                      10.horizontalSpace,
                      Text(
                        localizationStrings.wallet,
                        style: mainStyle(18, FontWeight.w500),
                      )
                    ],
                  )),
              10.verticalSpace,
              Container(
                  height: 65.h,
                  decoration: BoxDecoration(
                    color: const Color(0xffffffff),
                    border: Border.all(width: 1.0, color: primaryColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Switch(
                          value: showPaymentWithPostpay!,
                          activeColor: Colors.green,
                          onChanged: (bool value) {
                            showPaymentWithPostpay = !showPaymentWithPostpay!;
                            setState(() {});
                          }),
                      10.horizontalSpace,
                      Text(
                        localizationStrings.postPay,
                        style: mainStyle(18, FontWeight.w500),
                      )
                    ],
                  )),
              10.verticalSpace,
              Container(
                  height: 65.h,
                  decoration: BoxDecoration(
                    color: const Color(0xffffffff),
                    border: Border.all(width: 1.0, color: primaryColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Switch(
                          value: showCashPayment!,
                          activeColor: Colors.green,
                          onChanged: (bool value) {
                            showCashPayment = !showCashPayment!;
                            setState(() {});
                          }),
                      10.horizontalSpace,
                      Text(
                        localizationStrings.payCash,
                        style: mainStyle(18, FontWeight.w500),
                      )
                    ],
                  )),
              10.verticalSpace,
              Container(
                  height: 65.h,
                  decoration: BoxDecoration(
                    color: const Color(0xffffffff),
                    border: Border.all(width: 1.0, color: primaryColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Switch(
                          value: showPaymentUsingCards!,
                          activeColor: Colors.green,
                          onChanged: (bool value) {
                            showPaymentUsingCards = !showPaymentUsingCards!;
                            setState(() {});
                          }),
                      10.horizontalSpace,
                      Text(
                        localizationStrings.payWithYourCard,
                        style: mainStyle(18, FontWeight.w500),
                      )
                    ],
                  )),
              10.verticalSpace,
              Container(
                  height: 65.h,
                  decoration: BoxDecoration(
                    color: const Color(0xffffffff),
                    border: Border.all(width: 1.0, color: primaryColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Switch(
                          value: enableVerificationByWhatsapp,
                          activeColor: Colors.green,
                          onChanged: (bool value) {
                            enableVerificationByWhatsapp =
                                !enableVerificationByWhatsapp;
                            setState(() {});
                          }),
                      10.horizontalSpace,
                      Flexible(
                        child: Text(
                          localizationStrings.send_whatsapp_otp,
                          maxLines: 2,
                          style: mainStyle(18, FontWeight.w500),
                        ),
                      )
                    ],
                  )),
              10.verticalSpace,
              Container(
                  height: 65.h,
                  decoration: BoxDecoration(
                    color: const Color(0xffffffff),
                    border: Border.all(width: 1.0, color: primaryColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Switch(
                          value: enableForgetPasswordByEmail,
                          activeColor: Colors.green,
                          onChanged: (bool value) {
                            enableForgetPasswordByEmail =
                                !enableForgetPasswordByEmail;
                            setState(() {});
                          }),
                      10.horizontalSpace,
                      Text(
                        localizationStrings.forget_password_by_email,
                        style: mainStyle(18, FontWeight.w500),
                      )
                    ],
                  )),
              10.verticalSpace,
              Container(
                  height: 65.h,
                  decoration: BoxDecoration(
                    color: const Color(0xffffffff),
                    border: Border.all(width: 1.0, color: primaryColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Switch(
                          value: showWhatsAppContact!,
                          activeColor: Colors.green,
                          onChanged: (bool value) {
                            showWhatsAppContact = !showWhatsAppContact!;
                            setState(() {});
                          }),
                      10.horizontalSpace,
                      Flexible(
                        child: Text(
                          localizationStrings.lbl_using_whatsapp,
                          maxLines: 2,
                          style: mainStyle(18, FontWeight.w500),
                        ),
                      )
                    ],
                  )),
              10.verticalSpace,
              Container(
                  height: 65.h,
                  decoration: BoxDecoration(
                    color: const Color(0xffffffff),
                    border: Border.all(width: 1.0, color: primaryColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Switch(
                          value: enableFirebaseMessaging,
                          activeColor: Colors.green,
                          onChanged: (bool value) {
                            enableFirebaseMessaging = !enableFirebaseMessaging;
                            setState(() {});
                          }),
                      10.horizontalSpace,
                      Text(
                        localizationStrings.firebase_messaging,
                        style: mainStyle(18, FontWeight.w500),
                      )
                    ],
                  )),
              10.verticalSpace,
              Container(
                  height: 65.h,
                  decoration: BoxDecoration(
                    color: const Color(0xffffffff),
                    border: Border.all(width: 1.0, color: primaryColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Switch(
                          value: enableCrashlytics,
                          activeColor: Colors.green,
                          onChanged: (bool value) {
                            enableCrashlytics = !enableCrashlytics;
                            setState(() {});
                          }),
                      10.horizontalSpace,
                      Text(
                        localizationStrings.firebase_crashlytics,
                        style: mainStyle(18, FontWeight.w500),
                      )
                    ],
                  )),
              10.verticalSpace,
              Container(
                  height: 65.h,
                  decoration: BoxDecoration(
                    color: const Color(0xffffffff),
                    border: Border.all(width: 1.0, color: primaryColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Switch(
                          value: showNotifications!,
                          activeColor: Colors.green,
                          onChanged: (bool value) {
                            showNotifications = !showNotifications!;
                            setState(() {});
                          }),
                      10.horizontalSpace,
                      Text(
                        localizationStrings.lbl_notification,
                        style: mainStyle(18, FontWeight.w500),
                      )
                    ],
                  )),
              10.verticalSpace,
              Container(
                  height: 65.h,
                  decoration: BoxDecoration(
                    color: const Color(0xffffffff),
                    border: Border.all(width: 1.0, color: primaryColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Switch(
                          value: showSubCategoryTitle,
                          activeColor: Colors.green,
                          onChanged: (bool value) {
                            showSubCategoryTitle = !showSubCategoryTitle;
                            setState(() {});
                          }),
                      10.horizontalSpace,
                      Text(
                        'showSubCategoryTitle',
                        style: mainStyle(18, FontWeight.w500),
                      )
                    ],
                  )),
              10.verticalSpace,
              Container(
                  decoration: BoxDecoration(
                    color: const Color(0xffffffff),
                    border: Border.all(width: 1.0, color: primaryColor),
                  ),
                  child: Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 8.w,vertical: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(localizationStrings.live_server ,   style: mainStyle(18, FontWeight.w500),),
                        5.verticalSpace,
                        SimpleLoginInputField(hintText: localizationStrings.live_server,controller: serverUrlController),
                     10.verticalSpace,
                        DefaultButton(
                          title: localizationStrings.save,
                          onClick: (){
                            saveCacheServerUrl(serverUrlController.text);
                            setState(() {

                            });
                          },
                        )
                      ],
                    ),
                  )),
              10.verticalSpace,
              ChangeColorOption(
                  color: primaryColor,
                  title: 'mainBackgroundColor',
                  onColorChanged: (color) {
                    mainBackgroundColor = color;
                    setState(() {});
                  }),
              10.verticalSpace,
              ChangeColorOption(
                  color: primaryColor,
                  title: 'titleColor',
                  onColorChanged: (color) {
                    titleColor = color;
                    setState(() {});
                  }),
              10.verticalSpace,
              ChangeColorOption(
                  color: primaryColor,
                  title: 'primaryColor',
                  onColorChanged: (color) {
                    primaryColor = color;
                    setState(() {});
                  }),
              10.verticalSpace,
              ChangeColorOption(
                  color: primaryColor,
                  title: 'subCategoriesColor',
                  onColorChanged: (color) {
                    subCategoriesColor = color;
                    setState(() {});
                  }),
              10.verticalSpace,
              ChangeColorOption(
                  color: primaryColor,
                  title: 'buyNowButtonColor',
                  onColorChanged: (color) {
                    buyNowButtonColor = color;
                    setState(() {});
                  }),
              10.verticalSpace,
              ChangeColorOption(
                  color: primaryColor,
                  title: 'priceColor',
                  onColorChanged: (color) {
                    priceColor = color;
                    setState(() {});
                  }),
              10.verticalSpace,
              ChangeColorOption(
                  color: primaryColor,
                  title: 'shareButtonColor',
                  onColorChanged: (color) {
                    titleColor = color;
                    setState(() {});
                  }),
              10.verticalSpace,
              ChangeColorOption(
                  color: primaryColor,
                  title: 'includingTaxColor',
                  onColorChanged: (color) {
                    includingTaxColor = color;
                    setState(() {});
                  }),
              10.verticalSpace,
              ChangeColorOption(
                  color: primaryColor,
                  title: 'giftBackColor',
                  onColorChanged: (color) {
                    giftBackColor = color;
                    setState(() {});
                  }),
              10.verticalSpace,
              ChangeColorOption(
                  color: primaryColor,
                  title: 'categoryHeaderColor',
                  onColorChanged: (color) {
                    categoryHeaderColor = color;
                    setState(() {});
                  }),
              10.verticalSpace,
              ChangeColorOption(
                  color: primaryColor,
                  title: 'newSoftGreyColor',
                  onColorChanged: (color) {
                    newSoftGreyColor = color;
                    setState(() {});
                  }),
              10.verticalSpace,
              ChangeColorOption(
                  color: primaryColor,
                  title: 'mainGreyColor',
                  onColorChanged: (color) {
                    mainGreyColor = color;
                    setState(() {});
                  }),
              10.verticalSpace,
              ChangeColorOption(
                  color: primaryColor,
                  title: 'mainCatGreyColor',
                  onColorChanged: (color) {
                    mainCatGreyColor = color;
                    setState(() {});
                  }),
              10.verticalSpace,
              ChangeColorOption(
                  color: primaryColor,
                  title: 'newSoftGreyColorAux',
                  onColorChanged: (color) {
                    newSoftGreyColorAux = color;
                    setState(() {});
                  }),
              10.verticalSpace,
              ChangeColorOption(
                  color: primaryColor,
                  title: 'firstOfferBackColor',
                  onColorChanged: (color) {
                    firstOfferBackColor = color;
                    setState(() {});
                  }),
              10.verticalSpace,
              ChangeColorOption(
                  color: primaryColor,
                  title: 'firstOfferForeColor',
                  onColorChanged: (color) {
                    firstOfferForeColor = color;
                    setState(() {});
                  }),
              10.verticalSpace,
              ChangeColorOption(
                  color: primaryColor,
                  title: 'secondOfferBackColor',
                  onColorChanged: (color) {
                    secondOfferBackColor = color;
                    setState(() {});
                  }),
              10.verticalSpace,
              ChangeColorOption(
                  color: primaryColor,
                  title: 'secondOfferForeColor',
                  onColorChanged: (color) {
                    secondOfferForeColor = color;
                    setState(() {});
                  }),
              10.verticalSpace,
              ChangeColorOption(
                  color: primaryColor,
                  title: 'thirdOfferBackColor',
                  onColorChanged: (color) {
                    thirdOfferBackColor = color;
                    setState(() {});
                  }),
              10.verticalSpace,
              ChangeColorOption(
                  color: primaryColor,
                  title: 'thirdOfferForeColor',
                  onColorChanged: (color) {
                    thirdOfferForeColor = color;
                    setState(() {});
                  }),10.verticalSpace,
              ChangeColorOption(
                  color: primaryColor,
                  title: 'fourthOfferBackColor',
                  onColorChanged: (color) {
                    fourthOfferBackColor = color;
                    setState(() {});
                  }),
              10.verticalSpace,
              ChangeColorOption(
                  color: primaryColor,
                  title: 'fourthOfferForeColor',
                  onColorChanged: (color) {
                    fourthOfferForeColor = color;
                    setState(() {});
                  }),
              10.verticalSpace,
              ChangeColorOption(
                  color: primaryColor,
                  title: 'flashDealForeColor',
                  onColorChanged: (color) {
                    flashDealForeColor = color;
                    setState(() {});
                  }),
              10.verticalSpace,
              ChangeColorOption(
                  color: primaryColor,
                  title: 'flashDealBackColor',
                  onColorChanged: (color) {
                    flashDealBackColor = color;
                    setState(() {});
                  }),
              10.verticalSpace,
              ChangeColorOption(
                  color: primaryColor,
                  title: 'applyCouponButtonColor',
                  onColorChanged: (color) {
                    applyCouponButtonColor = color;
                    setState(() {});
                  }),

              20.verticalSpace
            ]),
          ),
        ));
  }
}

class ChangeColorOption extends StatelessWidget {
  const ChangeColorOption(
      {Key? key,
      required this.title,
      required this.color,
      required this.onColorChanged})
      : super(key: key);

  final String title;
  final Color color;
  final void Function(Color color) onColorChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 65.h,
        decoration: BoxDecoration(
          color: const Color(0xffffffff),
          border: Border.all(width: 1.0, color: primaryColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            10.horizontalSpace,
            Text(
              title,
              style: mainStyle(18, FontWeight.w500),
            ),
            const Spacer(),
            SizedBox(
              width: 0.2.sw,
              child: DefaultButton(
                title: 'pick',
                onClick: () {
                  myAlertDialog(context, 'color picker',
                      alertDialogContent: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: color,
                          onColorChanged: onColorChanged,
                        ),
                      ),
                      withCancelButton: true);
                },
              ),
            ),
            10.horizontalSpace
          ],
        ));
  }
}

class SettingRow extends StatelessWidget {
  const SettingRow({
    Key? key,
    required this.svgPath,
    required this.title,
    required this.selectedValue,
  }) : super(key: key);

  final String svgPath;
  final String title;
  final String selectedValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 230.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(svgPath),
              SizedBox(
                width: 10.w,
              ),
              Text(title)
            ],
          ),
        ),
        Text('> $selectedValue')
      ],
    );
  }
}
