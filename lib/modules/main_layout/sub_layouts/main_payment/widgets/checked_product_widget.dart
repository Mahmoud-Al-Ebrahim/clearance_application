import 'package:clearance/core/shared_widgets/shared_widgets.dart';
import 'package:clearance/core/styles_colors/styles_colors.dart';
import 'package:clearance/models/api_models/check_availability_model.dart';
import 'package:clearance/modules/main_layout/sub_layouts/cart/cart_screen.dart';
import 'package:clearance/modules/main_layout/sub_layouts/cart/cubit/cart_cubit.dart';
import 'package:clearance/modules/main_layout/sub_layouts/cart/cubit/cart_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CheckedProductWidget extends StatelessWidget {
  const CheckedProductWidget({Key? key, required this.checkedProductModel})
      : super(key: key);
  final CheckedProduct checkedProductModel;

  @override
  Widget build(BuildContext context) {
    var cartCubit = CartCubit.get(context);
    var localizationStrings = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.all(4.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DefaultImage(
                backGroundImageUrl: checkedProductModel.imageUrl,
                width: 90.w,
                height: 110.h,
              ),
              SizedBox(
                width: 5.w,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID: ${checkedProductModel.id.toString()}',
                      maxLines: 3,
                      style: mainStyle(
                        14.0,
                        FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Text(
                      'name: ' + checkedProductModel.name.toString(),
                      maxLines: 3,
                      style: mainStyle(
                        14.0,
                        FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Text(
                      checkedProductModel.cause.toString(),
                      maxLines: 3,
                      style: mainStyle(
                        16.0,
                        FontWeight.w700,
                      ),
                    ),
                    checkedProductModel.cartPosition != null
                        ? BlocBuilder<CartCubit, CartStates>(
                            builder: (context, state) {
                              return SizedBox(
                                width: 80.w,
                                child: InkWell(
                                  onTap: () {
                                    cartCubit.removeItem('',
                                        cartPosition:
                                            checkedProductModel.cartPosition,
                                        context: context);
                                  },
                                  child: Container(
                                      padding: EdgeInsets.all(2.r),
                                      height: 25.w,
                                      decoration: BoxDecoration(
                                          border: Border.all(color: Colors.red),
                                          borderRadius:
                                              BorderRadius.circular(12.r),
                                          color: Colors.pinkAccent
                                              .withOpacity(0.05)),
                                      child: Center(
                                        child: state is RemovingCartItemState &&
                                                cartCubit
                                                        .currentRemovingItemId ==
                                                    checkedProductModel.id
                                                        .toString()
                                            ? DefaultLoader(
                                                customWidth: 25.w,
                                                customHeight: 25.h,
                                              )
                                            : Text(
                                                localizationStrings!.remove,
                                                style: mainStyle(
                                                    14, FontWeight.bold,
                                                    color: Colors.red,
                                                    fontFamily: 'poppins'),
                                              ),
                                      )),
                                ),
                              );
                            },
                          )
                        : const SizedBox.shrink()
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
