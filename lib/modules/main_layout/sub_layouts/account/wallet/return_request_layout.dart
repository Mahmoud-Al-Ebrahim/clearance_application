import 'dart:io';
import 'package:camera/camera.dart';
import 'package:clearance/core/constants/startup_settings.dart';
import 'package:clearance/core/error_screens/show_error_message.dart';
import 'package:clearance/core/shared_widgets/shared_widgets.dart';
import 'package:clearance/core/styles_colors/styles_colors.dart';
import 'package:clearance/models/api_models/orders-model.dart';
import 'package:clearance/models/api_models/product_details_for_refund_model.dart';
import 'package:clearance/models/api_models/refund_reasons_model.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/account_shared_widgets/account_shared_widgets.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/cubit/account_cubit.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/cubit/account_state.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/wallet/payment_destination_layout.dart';
import 'package:clearance/modules/main_layout/sub_layouts/cart/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/main_functions/main_funcs.dart';
import '../../../../../models/api_models/home_Section_model.dart';
import '../../../../../core/common/helper_function.dart';

class ReturnRequestLayout extends StatefulWidget {
  ReturnRequestLayout({Key? key,
    this.orderDetails,
    this.isForEdit = false,
    this.returnRequestId})
      : super(key: key);
  List<OrderDetail>? orderDetails;
  final bool isForEdit;
  final int? returnRequestId;

  @override
  State<ReturnRequestLayout> createState() => _ReturnRequestLayoutState();
}

class _ReturnRequestLayoutState extends State<ReturnRequestLayout> {
  late final List<TextEditingController> reasonDescriptionController;

  late final List<GlobalKey<FormState>> formKey;

  final ValueNotifier<int> selectedMethod = ValueNotifier(2);

  final Map<String, List<File>> files = {};
  final Map<String, Reason?> reasons = {};
  final Map<String, String?> reasonDescription = {};

  late final List<ValueNotifier<bool>> filesChoosed;
  late final List<ValueNotifier<bool>> previousFilesChanged;
  late final List<ValueNotifier<bool>> showTheseFieldsRequired;
  late final List<ValueNotifier<bool>> wantToReturn;
  bool isMakeAReturnRequestPreviously = false;
  late List<bool> firstBuild;

  @override
  void initState() {
    AccountCubit.get(context).initReturnRequest();
    if (AccountCubit
        .get(context)
        .refundReasonsModel == null) {
      AccountCubit.get(context).getRefundReasons();
    }
    if (AccountCubit
        .get(context)
        .paymentDestinationsModel == null) {
      AccountCubit.get(context).getPaymentDestinations();
    }

    widget.orderDetails = widget.orderDetails!
        .map((e) {
      if (e.hasRefundRequest == 0) {
        return e;
      }
    })
        .cast<OrderDetail>()
        .toList();
    if (widget.orderDetails![0].orderId != null) {
      if (!widget.isForEdit) {
        AccountCubit.get(context)
            .initialStoreRefundRequest(widget.orderDetails![0].orderId!, 0, 1);
      } else {
        AccountCubit
            .get(context)
            .returnRequestsIds[widget.orderDetails![0].orderId.toString()] =
            widget.returnRequestId.toString();
        AccountCubit.get(context)
            .getOrderInfoForRefund(widget.orderDetails![0].orderId!);
      }
    }
    initVariables();
    super.initState();
  }

  void initVariables() {
    if(widget.returnRequestId!=null){
      AccountCubit.get(context).returnRequestsIds[widget.orderDetails![0].orderId.toString()]=widget.returnRequestId.toString();
    }
    wantToReturn = List.generate(
        widget.orderDetails?.length ?? 0, (index) => ValueNotifier(false));
    firstBuild =
        List.generate(widget.orderDetails?.length ?? 0, (index) => true);
    filesChoosed = List.generate(
        widget.orderDetails?.length ?? 0, (index) => ValueNotifier(false));
    formKey =
        List.generate(widget.orderDetails?.length ?? 0, (index) => GlobalKey());
    previousFilesChanged = List.generate(
        widget.orderDetails?.length ?? 0, (index) => ValueNotifier(false));
    for (int i = 0; i < (widget.orderDetails?.length ?? 0); i++) {
      files[widget.orderDetails![i].productId.toString()] = [];
    }
    reasonDescriptionController = List.generate(
        widget.orderDetails?.length ?? 0, (index) => TextEditingController());
    showTheseFieldsRequired = List.generate(
        widget.orderDetails?.length ?? 0, (index) => ValueNotifier(false));
  }

