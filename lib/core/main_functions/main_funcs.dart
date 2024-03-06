import 'dart:convert';
import 'dart:developer';
import 'dart:ui';
import 'package:clearance/modules/main_layout/sub_layouts/account/cubit/account_cubit.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/cubit/account_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:clearance/core/cache/cache.dart';
import 'package:page_transition/page_transition.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

import '../../appMainInitial.dart';
import '../../models/api_models/user_info_model.dart';
import '../../models/api_models/user_model.dart';
import '../../modules/auth_screens/sign_in_screen.dart';
import '../../modules/main_layout/main_layout.dart';
import '../constants/networkConstants.dart';
import '../constants/startup_settings.dart';
import '../main_cubits/cubit_main.dart';
import '../network/dio_helper.dart';
import '../styles_colors/styles_colors.dart';

void logg(String logVal) {
  log(logVal);
}

void logRequestedUrl(String logText) {
  log(logText);
}

Future<void> navigateTo(BuildContext context, page) async {
  Navigator.push(
    context,
    PageTransition(
      type: PageTransitionType.fade,
      child: page,
      duration: const Duration(milliseconds: 400),
    ),
  );
}

Future<void> navigateToAndFinish(BuildContext context, page) async {
  Navigator.pushAndRemoveUntil(
    context,
    PageTransition(
      type: PageTransitionType.bottomToTop,
      child: page,
      duration: const Duration(milliseconds: 0),
    ),
    (route) => route.isFirst,
  );
}

Future<void> navigateToAndFinishUntil(BuildContext context, page) async {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (context) => page,
    ),
    (route) => false,
  );
}
Future<void> navigateToWithNavBarToAddAddress(
    BuildContext context, Widget page, routeName) async {
  pushNewScreenWithRouteSettings(
    context,
    settings: RouteSettings(name: routeName),
    screen: page,
    withNavBar: true,
    pageTransitionAnimation: PageTransitionAnimation.fade,
  );
}

Future<void> navigateToWithNavBar(
    BuildContext context, Widget page, routeName , {bool popAll=true}) async {
  if(popAll) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }
  pushNewScreenWithRouteSettings(
    context,
    settings: RouteSettings(name: routeName),
    screen: page,
    withNavBar: true,
    pageTransitionAnimation: PageTransitionAnimation.fade,
  );
}

Future<void> navigateToWithoutNavBar(
    BuildContext context, Widget page, routeName) async {
  pushNewScreenWithRouteSettings(
    context,
    settings: RouteSettings(name: routeName),
    screen: page,
    withNavBar: false,
    pageTransitionAnimation: PageTransitionAnimation.fade,
  );
}

Future<void> defaultAlertDialog(BuildContext context, String title,
    {Widget? alertDialogContent,
    bool? dismissible,
    Color? alertDialogBackColor}) async {
  await showDialog<String>(
      context: context,
      useRootNavigator: false,
      barrierDismissible: dismissible ?? true,
      barrierColor: Colors.white.withOpacity(0),
      builder: (BuildContext context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
            child: AlertDialog(
              backgroundColor: alertDialogBackColor ?? null,
              title: Center(
                  child: Text(
                title,
                style: mainStyle(
                  18.0,
                  FontWeight.w200,
                ),
              )),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18.0.r))),
              content: alertDialogContent,
            ),
          ));
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

String? getErrorMessageFromErrorJsonResponse(dynamic error) {
  if (error.response == null) {
    return 'Check your internet connection';
  } else {
    return (json.decode(error.response.toString())["message"]).toString();
  }
}

Future<void> myAlertDialog(BuildContext context, String title,
    {Widget? alertDialogContent,
      bool? dismissible,
      bool? withCancelButton,
      Color? alertDialogBackColor}) async {
  await showDialog<String>(
      context: context,
      useRootNavigator: false,
      barrierDismissible: dismissible ?? true,
      barrierColor: Colors.white.withOpacity(0),
      builder: (BuildContext context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
        child: Stack(
          children: [
            AlertDialog(
              backgroundColor: alertDialogBackColor ?? null,
              title: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Text(
                          title,
                          style: mainStyle(
                            18.0,
                            FontWeight.w200,
                          )
                      ),
                      const Spacer(),
                      (withCancelButton!= null && withCancelButton==true) ? Transform.translate(
                        offset: Offset(18.r,-18.r),
                        child: BlocBuilder<AccountCubit, AccountStates>(
                          builder: (context, state) {
                            return InkWell(
                                onTap: (state is! OrderCancelLoading)
                                    ? () {
                                  Navigator.pop(context);
                                }
                                    : null,
                                child: Icon(
                                  Icons.cancel_outlined,
                                  color: primaryColor,
                                  size: 30.h,
                                ));
                          },
                        ),
                      ):const SizedBox.shrink()

                    ],
                  )),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18.0.r))),
              content: alertDialogContent,
            ),
          ],
        ),
      ));
}



bool isUserSignedIn(String? token) {
  if (token != null) {
    return true;
  }
  return false;
}

void pushNewScreenLayout(BuildContext context, page, bool withNavBar) {
  logg('pushNewScreenLayout');
  pushNewScreen(
    context,
    screen: page,
    withNavBar: withNavBar,
    pageTransitionAnimation: PageTransitionAnimation.cupertino,
  );
}
