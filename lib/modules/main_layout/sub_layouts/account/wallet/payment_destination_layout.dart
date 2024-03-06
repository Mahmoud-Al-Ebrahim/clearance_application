import 'package:clearance/core/cache/cache.dart';
import 'package:clearance/core/constants/startup_settings.dart';
import 'package:clearance/core/error_screens/show_error_message.dart';
import 'package:clearance/core/shared_widgets/shared_widgets.dart';
import 'package:clearance/models/api_models/payment_destinations_model.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/cubit/account_cubit.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/cubit/account_state.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/wallet/change_quantity_widget.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/wallet/return_request_details_layout.dart';
import 'package:clearance/modules/main_layout/sub_layouts/cart/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../../core/styles_colors/styles_colors.dart';

class PaymentDestinationLayout extends StatelessWidget {
  PaymentDestinationLayout(
      {Key? key, required this.orderId})
      : super(key: key);
  final ValueNotifier<int> selectedMethod = ValueNotifier(-1);
  final int orderId;

  @override
  Widget build(BuildContext context) {
    var localizationStrings = AppLocalizations.of(context);
    var accountCubit = AccountCubit.get(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(130.0.h),
        child: DefaultAppBarWithTitleAndBackButtonAndSteps(
          title: localizationStrings!.returnRequest,
          currentPage: 2,
          stepCount: 2,
        ),
      ),
      body: BlocBuilder<AccountCubit, AccountStates>(
        builder: (context, state) {
          if (state is GetPaymentDestinationsLoadingState) {
            return const Center(
              child: DefaultLoader(),
            );
          }
          if (accountCubit.paymentDestinationsModel == null) {
            return Center(
              child: IconButton(
                  onPressed: () {
                    accountCubit.getPaymentDestinations();
                  },
                  icon: Icon(
                    Icons.refresh,
                    color: primaryColor,
                  )),
            );
          }
          String? locale = getCachedLocal();
          selectedMethod.value = accountCubit.orderDetailsForRefundModel!.data!
                  .returnRequestDestinationId ??
              (selectedMethod.value == -1
                  ? accountCubit
                      .paymentDestinationsModel!.data!.destinations![0].id!
                  : selectedMethod.value);
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  20.verticalSpace,
                  Text(
                    localizationStrings.total_refundable_amount,
                    style: mainStyle(18, FontWeight.bold),
                  ),
                  10.verticalSpace,
                  Text(
                    accountCubit.orderDetailsForRefundModel!.data!
                        .totalRefundableAmountFormatted
                        .toString(),
                    style: mainStyle(18, FontWeight.bold),
                  ),
                  10.verticalSpace,
                  Text(
                    localizationStrings.choose_payment_method,
                    style: mainStyle(18, FontWeight.bold),
                  ),
                  10.verticalSpace,
                  ValueListenableBuilder<int>(
                    valueListenable: selectedMethod,
                    builder: (context, selectedId, _) {
                      return ListView.separated(
                          itemBuilder: (context, paymentIndex) {
                            Destination dest = accountCubit
                                .paymentDestinationsModel!
                                .data!
                                .destinations![paymentIndex];
                            return GestureDetector(
                              onTap: () {
                                selectedMethod.value = dest.id!;
                              },
                              child: ReturnMoneyPaymentMethod(
                                iconWidget: DefaultImage(
                                  backGroundImageUrl: dest.icon.toString(),
                                  boxFit: BoxFit.contain,
                                  height: 40.h,
                                  width: 40.h,
                                ),
                                title: (locale == 'en'
                                        ? dest.englishName
                                        : dest.arabicName)
                                    .toString(),
                                isSelected: selectedId == dest.id!,
                              ),
                            );
                          },
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (context, paymentIndex) {
                            return const Divider(
                              thickness: 4,
                            );
                          },
                          itemCount: accountCubit.paymentDestinationsModel!
                                  .data!.destinations?.length ??
                              0);
                    },
                  ),
                  30.verticalSpace,
                  Column(
                    children: [
                      BlocConsumer<AccountCubit, AccountStates>(
                          listener: (context, state) {
                        if (state is ConfirmReturnRequestSuccess) {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context)
                              ..pop()
                              ..pop()
                              ..push(MaterialPageRoute(
                                  builder: (_) => ReturnRequestDetailsLayout(
                                        returnRequestId: accountCubit.returnRequestsIds[orderId.toString()],
                                      )));
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => ReturnRequestDetailsLayout(
                                  returnRequestId: accountCubit.returnRequestsIds[orderId.toString()],
                                )));
                          }
                        }
                      }, builder: (context, state) {
                        return state is ConfirmReturnRequestLoading
                            ? Center(
                                child: DefaultLoader(customHeight: 40.h),
                              )
                            : Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 15.0.w),
                                child: DefaultButton(
                                  title: localizationStrings.lbl_send,
                                  onClick: () async {
                                    accountCubit.confirmReturnRequest(
                                        orderId, selectedMethod.value);
                                  },
                                ),
                              );
                      }),
                      30.verticalSpace
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
