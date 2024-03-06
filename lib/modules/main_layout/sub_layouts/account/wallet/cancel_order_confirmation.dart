import 'package:clearance/core/constants/startup_settings.dart';
import 'package:clearance/core/shared_widgets/shared_widgets.dart';
import 'package:clearance/core/styles_colors/styles_colors.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/cubit/account_cubit.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/cubit/account_state.dart';
import 'package:clearance/modules/main_layout/sub_layouts/cart/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CancelOrderConfirmation extends StatelessWidget {
  const CancelOrderConfirmation({Key? key, required this.orderId})
      : super(key: key);
  final int orderId;

  @override
  Widget build(BuildContext context) {
    var localizationStrings = AppLocalizations.of(context);
    var accountCubit = AccountCubit.get(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: BlocConsumer<AccountCubit, AccountStates>(
        listener: (context, state) {
      if (state is OrderCanceledSuccess) {
        if(Navigator.of(context).canPop()){
          Navigator.pop(context);
        }
      }
        },
        builder: (context, state) {
          return Stack(
            alignment: Alignment.topRight,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    localizationStrings!.are_you_sure,
                    style: mainStyle(20, FontWeight.bold, color: primaryColor),
                  ),
                  20.verticalSpace,
                  InkWell(
                    onTap: () {
                      accountCubit.cancelOrder(orderId.toString(),
                          returnMoneyToCard: false);
                    },
                    child: Container(
                      width: 1.sw,
                      padding: EdgeInsets.all(5.r),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: Colors.green),
                      child: (state is OrderCancelLoading && !state.fromWallet)
                          ? Center(
                              child: DefaultLoader(customHeight: 30.h),
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/public/wallet.svg',
                                  height: 25.h,
                                ),
                                5.horizontalSpace,
                                Flexible(
                                  child: Text(
                                    localizationStrings
                                        .return_the_money_using_Wallet,
                                    maxLines: 4,
                                    textAlign: TextAlign.center,
                                    style: mainStyle(14, FontWeight.w400,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  12.verticalSpace,
                  InkWell(
                    onTap: () {
                      accountCubit.cancelOrder(orderId.toString(),
                          returnMoneyToCard: true);
                    },
                    child: Container(
                      width: 1.sw,
                      padding: EdgeInsets.all(5.r),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: Colors.red),
                      child: (state is OrderCancelLoading && state.fromWallet)
                          ? Center(
                              child: DefaultLoader(customHeight: 30.h),
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/public/icons8_visa_1.svg',
                                  height: 25.h,
                                ),
                                5.horizontalSpace,
                                Flexible(
                                  child: Text(
                                    localizationStrings
                                        .return_the_money_using_credit_card,
                                    maxLines: 4,
                                    textAlign: TextAlign.center,
                                    style: mainStyle(14, FontWeight.w400,
                                        color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  10.verticalSpace,
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