  @override
  Widget build(BuildContext context) {
    var localizationStrings = AppLocalizations.of(context);
    var accountCubit = AccountCubit.get(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(130.0.h),
        child: DefaultAppBarWithTitleAndBackButtonAndSteps(
          title: localizationStrings!.returnRequest,
          currentPage: 1,
          stepCount: 2,
        ),
      ),
      body:
      BlocConsumer<AccountCubit, AccountStates>(listener: (context, state) {
        if (state is RefundRequestCancelingErrorState) {
          showTopModalSheetErrorMessage(
              context, localizationStrings.something_went_wrong);
        }
        if (state is RefundRequestSuccessState) {
          files[state.key] = [];
          showTopModalSheetErrorMessage(
              context, localizationStrings.addedSuccessfully);
        }
        if (state is RefundRequestUpdatingSuccessState) {
          showTopModalSheetErrorMessage(
              context, localizationStrings.updated_successfully);
        }
        if (state is RefundRequestCancelingSuccessState) {
          files[state.key] = [];
          reasons[state.key] = null;
          reasonDescriptionController[state.index].text = '';
          reasonDescription[state.key] = null;
          showTopModalSheetErrorMessage(
              context, localizationStrings.canceled_successfully);
        }
        if (state is RefundRequestErrorState ||
            state is GetProductInfoForRefundErrorState ||
            state is GetRefundReasonsFailureState ||
            state is GetPaymentDestinationsFailureState) {
          showTopModalSheetErrorMessage(
              context, localizationStrings.something_went_wrong);
        }
        if (state is RemoveImageFromServerSuccess) {
          accountCubit.orderDetailsForRefundModel!.data!.refunds!
              .firstWhere((element) => element.productId == state.productId)
              .imagesUrl!
              .removeAt(state.imageIndex);
          accountCubit.orderDetailsForRefundModel!.data!.refunds!
              .firstWhere((element) => element.productId == state.productId)
              .img!
              .removeAt(state.imageIndex);
          int index = accountCubit.orderDetailsForRefundModel!.data!.refunds!
              .indexWhere((element) => element.productId == state.productId);
          previousFilesChanged[index].value =
          !previousFilesChanged[index].value;
        }
      }, builder: (context, state) {
        if (state is GetProductInfoForRefundErrorState ||
            state is GetRefundReasonsFailureState ||
            state is GetPaymentDestinationsFailureState) {
          return Center(
            child: IconButton(
                onPressed: () {
                  if (accountCubit.refundReasonsModel == null) {
                    accountCubit.getRefundReasons();
                  }
                  if (accountCubit.orderDetailsForRefundModel == null) {
                    accountCubit.getOrderInfoForRefund(
                        widget.orderDetails![0].orderId!);
                  }
                },
                icon: Icon(
                  Icons.refresh,
                  color: primaryColor,
                )),
          );
        }
        if (accountCubit.orderDetailsForRefundModel == null ||
            accountCubit.refundReasonsModel == null) {
          return const Center(
            child: DefaultLoader(),
          );
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              ListView.separated(
                itemCount: widget.orderDetails?.length ?? 0,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                separatorBuilder: (context, index) {
                  return const Divider(
                    thickness: 4,
                  );
                },
                itemBuilder: (context, index) {
                  Refund refund = accountCubit
                      .orderDetailsForRefundModel!.data!.refunds![index];
                  isMakeAReturnRequestPreviously |=
                  (refund.alreadyReturn ?? false);
                  if (refund.alreadyReturn == true && firstBuild[index]) {
                    firstBuild[index] = false;
                    wantToReturn[index].value = true;
                    reasonDescriptionController[index].text =
                        refund.returnRequestProductDetails ?? '';
                    reasonDescription[refund.productId.toString()] =
                        refund.returnRequestProductDetails.toString();
                    reasons[refund.productId.toString()] = accountCubit
                        .refundReasonsModel!.data!.returnReasons!
                        .firstWhere((element) =>
                    element.id == refund.returnRequestProductReasonId);
                  }
                  Product product = widget.orderDetails![index].productDetails!;
                  return ValueListenableBuilder<bool>(
                      valueListenable: wantToReturn[index],
                      builder: (context, isForRefund, _) {
                        logg(isForRefund.toString());
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.0.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              20.verticalSpace,
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  DefaultImage(
                                    backGroundImageUrl: product.images![0],
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
                                          product.name.toString(),
                                          maxLines: 3,
                                          style: mainStyle(
                                            18.0,
                                            FontWeight.bold,
                                          ),
                                        ),
                                        if (widget
                                            .orderDetails![index].variant !=
                                            null) ...{
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          Text(
                                            widget
                                                .orderDetails![index].variant!,
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
                                    refund.quantity.toString(),
                                maxLines: 1,
                                style: mainStyle(
                                  16.0,
                                  FontWeight.w700,
                                ),
                              ),
                              5.verticalSpace,
                              Text(
                                localizationStrings.price +
                                    refund.productPriceFormatted.toString(),
                                maxLines: 1,
                                style: mainStyle(
                                  16.0,
                                  FontWeight.w700,
                                ),
                              ),
                              5.verticalSpace,
                              Text(
                                localizationStrings.subTotal +
                                    refund.subtotalFormatted.toString(),
                                maxLines: 3,
                                style: mainStyle(
                                  16.0,
                                  FontWeight.w700,
                                ),
                              ),
                              if (isForRefund) ...{
                                5.verticalSpace,
                                Form(
                                  key: formKey[index],
                                  child: Column(
                                    children: [
                                      20.verticalSpace,
                                      Text(localizationStrings.refundReason,
                                          style:
                                          mainStyle(18, FontWeight.bold)),
                                      5.verticalSpace,
                                      ClearanceDropDownMenu<Reason>(
                                        onChange: (selected) {
                                          wantToReturn[index].notifyListeners();
                                          reasons[widget
                                              .orderDetails![index].productId
                                              .toString()] = selected;
                                        },
                                        value: reasons[widget
                                            .orderDetails![index].productId
                                            .toString()],
                                        hint: localizationStrings.select_reason,
                                        validator: (value) {
                                          if (value == null && isForRefund) {
                                            return localizationStrings
                                                .fields_required;
                                          }
                                          return null;
                                        },
                                        items: accountCubit.refundReasonsModel!
                                            .data!.returnReasons!
                                            .map((e) => e)
                                            .toList(),
                                      ),
                                      if(reasons[widget
                                          .orderDetails![index]
                                          .productId
                                          .toString()] != null)...{
                                        10.verticalSpace,
                                        Text(localizationStrings
                                            .reason_cost_message1 +
                                            reasons[widget
                                                .orderDetails![index]
                                                .productId
                                                .toString()]!.cost.toString() +
                                            localizationStrings.aed +
                                            (reasons[widget
                                                .orderDetails![index]
                                                .productId
                                                .toString()]!.isCostBySystem ==
                                                1 ? localizationStrings
                                                .reason_cost_message2 : ''),
                                            style:
                                            mainStyle(16, FontWeight.bold,
                                                color: Colors.red)),
                                      },
                                      10.verticalSpace,
                                      Text(
                                          localizationStrings
                                              .reason_description,
                                          style:
                                          mainStyle(18, FontWeight.bold)),
                                      SimpleLoginInputField(
                                        controller:
                                        reasonDescriptionController[index],
                                        hintText:
                                        localizationStrings.description,
                                      ),
                                    ],
                                  ),
                                ),
                                20.verticalSpace,
                                Text(
                                  localizationStrings.attach_picture,
                                  style: mainStyle(16, FontWeight.w500),
                                ),
                                if (refund.alreadyReturn == true) ...{
                                  10.verticalSpace,
                                  ValueListenableBuilder<bool>(
                                      valueListenable:
                                      previousFilesChanged[index],
                                      builder: (context, rebuild, _) {
                                        return (refund.imageUrl?.isNotEmpty ??
                                            false)
                                            ? ListView.separated(
                                            physics:
                                            const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemBuilder: (context,
                                                imageIndex) =>
                                                Stack(
                                                  alignment:
                                                  Alignment.center,
                                                  children: [
                                                    Stack(
                                                        alignment: Alignment
                                                            .topRight,
                                                        children: [
                                                          DefaultImage(
                                                            backGroundImageUrl:
                                                            refund.imagesUrl![
                                                            imageIndex],
                                                            boxFit: BoxFit
                                                                .contain,
                                                            width: 1.sw,
                                                            height: 0.25.sh,
                                                          ),
                                                          Transform
                                                              .translate(
                                                            offset: Offset(
                                                                0, -12.5.h),
                                                            child: InkWell(
                                                              onTap: () {
                                                                accountCubit
                                                                    .removePictureFromServer(
                                                                    imageIndex,
                                                                    refund
                                                                        .productId!,
                                                                    refund
                                                                        .returnRequestProductId!,
                                                                    refund.img![
                                                                    imageIndex]);
                                                              },
                                                              child: Icon(
                                                                  Icons
                                                                      .cancel_outlined,
                                                                  color:
                                                                  primaryColor,
                                                                  size:
                                                                  25.h),
                                                            ),
                                                          ),
                                                        ]),
                                                    Transform.translate(
                                                        offset: Offset(
                                                            0, -15.sp),
                                                        child: state
                                                        is RemoveImageFromServerLoading
                                                            ? const DefaultLoader()
                                                            : const SizedBox
                                                            .shrink())
                                                  ],
                                                ),
                                            separatorBuilder:
                                                (context, index) =>
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
                                            refund.imagesUrl?.length ??
                                                0)
                                            : const SizedBox.shrink();
                                      }),
                                },
                                10.verticalSpace,
                                BlocBuilder<AccountCubit, AccountStates>(
                                  buildWhen: (p, c) =>
                                  c is UploadImageLoading ||
                                      c is UploadImageSuccess ||
                                      c is UploadImageFailure,
                                  builder: (context, state) {
                                    return ValueListenableBuilder<bool>(
                                        valueListenable: filesChoosed[index],
                                        builder: (context, rebuild, _) {
                                          return (files[widget
                                              .orderDetails![index]
                                              .productId
                                              .toString()]!
                                              .isNotEmpty)
                                              ? ListView.separated(
                                              physics:
                                              const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemBuilder:
                                                  (context, imageIndex) =>
                                                  Stack(
                                                    alignment: Alignment
                                                        .center,
                                                    children: [
                                                      Stack(
                                                          alignment:
                                                          Alignment
                                                              .topRight,
                                                          children: [
                                                            Image(
                                                              image: FileImage(
                                                                  files[widget
                                                                      .orderDetails![
                                                                  index]
                                                                      .productId
                                                                      .toString()]![imageIndex]),
                                                              loadingBuilder: (
                                                                  BuildContext context,
                                                                  Widget
                                                                  child,
                                                                  ImageChunkEvent?
                                                                  loadingProgress) {
                                                                if (loadingProgress ==
                                                                    null) {
                                                                  return child;
                                                                }
                                                                return Center(
                                                                    child:
                                                                    DefaultLoader(
                                                                      customHeight:
                                                                      30.h,
                                                                    ));
                                                              },
                                                              fit: BoxFit
                                                                  .contain,
                                                              width:
                                                              1.sw,
                                                              height:
                                                              0.25.sh,
                                                            ),
                                                            Transform
                                                                .translate(
                                                              offset: Offset(
                                                                  0,
                                                                  -12.5
                                                                      .h),
                                                              child:
                                                              InkWell(
                                                                onTap:
                                                                    () {
                                                                  files[widget
                                                                      .orderDetails![index]
                                                                      .productId
                                                                      .toString()]!
                                                                      .removeAt(
                                                                      index);
                                                                  filesChoosed[index]
                                                                      .value =
                                                                  !filesChoosed[index]
                                                                      .value;
                                                                },
                                                                child: Icon(
                                                                    Icons
                                                                        .cancel_outlined,
                                                                    color:
                                                                    primaryColor,
                                                                    size:
                                                                    25.h),
                                                              ),
                                                            )
                                                          ]),
                                                      Transform.translate(
                                                          offset: Offset(0,
                                                              -15.sp),
                                                          child: (state is UploadImageFailure &&
                                                              imageIndex ==
                                                                  (accountCubit
                                                                      .currentImageToUpload[index] ??
                                                                      0))
                                                              ? InkWell(
                                                              onTap: () {
                                                                accountCubit
                                                                    .uploadImages(
                                                                  widget
                                                                      .orderDetails![index]
                                                                      .productId
                                                                      .toString(),
                                                                  0,
                                                                  widget
                                                                      .orderDetails![index]
                                                                      .orderId!,
                                                                  files,
                                                                  widget
                                                                      .orderDetails![index]
                                                                      .id!,
                                                                  refund,
                                                                  reasons,
                                                                  reasonDescription,
                                                                );
                                                              },
                                                              child: Icon(
                                                                Icons.refresh,
                                                                size:
                                                                30.sp,
                                                                color:
                                                                Colors.red,
                                                              ))
                                                              : (imageIndex ==
                                                              (accountCubit
                                                                  .currentImageToUpload[widget
                                                                  .orderDetails![index]
                                                                  .productId
                                                                  .toString()] ??
                                                                  0) &&
                                                              !accountCubit
                                                                  .enableChooseImages)
                                                              ? const DefaultLoader()
                                                              : (imageIndex <
                                                              (accountCubit
                                                                  .currentImageToUpload[widget
                                                                  .orderDetails![index]
                                                                  .productId
                                                                  .toString()] ??
                                                                  0))
                                                              ? Icon(
                                                            Icons
                                                                .check_circle_outline_sharp,
                                                            size: 30.sp,
                                                            color: Colors.green,
                                                          )
                                                              : const SizedBox
                                                              .shrink())
                                                    ],
                                                  ),
                                              separatorBuilder:
                                                  (context, index) =>
                                                  Column(
                                                    children: [
                                                      10.verticalSpace,
                                                      Divider(
                                                        thickness: 3.h,
                                                      ),
                                                      10.verticalSpace
                                                    ],
                                                  ),
                                              itemCount: files[widget
                                                  .orderDetails![
                                              index]
                                                  .productId
                                                  .toString()]
                                                  ?.length ??
                                                  0)
                                              : const SizedBox.shrink();
                                        });
                                  },
                                ),
                                10.verticalSpace,
                                BlocBuilder<AccountCubit, AccountStates>(
                                  builder: (context, state) {
                                    return DefaultButton(
                                        title: localizationStrings.choose_image,
                                        borderColors: (!accountCubit
                                            .enableRequestRefund &&
                                            accountCubit.currentKeyToWork ==
                                                widget.orderDetails![index]
                                                    .productId
                                                    .toString())
                                            ? newSoftGreyColorAux
                                            : null,
                                        titleColor: (!accountCubit
                                            .enableRequestRefund &&
                                            accountCubit.currentKeyToWork ==
                                                widget.orderDetails![index]
                                                    .productId
                                                    .toString())
                                            ? newSoftGreyColorAux
                                            : null,
                                        onClick: (accountCubit
                                            .enableRequestRefund ||
                                            accountCubit.currentKeyToWork !=
                                                widget.orderDetails![index]
                                                    .productId
                                                    .toString())
                                            ? () async {
                                          files[widget
                                              .orderDetails![index]
                                              .productId
                                              .toString()]!
                                              .addAll(
                                              await HelperFunctions()
                                                  .pickFiles() ??
                                                  []);
                                          filesChoosed[index].value =
                                          !filesChoosed[index].value;
                                        }
                                            : null);
                                  },
                                ),
                                10.verticalSpace,
                                BlocBuilder<AccountCubit, AccountStates>(
                                  builder: (context, state) {
                                    return DefaultButton(
                                        title: localizationStrings.open_camera,
                                        borderColors: (!accountCubit
                                            .enableRequestRefund &&
                                            accountCubit.currentKeyToWork ==
                                                widget.orderDetails![index]
                                                    .productId
                                                    .toString())
                                            ? newSoftGreyColorAux
                                            : null,
                                        titleColor: (!accountCubit
                                            .enableRequestRefund &&
                                            accountCubit.currentKeyToWork ==
                                                widget.orderDetails![index]
                                                    .productId
                                                    .toString())
                                            ? newSoftGreyColorAux
                                            : null,
                                        onClick:
                                        (accountCubit.enableRequestRefund ||
                                            accountCubit
                                                .currentKeyToWork !=
                                                widget
                                                    .orderDetails![index]
                                                    .productId
                                                    .toString())
                                            ? () async {
                                          await HelperFunctions
                                              .initCamera();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  Scaffold(
                                                    body: Column(
                                                      children: [
                                                        CameraPreview(
                                                            HelperFunctions
                                                                .cameraController),
                                                        10.verticalSpace,
                                                        Transform
                                                            .translate(
                                                          offset: Offset(
                                                              0, -56.h),
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                15.w),
                                                            child:
                                                            DefaultButton(
                                                              title: localizationStrings
                                                                  .lbl_take_picture,
                                                              onClick:
                                                                  () async {
                                                                XFile
                                                                image =
                                                                await HelperFunctions
                                                                    .cameraController
                                                                    .takePicture();
                                                                files[widget
                                                                    .orderDetails![index]
                                                                    .productId
                                                                    .toString()]!
                                                                    .add(File(
                                                                    image
                                                                        .path));
                                                                filesChoosed[
                                                                index]
                                                                    .value =
                                                                !filesChoosed[
                                                                index]
                                                                    .value;
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                            ),
                                          );
                                        }
                                            : null);
                                  },
                                ),
                              },
                              10.verticalSpace,
                              !(refund.alreadyReturn ?? true)
                                  ? isForRefund
                                  ? const SizedBox.shrink()
                                  : DefaultButton(
                                title: localizationStrings
                                    .want_to_return,
                                onClick: () {
                                  if (isForRefund) {} else {
                                    wantToReturn[index].value =
                                    !wantToReturn[index].value;
                                  }
                                },
                              )
                                  : const SizedBox.shrink(),
                              10.verticalSpace,
                              isForRefund ? BlocBuilder<
                                  AccountCubit,
                                  AccountStates>(
                                  builder: (context, state) {
                                    return (!accountCubit.enableRequestRefund &&
                                        accountCubit.currentKeyToWork ==
                                            widget
                                                .orderDetails![index].productId
                                                .toString())
                                        ? Center(
                                      child:
                                      DefaultLoader(customHeight: 40.h),
                                    )
                                        : Row(
                                      children: [
                                        Expanded(
                                          child: DefaultButton(
                                              title: localizationStrings.back,
                                              onClick: () {
                                                files[widget
                                                    .orderDetails![index]
                                                    .productId
                                                    .toString()] = [];
                                                filesChoosed[index].value =
                                                false;
                                                reasons[widget
                                                    .orderDetails![index]
                                                    .productId
                                                    .toString()] = null;
                                                files[widget
                                                    .orderDetails![index]
                                                    .productId
                                                    .toString()] = [];
                                                reasonDescription[widget
                                                    .orderDetails![index]
                                                    .productId
                                                    .toString()] = null;
                                                reasonDescriptionController[
                                                index]
                                                    .text = '';

                                                wantToReturn[index].value =
                                                !wantToReturn[index].value;
                                              },
                                              titleColor: Colors.red,
                                              borderColors: Colors.red),),
                                        if (!(refund.alreadyReturn ??
                                            true)) ...{
                                          10.horizontalSpace,
                                          Expanded(
                                            child: DefaultButton(
                                                title: localizationStrings.save,
                                                onClick: () {
                                                  if (formKey[index]
                                                      .currentState!
                                                      .validate()) {
                                                    reasonDescription[
                                                    widget
                                                        .orderDetails![
                                                    index]
                                                        .productId
                                                        .toString()] =
                                                        reasonDescriptionController[
                                                        index]
                                                            .text;
                                                    showTheseFieldsRequired[
                                                    index]
                                                        .value = false;
                                                    accountCubit.uploadImages(
                                                        widget
                                                            .orderDetails![
                                                        index]
                                                            .productId
                                                            .toString(),
                                                        0,
                                                        widget
                                                            .orderDetails![
                                                        index]
                                                            .orderId!,
                                                        files,
                                                        widget
                                                            .orderDetails![
                                                        index]
                                                            .id!,
                                                        refund,
                                                        reasons,
                                                        reasonDescription);
                                                  } else {
                                                    showTheseFieldsRequired[
                                                    index]
                                                        .value = true;
                                                  }
                                                },
                                                titleColor: Colors.green,
                                                borderColors: Colors.green),)
                                        }
                                      ],
                                    );
                                  }) : const SizedBox.shrink(),
                              20.verticalSpace,
                              if ((refund.alreadyReturn ?? false))...{
                                BlocConsumer<AccountCubit, AccountStates>(
                                    listener: (context, state) {},
                                    builder: (context, state) {
                                      return (!accountCubit
                                          .enableRequestRefund &&
                                          accountCubit.currentKeyToWork ==
                                              widget.orderDetails![index]
                                                  .productId
                                                  .toString())
                                          ? const SizedBox.shrink()
                                          : DefaultButton(
                                        title: localizationStrings
                                            .edit_product_return_request,
                                        onClick: () async {
                                          if (formKey[index]
                                              .currentState!
                                              .validate()) {
                                            reasonDescription[widget
                                                .orderDetails![index]
                                                .productId
                                                .toString()] =
                                                reasonDescriptionController[
                                                index]
                                                    .text;
                                            showTheseFieldsRequired[index]
                                                .value = false;
                                            accountCubit.uploadImages(
                                                widget
                                                    .orderDetails![index]
                                                    .productId
                                                    .toString(),
                                                0,
                                                widget
                                                    .orderDetails![index]
                                                    .orderId!,
                                                files,
                                                widget
                                                    .orderDetails![index]
                                                    .id!,
                                                refund,
                                                reasons,
                                                reasonDescription,
                                                type: 'edit');
                                          } else {
                                            showTheseFieldsRequired[index]
                                                .value = true;
                                          }
                                        },
                                      );
                                    }),
                                10.verticalSpace,
                                BlocConsumer<AccountCubit, AccountStates>(
                                    listener: (context, state) {},
                                    builder: (context, state) {
                                      return (!accountCubit
                                          .enableRequestRefund &&
                                          accountCubit.currentKeyToWork ==
                                              widget.orderDetails![index]
                                                  .productId
                                                  .toString())
                                          ? const SizedBox.shrink()
                                          : DefaultButton(
                                        title: localizationStrings
                                            .cancel_return_request,
                                        onClick: () async {
                                          accountCubit
                                              .cancelProductReturnRequest(
                                              widget
                                                  .orderDetails![
                                              index]
                                                  .productId
                                                  .toString(),
                                              refund
                                                  .returnRequestProductId!,
                                              widget
                                                  .orderDetails![
                                              index]
                                                  .orderId!,
                                              index);
                                        },
                                      );
                                    }),
                              },
                              5.verticalSpace,
                              ValueListenableBuilder<bool>(
                                  valueListenable:
                                  showTheseFieldsRequired[index],
                                  builder: (context, show, _) {
                                    return show
                                        ? Text(
                                      localizationStrings.fields_required,
                                      style: mainStyle(
                                          16, FontWeight.w500,
                                          color: Colors.red),
                                    )
                                        : const SizedBox.shrink();
                                  }),
                              20.verticalSpace
                            ],
                          ),
                        );
                      });
                },
              ),
              20.verticalSpace,
              BlocConsumer<AccountCubit, AccountStates>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    return (!accountCubit.enableRequestRefund)
                        ? Center(
                      child: DefaultLoader(customHeight: 40.h),
                    )
                        : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.0.w),
                      child: DefaultButton(
                        title: localizationStrings.next,
                        onClick: () async {
                          if (isMakeAReturnRequestPreviously) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PaymentDestinationLayout(
                                          orderId: widget.orderDetails![0].orderId!,
                                        )));
                          } else {
                            showTopModalSheetErrorMessage(
                                context,
                                localizationStrings
                                    .you_must_return_message);
                          }
                        },
                      ),
                    );
                  }),
              30.verticalSpace
            ],
          ),
        );
      }),
    );
  }
}
