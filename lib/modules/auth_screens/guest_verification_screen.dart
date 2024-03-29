import 'dart:io';

import 'package:clearance/core/constants/networkConstants.dart';
import 'package:clearance/core/main_cubits/cubit_main.dart';
import 'package:clearance/core/main_functions/main_funcs.dart';
import 'package:clearance/core/network/dio_helper.dart';
import 'package:clearance/core/shared_widgets/shared_widgets.dart';
import 'package:clearance/models/api_models/user_info_model.dart';
import 'package:clearance/models/api_models/user_model.dart';
import 'package:clearance/modules/auth_screens/widgets/verfification_number_field.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/cubit/account_cubit.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/cubit/account_state.dart';
import 'package:clearance/modules/main_layout/sub_layouts/main_payment/cubit/cubit_payment.dart';
import 'package:clearance/modules/main_layout/sub_layouts/main_payment/cubit/states_payment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/cache/cache.dart';
import '../../core/constants/startup_settings.dart';
import '../../core/error_screens/show_error_message.dart';
import '../../core/styles_colors/styles_colors.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../main_layout/sub_layouts/cart/cubit/cart_cubit.dart';
import 'cubit/cubit_auth.dart';
import 'cubit/states_auth.dart';

class GuestVerificationScreen extends StatefulWidget {
  const GuestVerificationScreen({Key? key, this.requestVerify = true , this.returnTheNumber=false})
      : super(key: key);
  static String routeName = 'GuestVerificationScreen';
  final bool requestVerify;
  final bool returnTheNumber;

  @override
  State<GuestVerificationScreen> createState() => _GuestVerificationScreen();
}

