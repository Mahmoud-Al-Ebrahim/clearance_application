import 'package:clearance/core/constants/startup_settings.dart';
import 'package:clearance/core/error_screens/show_error_message.dart';
import 'package:clearance/core/styles_colors/styles_colors.dart';
import 'package:clearance/models/local_models/local_models.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/cubit/account_cubit.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/cubit/account_state.dart';
import 'package:clearance/modules/main_layout/sub_layouts/cart/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../core/shared_widgets/shared_widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChangeQuantityWidget extends StatefulWidget {
  ChangeQuantityWidget(
      {Key? key,
      required this.orderId,
      required this.detailsId,
      this.isPaid = false})
      : super(key: key);
  final int orderId;
  final int detailsId;
  final bool isPaid;

  @override
  State<ChangeQuantityWidget> createState() => _ChangeQuantityWidgetState();
}

class _ChangeQuantityWidgetState extends State<ChangeQuantityWidget> {
  final TextEditingController quantityController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final ValueNotifier<int> selectedMethod = ValueNotifier(1);

  @override
  void initState() {
    quantityController.addListener(() {
      if(quantityController.text.isNotEmpty) {
        AccountCubit.get(context).checkMaxQuantityReached(() {
          quantityController.text = quantityController.text
              .substring(0, quantityController.text.length - 1);
        }, int.parse(quantityController.text), widget.orderId,
            widget.detailsId);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var localizationStrings = AppLocalizations.of(context);
    var accountCubit = AccountCubit.get(context);
    return BlocConsumer<AccountCubit, AccountStates>(
        listener: (context, state) {
          if(state is SetQuantityFailure){
            showTopModalSheetErrorMessage(context, localizationStrings!.that_is_greater_than_qty);
          }
          if(state is ProductQuantityChanged){
            if(Navigator.of(context).canPop()){
              Navigator.of(context).pop();
            }
          }
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(localizationStrings!.quantity_to_decrease,
                      style: mainStyle(14, FontWeight.w500)),
                  5.verticalSpace,
                  SimpleLoginInputField(
                    controller: quantityController,
                    hintText: localizationStrings.quantity_to_decrease,
                    inputFormatter: [
                      FilteringTextInputFormatter(RegExp(r'[0-9]'), allow: true)
                    ],
                    validate: (String? val) {
                      if (val!.isEmpty) {
                        return localizationStrings.please_enter_quantity;
                      }
                      return null;
                    },
                  ),
                  if (widget.isPaid) ...{
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (returnMoneyWithWallet) ...{
                          15.verticalSpace,
                          ValueListenableBuilder<int>(
                              valueListenable: selectedMethod,
                              builder: (context, selectedId, _) {
                                return GestureDetector(
                                  onTap: () {
                                    selectedMethod.value = 1;
                                  },
                                  child: ReturnMoneyPaymentMethod(
                                    iconWidget: SvgPicture.asset(
                                      'assets/images/public/wallet.svg',
                                      height: 25.h,
                                    ),
                                    title: localizationStrings.wallet,
                                    isSelected: selectedId == 1,
                                  ),
                                );
                              }),
                          if (returnMoneyWithCard) ...{
                            15.verticalSpace,
                            ValueListenableBuilder<int>(
                                valueListenable: selectedMethod,
                                builder: (context, selectedId, _) {
                                  return GestureDetector(
                                    onTap: () {
                                      selectedMethod.value = 2;
                                    },
                                    child: ReturnMoneyPaymentMethod(
                                      iconWidget: SvgPicture.asset(
                                        'assets/images/public/icons8_visa_1.svg',
                                        height: 25.h,
                                      ),
                                      title: localizationStrings.visa,
                                      isSelected: selectedId == 2,
                                    ),
                                  );
                                }),
                          }
                        }
                      ],
                    ),
                  },
                  15.verticalSpace,
                  (accountCubit.currentProductToChangeQuantity ==
                              widget.detailsId &&
                          state is ProductQuantityChanging)
                      ? Center(
                          child: DefaultLoader(customHeight: 0.05.sh),
                        )
                      : Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: DefaultButton(
                                title: localizationStrings.submit,
                                onClick: () async {
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }
                                  accountCubit.setProductNewQuantity(
                                      widget.orderId,
                                      int.parse(quantityController.text),
                                      widget.detailsId,
                                      returnMoneyToCard: widget.isPaid
                                          ? selectedMethod.value == 2
                                          : null);
                                },
                              ),
                            ),
                            const Spacer(),
                            Expanded(
                              flex: 2,
                              child: DefaultButton(
                                title: localizationStrings.cancel,
                                onClick: () async {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        )
                ],
              ),
            ),
          );
        });
  }
}

class ReturnMoneyPaymentMethod extends StatelessWidget {
  const ReturnMoneyPaymentMethod({
    Key? key,
    required this.isSelected,
    required this.title,
    required this.iconWidget,
  }) : super(key: key);

  final bool isSelected;
  final String title;
  final Widget iconWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: mainGreyColor.withOpacity(0.1),
      child: Row(
        children: [
          SizedBox(
            width: 20.w,
          ),
          SizedBox(
            height: 56.h,
            width: 20.w,
            child: Center(
              child: SvgPicture.asset(
                isSelected
                    ? 'assets/images/public/icons8_checked_radio_button.svg'
                    : 'assets/images/public/icons8_unchecked_radio_button.svg',
                width: 10.w,
                height: 12.w,
              ),
            ),
          ),
          SizedBox(
            width: 10.w,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              iconWidget,
              5.horizontalSpace,
              Text(
                title,
                style: mainStyle(16.0, FontWeight.w600),
              ),
            ],
          )
        ],
      ),
    );
  }
}
