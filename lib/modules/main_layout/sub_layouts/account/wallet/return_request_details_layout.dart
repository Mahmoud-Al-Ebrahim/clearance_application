import 'package:clearance/core/cache/cache.dart';
import 'package:clearance/core/constants/startup_settings.dart';
import 'package:clearance/core/error_screens/show_error_message.dart';
import 'package:clearance/core/shared_widgets/shared_widgets.dart';
import 'package:clearance/core/styles_colors/styles_colors.dart';
import 'package:clearance/models/api_models/payment_destinations_model.dart';
import 'package:clearance/models/api_models/return_request_display_data_model.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/cubit/account_cubit.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/cubit/account_state.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/wallet/change_quantity_widget.dart';
import 'package:clearance/modules/main_layout/sub_layouts/cart/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class ReturnRequestDetailsLayout extends StatefulWidget {
  const ReturnRequestDetailsLayout({Key? key, this.returnRequestId})
      : super(key: key);

  final String? returnRequestId;

  @override
  State<ReturnRequestDetailsLayout> createState() =>
      _ReturnRequestDetailsLayoutState();
}

class _ReturnRequestDetailsLayoutState
    extends State<ReturnRequestDetailsLayout> {
  @override
  void initState() {
    AccountCubit.get(context)
        .getReturnRequestDataForDisplay(widget.returnRequestId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var localizationStrings = AppLocalizations.of(context);
    var accountCubit = AccountCubit.get(context);
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(56.0.h),
          child: DefaultAppBarWithTitleAndBackButton(
            title: localizationStrings!.refund_details,
          ),
        ),
        body: BlocConsumer<AccountCubit, AccountStates>(
          listener: (context, state) {
            if (state is GetOrderReturnRequestDataFailure) {
              showTopModalSheetErrorMessage(
                  context, localizationStrings.something_went_wrong);
            }
          },
          builder: (context, state) {
            if (state is GetOrderReturnRequestDataFailure ||
                state is GetRefundReasonsFailureState ||
                state is GetPaymentDestinationsFailureState) {
              return Center(
                child: IconButton(
                    onPressed: () {
                      if (accountCubit.refundReasonsModel == null) {
                        accountCubit.getRefundReasons();
                      }
                      if (accountCubit.paymentDestinationsModel == null) {
                        accountCubit.getPaymentDestinations();
                      }
                      if(accountCubit.returnRequestDisplayDataModel==null){
                        accountCubit.getReturnRequestDataForDisplay(
                            widget.returnRequestId);
                      }
                    },
                    icon: Icon(
                      Icons.refresh,
                      color: primaryColor,
                    )),
              );
            }
            if (accountCubit.returnRequestDisplayDataModel == null || accountCubit.refundReasonsModel == null || accountCubit.paymentDestinationsModel == null) {
              return const Center(
                child: DefaultLoader(),
              );
            }
            List<ProductsReturned>? products = accountCubit
                .returnRequestDisplayDataModel!.data!.productsReturned;
            Destination customerDestination = accountCubit
                .paymentDestinationsModel!.data!.destinations!
                .firstWhere((element) =>
                    element.id ==
                    accountCubit.returnRequestDisplayDataModel!.data!
                        .customerReturnRequestDestinationId);


            Destination? adminDestination;
            if(accountCubit.returnRequestDisplayDataModel!.data!
                .adminReturnRequestDestinationId!=null) {
              adminDestination = accountCubit
                  .paymentDestinationsModel!.data!.destinations!
                  .firstWhere((element) =>
              element.id ==
                  accountCubit.returnRequestDisplayDataModel!.data!
                      .adminReturnRequestDestinationId);
            }
            String? locale=getCachedLocal();

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      20.verticalSpace,
                      Text(
                        localizationStrings.total_refundable_amount +
                            accountCubit.returnRequestDisplayDataModel!.data!
                                .totalReturnableAmountFormatted
                                .toString(),
                        maxLines: 3,
                        style: mainStyle(
                          16.0,
                          FontWeight.w700,
                        ),
                      ),
                      5.verticalSpace,
                      Text(
                        localizationStrings.refund_status +
                            accountCubit
                                .returnRequestDisplayDataModel!.data!.status
                                .toString()
                                .toString(),
                        maxLines: 3,
                        style: mainStyle(
                          16.0,
                          FontWeight.w700,
                        ),
                      ),
                      5.verticalSpace,
                      Text(
                        localizationStrings.delivery_service_name +
                            accountCubit.returnRequestDisplayDataModel!.data!
                                .deliveryServiceName
                                .toString()
                                .toString(),
                        maxLines: 3,
                        style: mainStyle(
                          16.0,
                          FontWeight.w700,
                        ),
                      ),
                      5.verticalSpace,
                      Text(
                        localizationStrings.customer_money_destination,
                        maxLines: 3,
                        style: mainStyle(
                          16.0,
                          FontWeight.w700,
                        ),
                      ),
                      5.verticalSpace,
                      ReturnMoneyPaymentMethod(
                        iconWidget: DefaultImage(
                          backGroundImageUrl:
                              customerDestination.icon.toString(),
                          boxFit: BoxFit.contain,
                          height: 40.h,
                          width: 40.h,
                        ),
                        title: (locale=='en' ? customerDestination.englishName : customerDestination.arabicName).toString(),
                        isSelected: true,
                      ),
                      5.verticalSpace,
                      if(adminDestination!=null)...{
                        Text(
                          localizationStrings.admin_money_destination,
                          maxLines: 3,
                          style: mainStyle(
                            16.0,
                            FontWeight.w700,
                          ),
                        ),
                        5.verticalSpace,
                        ReturnMoneyPaymentMethod(
                          iconWidget: DefaultImage(
                            backGroundImageUrl: adminDestination.icon.toString(),
                            boxFit: BoxFit.contain,
                            height: 40.h,
                            width: 40.h,
                          ),
                          title: (locale=='en' ? customerDestination.englishName : customerDestination.arabicName).toString(),
                          isSelected: true,
                        ),
                      },
                      10.verticalSpace,
                      ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (context, index) => Column(
                                children: [
                                  10.verticalSpace,
                                  Divider(
                                    thickness: 3.h,
                                  ),
                                  10.verticalSpace
                                ],
                              ),
                          itemCount: products?.length ?? 0,
                          itemBuilder: (context, index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    DefaultImage(
                                      backGroundImageUrl:
                                          products![index].productImageUrl,
                                      width: 90.w,
                                      height: 110.h,
                                      boxFit: BoxFit.fill,
                                    ),
                                    SizedBox(
                                      width: 5.w,
                                    ),
                                    Flexible(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            products[index]
                                                .productName
                                                .toString(),
                                            maxLines: 3,
                                            style: mainStyle(
                                              18.0,
                                              FontWeight.bold,
                                            ),
                                          ),
                                          if (products[index].productVariant !=
                                              null) ...{
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            Text(
                                              products[index].productVariant!,
                                              maxLines: 3,
                                              style: mainStyle(
                                                16.0,
                                                FontWeight.w500,
                                              ),
                                            ),
                                          }
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                10.verticalSpace,
                                Text(
                                  localizationStrings.quantity +
                                      products[index].quantity.toString(),
                                  maxLines: 1,
                                  style: mainStyle(
                                    16.0,
                                    FontWeight.w700,
                                  ),
                                ),
                                5.verticalSpace,
                                Text(
                                  localizationStrings.refundable_amount +
                                      products[index]
                                          .returnableAmountFormatted
                                          .toString(),
                                  maxLines: 3,
                                  style: mainStyle(
                                    16.0,
                                    FontWeight.w700,
                                  ),
                                ),
                                5.verticalSpace,
                                Text(
                                  localizationStrings.refundReason +
                            (locale=='en' ?  accountCubit.refundReasonsModel!.data!
                                          .returnReasons!
                                          .firstWhere((element) =>
                                              element.id ==
                                              products[index].reasonId).reasonEnglish : accountCubit.refundReasonsModel!.data!
                                .returnReasons!
                                .firstWhere((element) =>
                            element.id ==
                                products[index].reasonId).reasonArabic)
                                          .toString(),
                                  maxLines: 3,
                                  style: mainStyle(
                                    16.0,
                                    FontWeight.w700,
                                  ),
                                ),
                                5.verticalSpace,
                                Text(
                                  localizationStrings.reason_description +
                                      products[index].details.toString(),
                                  maxLines: 3,
                                  style: mainStyle(
                                    16.0,
                                    FontWeight.w700,
                                  ),
                                ),
                                5.verticalSpace,
                                Text(
                                  localizationStrings.attached_picture,
                                  maxLines: 3,
                                  style: mainStyle(
                                    16.0,
                                    FontWeight.w700,
                                  ),
                                ),
                                ListView.separated(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, imageIndex) =>
                                        DefaultImage(
                                          backGroundImageUrl: products[index]
                                              .imagesUrl![imageIndex],
                                          boxFit: BoxFit.contain,
                                          width: 1.sw,
                                          height: 0.25.sh,
                                        ),
                                    separatorBuilder: (context, index) =>
                                        Column(
                                          children: [
                                            10.verticalSpace,
                                            Divider(
                                              thickness: 3.h,
                                            ),
                                            10.verticalSpace
                                          ],
                                        ),
                                    itemCount:
                                        products[index].imagesUrl?.length ?? 0)
                              ],
                            );
                          }),
                      30.verticalSpace
                    ]),
              ),
            );
          },
        ));
  }
}