class _GuestVerificationScreen extends State<GuestVerificationScreen>
    with SingleTickerProviderStateMixin {
  var localizationStrings;

  late final TextEditingController phone;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late ValueNotifier<bool> completedVerificationNotifier;
  late ValueNotifier<bool> _enabledResendNotifier;
  late ValueNotifier<bool> _visibility;
  late ValueNotifier<bool> _isLoadingNotifier;
  late ValueNotifier<bool> _allowToSendOtp;
  late ValueNotifier<bool> _verificationLoader;
  int secondsDuration = 100;
  CountdownTimerController? controller;
  late int endTime;
  String? code;
  String? verificationId;
  PhoneNumber _phoneNumber = PhoneNumber();

  FirebaseAuth auth = FirebaseAuth.instance;
  String previous = '';

  void onEnd() {
    controller!.disposeTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enabledResendNotifier.value = true;
    });
  }
  int  sendUsingWhatsapp=0;
  @override
  void initState() {
    phone = TextEditingController();
    completedVerificationNotifier = ValueNotifier<bool>(false);
    _enabledResendNotifier = ValueNotifier<bool>(false);
    _visibility = ValueNotifier<bool>(false);
    _isLoadingNotifier = ValueNotifier<bool>(false);
    _verificationLoader = ValueNotifier<bool>(false);
    _allowToSendOtp = ValueNotifier<bool>(true);
    super.initState();
  }

  @override
  void dispose() {
    phone.dispose();
    if (controller != null) {
      controller!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    lastScreen = 'GuestVerificationScreen';

    localizationStrings = AppLocalizations.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0.h),
        child: const DefaultAppBarWithOnlyBackButton(),
      ),
      body: Stack(
        alignment: getCachedLocal() == 'en'
            ? Alignment.bottomLeft
            : Alignment.bottomRight,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: BlocListener<PaymentCubit, PaymentsStates>(
              listener: (context, state) {},
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    CacheHelper.getData(key: 'rectangularCurvedLogoUrl') == null
                        ? Image.asset(
                            'assets/icons/clearance2.png',
                            scale: 5,
                          )
                        : Image.file(
                            File(CacheHelper.getData(
                                key: 'rectangularCurvedLogoUrl')),
                            scale: 5,
                          ),
                    const Spacer(),
                    PhoneInputField(
                      label: localizationStrings.phone,
                      phoneController: phone,
                      onInputChanged: (number) {
                        _phoneNumber = number;
                        _allowToSendOtp.value = previous != number.phoneNumber;
                        saveCachePhoneCode(number.isoCode);
                        saveCachePhoneDialCode(number.dialCode);
                        int sz = number.dialCode!.length;
                        saveCachePhoneNumber(number.phoneNumber!.substring(sz));
                      },
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    ValueListenableBuilder<bool>(
                        valueListenable: _allowToSendOtp,
                        builder: (context, allow, _) {
                          return allow
                              ? ValueListenableBuilder<bool>(
                                  valueListenable: _isLoadingNotifier,
                                  builder: (context, loading, _) {
                                    return Column(
                                      children: [
                                        if (loading) ...{
                                          SizedBox(
                                              width: 0.4.sw,
                                              child:
                                                  const LinearProgressIndicator())
                                        },
                                        Column(
                                          children: [
                                            if (enableVerificationByWhatsapp) ...{
                                              10.verticalSpace,
                                              InkWell(
                                                onTap: () {
                                                  lastClickedButton =
                                                  'send via whatsapp';
                                                  setCurrentAction(buttonName: 'SendViaOtpWithWhatsAppButton');
                                                  if (!formKey.currentState!
                                                      .validate()) {
                                                    return;
                                                  }
                                                  endTime = DateTime.now()
                                                      .millisecondsSinceEpoch +
                                                      1000 * secondsDuration;
                                                  controller =
                                                      CountdownTimerController(
                                                          endTime: endTime,
                                                          onEnd: onEnd);
                                                  sendUsingWhatsapp=1;
                                                  _fetchOtp();
                                                  _visibility.value = true;
                                                  _isLoadingNotifier.value =
                                                  true;
                                                },
                                                child: DefaultContainer(
                                                    width: 0.65.sw,
                                                    height: 60.h,
                                                    radius: 12.r,
                                                    backColor: const Color(0xff2CB742),
                                                    borderColor: const Color(0xff2CB742),
                                                    childWidget: Center(
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          15.horizontalSpace,
                                                          Image.asset(
                                                            'assets/images/whats_app.png',
                                                            height: 25.h,
                                                          ),
                                                          5.horizontalSpace,
                                                          Flexible(
                                                            child: Text(
                                                              localizationStrings
                                                                  .send_whatsapp_otp,
                                                              textAlign: TextAlign
                                                                  .center,
                                                              maxLines: 2,
                                                              style: mainStyle(
                                                                  20.0,
                                                                  FontWeight.w600,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                              ),
                                            },
                                            10.verticalSpace,
                                            InkWell(
                                              onTap: () {
                                                lastClickedButton =
                                                    'send via sms';
                                                setCurrentAction(buttonName: 'SendViaOtpWithSMSButton');
                                                if (!formKey.currentState!
                                                    .validate()) {
                                                  return;
                                                }
                                                endTime = DateTime.now()
                                                        .millisecondsSinceEpoch +
                                                    1000 * secondsDuration;
                                                controller =
                                                    CountdownTimerController(
                                                        endTime: endTime,
                                                        onEnd: onEnd);
                                                sendUsingWhatsapp=0;
                                                _fetchOtp();
                                                _visibility.value = true;
                                                _isLoadingNotifier.value = true;
                                              },
                                              child: DefaultContainer(
                                                  width: 0.65.sw,
                                                  radius: 12.r,
                                                  height: 60.h,
                                                  backColor: primaryColor,
                                                  borderColor: primaryColor,
                                                  childWidget: Center(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        15.horizontalSpace,
                                                        Image.asset(
                                                            'assets/images/sms.png',
                                                            color: Colors.white,
                                                            height: 25.h),
                                                        5.horizontalSpace,
                                                        Flexible(
                                                          child: Text(
                                                            localizationStrings
                                                                .send_sms_otp,
                                                            textAlign:
                                                                TextAlign.center,
                                                            maxLines: 2,
                                                            style: mainStyle(20.0,
                                                                FontWeight.w600,
                                                                color:
                                                                    Colors.white),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  })
                              : const SizedBox.shrink();
                        }),
                    SizedBox(
                      height: 10.h,
                    ),
                    ValueListenableBuilder<bool>(
                        valueListenable: _visibility,
                        builder: (context, visible, _) {
                          return visible
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(localizationStrings.enter_otp_message,
                                        style: mainStyle(16, FontWeight.w500)),
                                    5.verticalSpace,
                                    VerificationNumberFields(
                                      onChanged: (code) {
                                        completedVerificationNotifier.value =
                                            code.length == 6;
                                        this.code = code;
                                      },
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink();
                        }),
                    SizedBox(
                      height: 10.h,
                    ),
                    ValueListenableBuilder<bool>(
                        valueListenable: _enabledResendNotifier,
                        builder: (context, enableResend, _) {
                          return !enableResend
                              ? ValueListenableBuilder<bool>(
                                  valueListenable: _visibility,
                                  builder: (context, visible, _) {
                                    return visible
                                        ? CountdownTimer(
                                            widgetBuilder: (_, remainingTime) {
                                              return Directionality(
                                                textDirection:
                                                    TextDirection.ltr,
                                                child: Text(
                                                  '${remainingTime?.min ?? '00'} : ${remainingTime?.sec} ',
                                                  style: mainStyle(
                                                      20.0, FontWeight.w600,
                                                      color: primaryColor),
                                                ),
                                              );
                                            },
                                            controller: controller,
                                            onEnd: onEnd,
                                            endTime: endTime,
                                            endWidget: const SizedBox(),
                                          )
                                        : const SizedBox.shrink();
                                  })
                              : const SizedBox.shrink();
                        }),
                    SizedBox(
                      height: 10.h,
                    ),
                    ValueListenableBuilder<bool>(
                        valueListenable: _visibility,
                        builder: (context, visible, _) {
                          return visible
                              ? ValueListenableBuilder<bool>(
                                  valueListenable: _verificationLoader,
                                  builder: (context, loading, _) {
                                    return Column(
                                      children: [
                                        if (loading) ...{
                                          SizedBox(
                                              width: 0.35.sw,
                                              child:
                                                  const LinearProgressIndicator())
                                        },
                                        ValueListenableBuilder<bool>(
                                            valueListenable:
                                                completedVerificationNotifier,
                                            builder: (context, enableClick, _) {
                                              return InkWell(
                                                onTap: enableClick
                                                    ? _onVerification
                                                    : null,
                                                child: DefaultContainer(
                                                    height: 45.h,
                                                    width: 0.35.sw,
                                                    backColor: Colors.white
                                                        .withOpacity(0.5),
                                                    borderColor: enableClick
                                                        ? Colors.green
                                                        : Colors.grey,
                                                    childWidget: Center(
                                                      child: Text(
                                                        localizationStrings
                                                            .verify_otp,
                                                        style: mainStyle(20.0,
                                                            FontWeight.w600,
                                                            color: enableClick
                                                                ? Colors.green
                                                                : Colors.grey),
                                                      ),
                                                    )),
                                              );
                                            }),
                                      ],
                                    );
                                  })
                              : const SizedBox.shrink();
                        }),
                    SizedBox(
                      height: 10.h,
                    ),
                    ValueListenableBuilder<bool>(
                        valueListenable: _visibility,
                        builder: (context, visible, _) {
                          return visible
                              ? ValueListenableBuilder<bool>(
                                  valueListenable: _enabledResendNotifier,
                                  builder: (context, enabledResend, _) {
                                    return enabledResend
                                        ? InkWell(
                                            onTap: _onResend,
                                            child: DefaultContainer(
                                                height: 45.h,
                                                width: 0.35.sw,
                                                backColor: Colors.white
                                                    .withOpacity(0.5),
                                                borderColor: Colors.lightBlue,
                                                childWidget: Center(
                                                  child: Text(
                                                    localizationStrings
                                                        .reset_otp,
                                                    style: mainStyle(
                                                        20.0, FontWeight.w600,
                                                        color:
                                                            Colors.lightBlue),
                                                  ),
                                                )),
                                          )
                                        : const SizedBox.shrink();
                                  })
                              : const SizedBox.shrink();
                        }),
                    const Spacer()
                  ],
                ),
              ),
            ),
          ),
          BlocBuilder<AccountCubit, AccountStates>(
            buildWhen: (p, c) =>
                c is SuccessContactUsDataState ||
                c is LoadingContactUsDataState ||
                c is FailureContactUsDataState,
            builder: (context, state) {
              if (state is! SuccessContactUsDataState) {
                return const SizedBox.shrink();
              }
              return Transform.translate(
                offset: Offset(getCachedLocal() == 'en' ? 10.w : -10.w, -20.h),
                child: Visibility(
                  visible: showWhatsAppContact ?? true,
                  child: InkWell(
                    onTap: () async {
                      launchUrl(
                          Uri.parse(
                              'https://wa.me/${AccountCubit.get(context).contactUsModel!.data!.whatsAppPhone}/?text=${Uri.parse(AccountCubit.get(context).contactUsModel!.data!.whatsappMessage ?? localizationStrings!.lbl_whatsapp_message)}'),
                          mode: LaunchMode.externalApplication);
                    },
                    focusColor: Colors.transparent,
                    child: SvgPicture.asset('assets/images/whatsapp.svg'),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  _onResend() async {
    lastClickedButton = 'resend otp';
    setCurrentAction(buttonName: 'ResendOtpButton');
    secondsDuration += 100;
    endTime = DateTime.now().millisecondsSinceEpoch + 1000 * secondsDuration;
    controller = CountdownTimerController(endTime: endTime, onEnd: onEnd);
    controller!.start();
    _enabledResendNotifier.value = false;
    _fetchOtp();
  }

  _onVerification() async {
    lastClickedButton = 'verify orp';
    setCurrentAction(buttonName:'VerifyOtpButton');
    if ((code?.isEmpty ?? true) || code == null) {
      showTopModalSheetErrorMessage(context, localizationStrings.enter_otp);
      return;
    }
    if (verificationId == null) {
      showTopModalSheetErrorMessage(context, localizationStrings.wrong_otp);
      return;
    }

    _verificationLoader.value = true;
    await MainDioHelper.getData(
            url: verifyOtpEP,
            query: {"verificationId": verificationId, "otp": code})
        .then((value) async {
      logg(value.toString());
      if (value.data['isSuccessful']) {
        saveCacheIdToken(value.data['data']['id_token']);
        if (widget.requestVerify) {
          final response = await MainDioHelper.postData(
              url: verifyPhone,
              data: {'id_token': value.data['data']['id_token']},
              token: getCachedToken());
          if (response.data['code'] == 'user-verified') {
            logg('user-verified');
          } else if (response.data['code'] == 'user-exists') {
            saveCacheToken(response.data['token']);
            logg('user-exist');
            makeUserLogin(response.data);
            logg(response.data.toString());
            CartCubit.get(context).getCartDetails(
              updateAllList: true,
            );
            CartCubit.get(context).disableCouponStillAvailable();
            MainCubit.get(context).getAddresses();
          }
          AuthCubit.get(context).verifiedNow = true;
          PaymentCubit.get(context).emit(SuccessfulVerification());
          _isLoadingNotifier.value = false;
          _verificationLoader.value = false;
        }
        Navigator.pop(context, widget.returnTheNumber ? previous :sendUsingWhatsapp);
      } else {
        logg('verify phone error');
        logg(value.data['message'].toString());
        showTopModalSheetErrorMessage(
            context, value.data['message'].toString());
        _verificationLoader.value = false;
      }
    });
  }

  void _fetchOtp() async {
    verificationId = null;
    previous = _phoneNumber.phoneNumber?.replaceAll(RegExp(r"\s+"), "") ??
        (getCachedPhoneDialCode()! + getCachedPhoneNumber()!)
            .replaceAll(RegExp(r"\s+"), "");
    _allowToSendOtp.value = false;
    await MainDioHelper.getData(
            url: sendOtpEP,
            query: {"phone": previous, "is_via_whatsapp": sendUsingWhatsapp})
        .then((value) {
      logg('send otp success');
      logg('fetch verification id');
      verificationId = value.data['data']['verificationId'];
      _isLoadingNotifier.value = false;
    }).catchError((error) async {
      _isLoadingNotifier.value = false;
      logg('send otp error');
      logg(error.response.toString());
      showTopModalSheetErrorMessage(
          context, error.response.data['message'].toString());
    });
  }

  makeUserLogin(data) {
    var authCubit = AuthCubit.get(context);
    var mainCubit = MainCubit.get(context);
    authCubit.emit(AuthLoadingState());
    Map<String, dynamic> json = {
      "id": data['data']['id'],
      "name": data['data']['name'],
      "f_name": data['data']['f_name'],
      "l_name": data['data']['l_name'],
      "country_dial_code": data['data']['country_dial_code'],
      "is_phone_verified": data['data']["is_phone_verified"],
      "is_email_verified": data['data']["is_email_verified"],
      "phone": data['data']["phone"] != null
          ? (data['data']["phone"][0] == '+'
              ? data['data']["phone"]
              : ('+' + data['data']["phone"]))
          : null,
      "email": data['data']['email'],
      "image": data['data']['image'],
    };
    authCubit.userSignUpModel = UserModel.fromJson({
      'message': null,
      'data': {'token': data['token'], 'user': json}
    });
    authCubit.userCacheProcess(authCubit.userSignUpModel!);
    authCubit.emit(CheckingAuthState());
    authCubit.userInfoModel =
        UserInfoModel.fromJson({'message': null, 'data': json});
    saveCacheName(authCubit.userInfoModel!.data!.fName!);
    saveCacheEmail(authCubit.userInfoModel!.data!.email);
    authCubit.isUserAuth = true;
    authCubit.isUserAuthChecked = true;
    authCubit.emit(CheckingAuthStateDone());
    mainCubit.updateToken();
    mainCubit.initial(isLogout: false, context: context);
    authCubit.emit(SignUpSuccessState());
  }
}
