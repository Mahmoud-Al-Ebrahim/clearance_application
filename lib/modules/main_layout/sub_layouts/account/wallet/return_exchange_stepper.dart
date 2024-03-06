import 'dart:math';

import 'package:clearance/core/styles_colors/styles_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../core/constants/startup_settings.dart';

class ReturnAndExchangeStepper extends StatefulWidget {
  const ReturnAndExchangeStepper(
      {Key? key,
      required this.stepCount,
      required this.currentPage})
      : super(key: key);
  final int stepCount;
  final int currentPage;

  @override
  State<ReturnAndExchangeStepper> createState() =>
      _ReturnAndExchangeStepperState();
}

class _ReturnAndExchangeStepperState extends State<ReturnAndExchangeStepper> {
  @override
  Widget build(BuildContext context) {
    var localizationStrings = AppLocalizations.of(context);
    List<String> titles=(widget.stepCount==2) ?[
      localizationStrings!.choose_products_to_return,
      localizationStrings.choose_payment_destination
    ] : [
      localizationStrings!.choose_products_to_exchange,
      localizationStrings.choose_exchanges_products,
      localizationStrings.choose_payment_destination
    ];
    return Column(
      children: [
        Row(
          children: [
            Column(
              children: [
                getTepWidget(index: 1),
                8.verticalSpace,
                Text(
                  titles[0],
                  style: mainStyle(
                    12,
                    FontWeight.w500,
                    color: primaryColor.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Expanded(
                child: Container(
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
            )),
            Column(
              children: [
                getTepWidget(index: 2),
                8.verticalSpace,
                Text(
                  titles[1],
                  style: mainStyle(
                    12,
                    FontWeight.w500,
                    color: primaryColor.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            if (widget.stepCount > 2) ...{
              Expanded(
                  child: Container(
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
              )),
              Column(
                children: [
                  getTepWidget(index: 3),
                  8.verticalSpace,
                  Text(
                    titles[2],
                    style: mainStyle(
                      12,
                      FontWeight.w500,
                      color: primaryColor.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            },
          ],
        ),

      ],
    );
  }

  Widget getTepWidget({required int index}) {
    bool isActive = widget.currentPage == index;
    return Container(
      width: 50.w,
      height: 50.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.white : Colors.transparent,
        border: Border.all(
          color: primaryColor,
          width: isActive ? 2 : 0,
        ),
      ),
      child: Center(
        child: Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? primaryColor : primaryColor.withOpacity(0.6),
          ),
          child: Center(
              child: Text(
            index.toString(),
            style: mainStyle(16, FontWeight.w400, color: Colors.white),
            textAlign: TextAlign.center,
          )),
        ),
      ),
    );
  }
}
