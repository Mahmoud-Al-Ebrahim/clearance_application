import 'dart:io';
import 'dart:math';

import 'package:clearance/core/cache/cache.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/wallet/cancel_order_confirmation.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/wallet/change_quantity_widget.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/wallet/choose_products_for_exchange.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/wallet/return_request_details_layout.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/wallet/return_request_layout.dart';
import 'package:clearance/modules/main_layout/sub_layouts/product_details/cubit/cubit_product_details.dart';
import 'package:clearance/modules/main_layout/sub_layouts/product_details/cubit/states_product_details.dart'
    as product_state;
import 'package:clearance/modules/main_layout/sub_layouts/product_details/widgets/product_details_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:screenshot/screenshot.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../models/api_models/product_details_model.dart';
import 'package:clearance/core/constants/startup_settings.dart';
import 'package:clearance/models/api_models/orders-model.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/cubit/account_cubit.dart';
import 'package:clearance/modules/main_layout/sub_layouts/cart/cart_screen.dart';
import '../../../../../core/error_screens/errors_screens.dart';
import '../../../../../core/error_screens/show_error_message.dart';
import '../../../../../core/main_functions/main_funcs.dart';
import '../../../../../core/shared_widgets/shared_widgets.dart';
import '../../../../../core/styles_colors/styles_colors.dart';
import '../../../../../models/local_models/account_items_model.dart';
import '../account_shared_widgets/account_shared_widgets.dart';
import '../cubit/account_state.dart';

class MyOrdersView extends StatefulWidget {
  const MyOrdersView({Key? key}) : super(key: key);
  static String routeName = 'myOrdersView';

  @override
  State<MyOrdersView> createState() => _MyOrdersViewState();
}

class _MyOrdersViewState extends State<MyOrdersView>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    setCurrentScreen(screenName: 'MyOrdersView');

    // // TODO: implement initState
    // logg(widget.selectedTabId.toString());
    // _tabController = TabController(
    //     length: 5, vsync: this, initialIndex: widget.selectedTabId); //changed
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    lastScreen = 'MyOrdersView';

    var localizationStrings = AppLocalizations.of(context);
    var accountCubit = AccountCubit.get(context)
      ..changeCurrentOrderDetailsViewId('0');
    accountCubit.getOrders();

    List<AccountItemsModel> ordersMainItems = [
      AccountItemsModel(
          id: 0,
          apiOrderStatus: 'pending',
          svgImagePath: 'assets/images/account/my_orders/confirming.svg',
          title: localizationStrings!.pending),
      AccountItemsModel(
          id: 1,
          apiOrderStatus: 'processing',
          svgImagePath: 'assets/images/account/my_orders/processing.svg',
          title: localizationStrings!.processing),
      AccountItemsModel(
          id: 2,
          apiOrderStatus: 'information_received',
          svgImagePath:
              'assets/images/account/my_orders/information_received.svg',
          title: localizationStrings!.ready_to_ship),
      AccountItemsModel(
          id: 3,
          apiOrderStatus: 'shipped',
          svgImagePath: 'assets/images/account/my_orders/shipped.svg',
          title: localizationStrings!.shipped),
      AccountItemsModel(
          id: 4,
          apiOrderStatus: 'out_for_delivery',
          svgImagePath: 'assets/images/account/my_orders/out_for_delivery.svg',
          title: localizationStrings!.out_for_delivery),
      AccountItemsModel(
          id: 5,
          apiOrderStatus: 'delivered',
          svgImagePath: 'assets/images/account/my_orders/delivered.svg',
          title: localizationStrings.delivered),
      AccountItemsModel(
          id: 6,
          apiOrderStatus: 'returned',
          svgImagePath: 'assets/images/account/my_orders/refund.svg',
          title: localizationStrings.returned),
      AccountItemsModel(
          id: 7,
          apiOrderStatus: 'failed',
          svgImagePath: 'assets/images/account/my_orders/failed.svg',
          title: localizationStrings.failed),
      AccountItemsModel(
          id: 8,
          apiOrderStatus: 'canceled',
          svgImagePath: 'assets/images/account/my_orders/cancelled.svg',
          title: localizationStrings.canceled),
      AccountItemsModel(
          id: 9,
          apiOrderStatus: 'canceled_archived',
          svgImagePath: 'assets/images/account/my_orders/archive.svg',
          title: localizationStrings.canceled_archived),
    ];

    // List<OrdersListModel> ordersList = [
    //   OrdersListModel(
    //     id: 1,
    //     title: 'نظارات شمسية',
    //     imagePath: 'url',
    //     color: 'أسود',
    //     quantity: '2',
    //     price: '180 درهم',
    //   ),
    //   OrdersListModel(
    //     id: 2,
    //     title: 'مصفف الشعر',
    //     imagePath: 'url',
    //     color: 'أسود',
    //     quantity: '1',
    //     price: '100 درهم',
    //   ),
    //   OrdersListModel(
    //     id: 3,
    //     title: 'قفاذات اليدين',
    //     imagePath: 'url',
    //     color: 'أسود',
    //     quantity: '5',
    //     price: '300 درهم',
    //   ),
    // ];

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
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0.w),
                    child: AccountItemContainer(
                      title: localizationStrings.orders,
                      svgPath: 'assets/images/account/List order_Icon.svg',
                    ),
                  ),
                  Expanded(
                    child: BlocConsumer<AccountCubit, AccountStates>(
                      listener: (context, state) {
                        if (state is OrderCanceledError) {
                          showTopModalSheetErrorMessage(context,
                              localizationStrings.something_went_wrong);
                        }
                        if (state is OrderCanceledSuccess) {
                          showTopModalSheetErrorMessage(context,
                              localizationStrings.canceled_successfully);
                        }
                        if (state is ErrorLoadingDataState) {
                          showTopModalSheetErrorMessage(context,
                              localizationStrings.something_went_wrong);
                        }
                      },
                      builder: (context, state) {
                        if (state is ErrorLoadingDataState) {
                          return Center(
                            child: IconButton(
                              icon: Icon(
                                Icons.refresh,
                                color: primaryColor,
                              ),
                              onPressed: () {
                                accountCubit
                                  ..changeCurrentOrderDetailsViewId('0')
                                  ..getOrders();
                              },
                            ),
                          );
                        }
                        if (state is LoadingOrdersState) {
                          return Center(
                              child: DefaultLoader(
                            customHeight: 0.1.sh,
                          ));
                        }
                        return ConditionalBuilder(
                          condition: accountCubit.ordersModel != null,
                          builder: (context) => SingleChildScrollView(
                            child: OrdersListView(
                                ordersList: accountCubit.ordersModel!.data!
                                // !.where((element) => element.orderStatus=='test').toList()
                                ,
                                //send filtered content
                                localizationStrings: localizationStrings),
                          ),
                          fallback: (context) => Center(
                              child: DefaultLoader(
                            customHeight: 0.1.sh,
                          )),
                        );
                        // if (accountCubit.currentOrderList == null) {
                        //   accountCubit.applyOrdersListFilter(
                        //       ordersMainItems[widget.selectedTabId].apiOrderStatus);
                        // }
                        //
                        // return Padding(
                        //   padding: const EdgeInsets.symmetric(
                        //     horizontal: defaultHorizontalPadding * 1.2,
                        //   ),
                        //   child: DefaultTabController(
                        //     length: ordersMainItems.length,
                        //     child: Column(
                        //       mainAxisSize: MainAxisSize.min,
                        //       children: <Widget>[
                        //         DefaultContainer(
                        //           backColor: Colors.white,
                        //           borderColor: mainRedColorAux,
                        //           height: 60.w,
                        //           width: 1.sw,
                        //           childWidget: TabBar(
                        //               onTap: (index) {
                        //                 accountCubit.applyOrdersListFilter(
                        //                     ordersMainItems[index].apiOrderStatus);
                        //               },
                        //               controller: _tabController,
                        //
                        //               isScrollable: true,
                        //               indicatorColor: mainRedColorAux,
                        //               // labelPadding:
                        //               //     EdgeInsets.symmetric(horizontal: 8.0.w),
                        //               tabs: ordersMainItems
                        //                   .map((e) => OrderTab(
                        //                         svgAssetLink: e.svgImagePath,
                        //                         title: e.title,
                        //                       ))
                        //                   .toList()
                        //               //
                        //               // [
                        //               //   OrderTab(),
                        //               //   Tab(
                        //               //       child: Text(
                        //               //     'Shipping',
                        //               //     style: mainStyle(
                        //               //       14.0,
                        //               //       FontWeight.w600,
                        //               //     ),
                        //               //   )),
                        //               //   Tab(
                        //               //       child: Text(
                        //               //     'Delivered',
                        //               //     style: mainStyle(
                        //               //       14.0,
                        //               //       FontWeight.w600,
                        //               //     ),
                        //               //   )),
                        //               // ],
                        //               ),
                        //         ),
                        //         Expanded(
                        //           child: TabBarView(
                        //               children: ordersMainItems.map((e) {
                        //             return OrdersListView(
                        //                 ordersList: accountCubit.currentOrderList!
                        //                 // !.where((element) => element.orderStatus=='test').toList()
                        //
                        //                 ,
                        //                 //send filtered content
                        //                 localizationStrings: localizationStrings);
                        //           }).toList()
                        //               // [
                        //               //   OrdersListView(
                        //               //       demoOrdersList: ordersList,
                        //               //       localizationStrings: localizationStrings),
                        //               //   OrdersListView(
                        //               //       demoOrdersList: ordersList,
                        //               //       localizationStrings: localizationStrings),
                        //               //   OrdersListView(
                        //               //       demoOrdersList: ordersList,
                        //               //       localizationStrings: localizationStrings),
                        //               // ]
                        //               ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // );
                      },
                    ),
                  ),
                ],
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
                  offset:
                      Offset(getCachedLocal() == 'en' ? 10.w : -10.w, -20.h),
                  child: Visibility(
                    visible: showWhatsAppContact ?? true,
                    child: InkWell(
                      onTap: () async {
                        launchUrl(
                            Uri.parse(
                                'https://wa.me/${AccountCubit.get(context).contactUsModel!.data!.whatsAppPhone}/?text=${Uri.parse(AccountCubit.get(context).contactUsModel!.data!.whatsappMessage ?? localizationStrings.lbl_whatsapp_message)}'),
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
        ));
  }
}

class OrderTab extends StatelessWidget {
  const OrderTab({
    Key? key,
    required this.svgAssetLink,
    required this.title,
  }) : super(key: key);

  final String svgAssetLink;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60.w,
      child: Tab(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: CircleAvatar(
              radius: 50.w,
              backgroundColor: mainCatGreyColor.withOpacity(0.5),
              child: SvgPicture.asset(
                svgAssetLink,
              ),
            ),
          ),
          Text(
            title,
            maxLines: 1,
            style: mainStyle(
              12.0,
              FontWeight.w400,
            ),
          ),
        ],
      )),
    );
  }
}

class OrdersListView extends StatelessWidget {
  OrdersListView({
    Key? key,
    required this.ordersList,
    required this.localizationStrings,
  }) : super(key: key);

  final List<OrderItemModel> ordersList;
  final AppLocalizations? localizationStrings;
  late final List<GlobalKey> activeKeys;

  @override
  Widget build(BuildContext context) {
    var localizationStrings = AppLocalizations.of(context);
    var accountCubit = AccountCubit.get(context);
    List<AccountItemsModel> ordersMainItems = [
      AccountItemsModel(
          id: 0,
          apiOrderStatus: 'pending',
          svgImagePath: 'assets/images/account/my_orders/confirming.svg',
          title: localizationStrings!.pending),
      AccountItemsModel(
          id: 1,
          apiOrderStatus: 'processing',
          svgImagePath: 'assets/images/account/my_orders/processing.svg',
          title: localizationStrings!.processing),
      AccountItemsModel(
          id: 2,
          apiOrderStatus: 'ready_to_shipping',
          svgImagePath:
              'assets/images/account/my_orders/information_received.svg',
          title: localizationStrings!.ready_to_ship),
      AccountItemsModel(
          id: 3,
          apiOrderStatus: 'shipped',
          svgImagePath: 'assets/images/account/my_orders/shipped.svg',
          title: localizationStrings!.shipped),
      AccountItemsModel(
          id: 4,
          apiOrderStatus: 'out_for_delivery',
          svgImagePath: 'assets/images/account/my_orders/out_for_delivery.svg',
          title: localizationStrings!.out_for_delivery),
      AccountItemsModel(
          id: 5,
          apiOrderStatus: 'delivered',
          svgImagePath: 'assets/images/account/my_orders/delivered.svg',
          title: localizationStrings.delivered),
      // AccountItemsModel(
      //     id: 6,
      //     apiOrderStatus: 'returned',
      //     svgImagePath: 'assets/images/account/my_orders/refund.svg',
      //     title: localizationStrings.returned),
      // AccountItemsModel(
      //     id: 7,
      //     apiOrderStatus: 'failed',
      //     svgImagePath: 'assets/images/account/my_orders/failed.svg',
      //     title: localizationStrings.failed),
      // AccountItemsModel(
      //     id: 8,
      //     apiOrderStatus: 'canceled',
      //     svgImagePath: 'assets/images/account/my_orders/cancelled.svg',
      //     title: localizationStrings.canceled),
      // AccountItemsModel(
      //     id: 9,
      //     apiOrderStatus: 'canceled_archived',
      //     svgImagePath: 'assets/images/account/my_orders/archive.svg',
      //     title: localizationStrings.canceled_archived),
      // AccountItemsModel(
      //     id: 4,
      //     apiOrderStatus: 'returned',
      //     svgImagePath: 'assets/images/account/my_orders/refund.svg',
      //     title: localizationStrings.returned),
    ];
    activeKeys = List.generate(ordersList.length, (index) => GlobalKey());
    Widget widget = BlocConsumer<AccountCubit, AccountStates>(
  listener: (context, state) {
    if(state is CancelOrderReturnRequestFailure){
      showTopModalSheetErrorMessage(context, localizationStrings.something_went_wrong);
    }
    if(state is CancelOrderReturnRequestSuccess){
      showTopModalSheetErrorMessage(context, localizationStrings.canceled_successfully);
    }
  },
  builder: (context, state) {
    return ListView.separated(
      itemCount: ordersList.length,
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) => Container(
        color: index.isOdd ? Colors.grey.withOpacity(0.1) : Colors.white,
        child: Row(
          children: [
            SizedBox(
              width: 10.w,
            ),
            Expanded(
              // width: 180.w,
              child: Column(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 15.h,
                      ),
                      Text(
                        localizationStrings.orderSummary,
                        style: mainStyle(16.0, FontWeight.w600),
                      ),
                      10.verticalSpace,
                      ordersList[index].paymentStatus == 'paid'
                          ? RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                    text: '\n' +
                                        localizationStrings.paymentStatus +
                                        ordersList[index]
                                            .paymentStatus
                                            .toString(),
                                    style: mainStyle(12.w, FontWeight.w400,
                                        color: Colors.green)),
                              ]),
                            )
                          : const SizedBox.shrink(),
                      SizedBox(
                        height: 15.h,
                      ),
                      TableTwoValues(
                          mainKey: localizationStrings.orderAmount,
                          value: ordersList[index].orderAmount?.toString() ??
                              '--'),
                      10.verticalSpace,
                      TableTwoValues(
                          mainKey: localizationStrings.paymentMethod,
                          value: getCachedLocal() == 'en'
                              ? ordersList[index].paymentMethod.toString()
                              : (ordersList[index].paymentMethod ==
                                      'cash_on_delivery'
                                  ? 'دفع عند التوصيل'
                                  : ordersList[index]
                                      .paymentMethod
                                      .toString())),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TableTwoValues(
                                mainKey: localizationStrings.orderUniqueId,
                                value: ordersList[index].orderGroupId ?? '--'),
                          ),
                          SizedBox(
                            width: 3.w,
                          ),
                          IconButton(
                            color: Colors.transparent,
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text: ordersList[index].orderGroupId));
                              makeToastError(
                                  message: localizationStrings.lbl_copy);
                            },
                            icon: Icon(
                              Icons.copy,
                              color: primaryColor,
                              size: 15.w,
                            ),
                          ),
                        ],
                      ),
                      // TableTwoValues(
                      //     mainKey: localizationStrings.paymentMethod2,
                      //     value: ordersList[index].paymentMethod ?? '--'),
                      // TableTwoValues(
                      //     mainKey: localizationStrings.paymentStatus,
                      //     value: ordersList[index].paymentStatus ?? '--'),
                      // TableTwoValues(
                      //     mainKey: 'Discount amount:',
                      //     value: ordersList[index]
                      //             .discountAmount
                      //             ?.toString() ??
                      //         '--'),
                      // TableTwoValues(
                      //     mainKey: 'Shipping cost:',
                      //     value:
                      //         ordersList[index].shippingCost?.toString() ??
                      //             '--'),

                      ordersList[index].id.toString() ==
                              accountCubit.currentOrderDetailsViewId
                          ? Column(
                              //view details
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // shipping addresses
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 28.0),
                                  child: Divider(
                                    color: primaryColor,
                                  ),
                                ),
                                ConditionalBuilder(
                                  condition:
                                      ordersList[index].shippingAddressData !=
                                          null,
                                  builder: (context) => Column(
                                    children: [
                                      Text(
                                        localizationStrings.shippingDetails,
                                        style: mainStyle(16.0, FontWeight.w600),
                                      ),
                                      SizedBox(
                                        height: 15.h,
                                      ),
                                      TableTwoValues(
                                          mainKey: localizationStrings
                                              .shippingContact,
                                          value: ordersList[index]
                                                  .shippingAddressData!
                                                  .contactPersonName ??
                                              '--'),
                                      TableTwoValues(
                                          mainKey: localizationStrings
                                              .shippingAddress,
                                          value: ordersList[index]
                                                  .shippingAddressData!
                                                  .address ??
                                              '--'),
                                      TableTwoValues(
                                          mainKey: localizationStrings
                                              .shippingContactNum,
                                          value: ordersList[index]
                                                  .shippingAddressData!
                                                  .phone ??
                                              '--'),
                                    ],
                                  ),
                                  fallback: (context) => SizedBox(),
                                ),

                                // end shipping addresses

                                // order products
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 28.0),
                                  child: Divider(
                                    color: primaryColor,
                                  ),
                                ),
                                Text(
                                  localizationStrings.shippingOrdered,
                                  style: mainStyle(16.0, FontWeight.w600),
                                ),
                                SizedBox(
                                  height: 15.h,
                                ),
                                ListView.separated(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, innerIndex) {
                                      return OrderProductItem(
                                          isAvailableToEvaluate: [
                                            'out_of_delivery',
                                            'shipped',
                                            'ready_to_shipping'
                                          ].contains(
                                              ordersList[index].orderStatus),
                                          isOrderCancelled: ordersList[index]
                                                      .orderStatus ==
                                                  'canceled' ||
                                              ordersList[index].orderStatus ==
                                                  'canceled_archived',
                                          deliveryStatus: ordersList[index]
                                              .orderStatus
                                              .toString(),
                                          paymentStatus: ordersList[index]
                                              .paymentStatus
                                              .toString(),
                                          orderProductDetail: ordersList[index]
                                              .details![innerIndex]);
                                    },
                                    separatorBuilder: (context, innerIndex) =>
                                        const Divider(),
                                    itemCount:
                                        ordersList[index].details!.length),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 28.0),
                                  child: Divider(
                                    color: primaryColor,
                                  ),
                                ),

                                // ListView.separated(
                                //   itemBuilder: itemBuilder,
                                //   separatorBuilder: separatorBuilder,
                                //   itemCount: itemCount,
                                // )
                              ],
                            )
                          : const SizedBox(),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),

                  // Row(
                  //   children: [
                  //     Text(ordersList[index].orderStatus.toString()),
                  //     // Text(ordersMainItems[index]
                  //     //     .apiOrderStatus
                  //     //     .toString()),
                  //   ],
                  // ),
                  (ordersList[index].orderStatus != 'canceled' &&
                          ordersList[index].orderStatus !=
                              'canceled_archived' &&
                          ordersList[index].orderStatus != 'returned' &&
                          ordersList[index].orderStatus != 'partial_return' &&
                          ordersList[index].orderStatus != 'failed')
                      ? DefaultContainer(
                          height: 75.w,
                          borderColor: Colors.transparent,
                          childWidget: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.0.w, vertical: 3.h),
                            child: Center(
                              child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  // shrinkWrap: true,
                                  itemCount: ordersMainItems.length,
                                  scrollDirection: Axis.horizontal,
                                  separatorBuilder: (context, index) => Center(
                                        child: SizedBox(
                                          width: 18.w,
                                          child: Center(
                                            child: Text(
                                              '-->',
                                              style: mainStyle(
                                                  16.0, FontWeight.w900,
                                                  color: primaryColor),
                                            ),
                                          ),
                                        ),
                                      ),
                                  itemBuilder: (context, innerIndex) =>
                                      // buildArticleItem(model.data, context),
                                      NewOrderTab(
                                        key: ordersMainItems[innerIndex]
                                                    .apiOrderStatus
                                                    .toString() ==
                                                ordersList[index]
                                                    .orderStatus
                                                    .toString()
                                            ? activeKeys[index]
                                            : null,
                                        svgAssetLink:
                                            ordersMainItems[innerIndex]
                                                .svgImagePath,
                                        title:
                                            ordersMainItems[innerIndex].title,
                                        isSelected: ordersMainItems[innerIndex]
                                                .apiOrderStatus
                                                .toString() ==
                                            ordersList[index]
                                                .orderStatus
                                                .toString(),
                                      )
                                  // MainAccountHeaderItem(
                                  //   title: ordersMainItems[index].title,
                                  //   imagePath: ordersMainItems[index].svgImagePath,
                                  // ),
                                  ),
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                  ordersList[index].orderStatus == 'canceled'
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                              localizationStrings.order_cancelled_by_seller),
                        )
                      : const SizedBox(),
                  ordersList[index].orderStatus == 'canceled_archived'
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                              localizationStrings.order_cancelled_and_archived),
                        )
                      : const SizedBox(),
                  ordersList[index].orderStatus == 'returned'
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(localizationStrings.this_order_returned),
                        )
                      : const SizedBox(),
                  ordersList[index].orderStatus == 'partial_return'
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                              localizationStrings.this_order_partial_returned),
                        )
                      : const SizedBox(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () {
                            setCurrentAction(
                                buttonName: '(View/Hide)OrderDetailsButton');
                            if (ordersList[index].id.toString() !=
                                accountCubit.currentOrderDetailsViewId) {
                              accountCubit.changeCurrentOrderDetailsViewId(
                                  ordersList[index].id.toString());
                            } else {
                              logg('er log');
                              accountCubit.changeCurrentOrderDetailsViewId('0');
                            }
                          },
                          child: Text(
                            ordersList[index].id.toString() !=
                                    accountCubit.currentOrderDetailsViewId
                                ? localizationStrings.viewDetails
                                : localizationStrings.hideDetails,
                            style: mainStyle(16.0, FontWeight.w600,
                                color: ordersList[index].id.toString() !=
                                        accountCubit.currentOrderDetailsViewId
                                    ? primaryColor
                                    : Colors.red),
                          )),
                      // TextButton(
                      //     onPressed: () {
                      //       accountCubit
                      //           .changeCurrentOrderDetailsViewId('0');
                      //     },
                      //     child: Text('Hide details')),
                      (ordersList[index].paymentStatus == 'paid' &&
                              !returnMoneyWithWallet)
                          ? const SizedBox.shrink()
                          : orderStatusCanCancelled
                                  .contains(ordersList[index].orderStatus)
                              ? TextButton(
                                  onPressed: () {
                                    setCurrentAction(
                                        buttonName: 'CancelOrderButton');
                                    if (ordersList[index].paymentStatus ==
                                            'paid' &&
                                        returnMoneyWithWallet) {
                                      myAlertDialog(context,
                                          localizationStrings.cancelOrder,
                                          dismissible: false,
                                          withCancelButton: true,
                                          alertDialogContent:
                                              CancelOrderConfirmation(
                                            orderId: ordersList[index].id!,
                                          ));
                                    } else if (ordersList[index]
                                            .paymentStatus !=
                                        'paid') {
                                      myAlertDialog(context,
                                          localizationStrings.cancelOrder,
                                          alertDialogContent: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                height: 25.h,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          if (!accountCubit
                                                              .cancellingOrder) {
                                                            accountCubit
                                                                .cancelOrder(
                                                                    ordersList[
                                                                            index]
                                                                        .id
                                                                        .toString())
                                                                .then((value) =>
                                                                    Navigator.pop(
                                                                        context));
                                                          }
                                                        },
                                                        child: DefaultContainer(
                                                          height: 50.h,
                                                          borderColor:
                                                              Colors.red,
                                                          childWidget: Center(
                                                            child: Text(
                                                                localizationStrings
                                                                    .yes),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: DefaultContainer(
                                                          borderColor:
                                                              Colors.green,
                                                          height: 50.h,
                                                          childWidget: Center(
                                                            child: Text(
                                                                localizationStrings
                                                                    .no),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          ));
                                    }
                                  },
                                  child: Text(
                                    localizationStrings.cancelOrder,
                                    style: mainStyle(16.0, FontWeight.w600,
                                        color: primaryColor),
                                  ))
                              : const SizedBox.shrink(),
                    ],
                  ),
                  if (ordersList[index].orderCanReturn) ...{
                    10.verticalSpace,
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        8.verticalSpace,
                        // if (!expired &&
                        //     orderProductDetail.hasRefundRequest == 0 &&
                        //     returnMoneyWithWallet &&
                        //     deliveryStatus == 'delivered') ...{
                        !ordersList[index].orderHasReturnRequest
                            ? DefaultButton(
                                title: localizationStrings.add_return_request,
                                onClick: () {
                                  setCurrentAction(
                                      buttonName: 'AddReturnRequestButton');
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ReturnRequestLayout(
                                                orderDetails:
                                                    ordersList[index].details,
                                                returnRequestId:
                                                    ordersList[index]
                                                        .returnRequestId,
                                                isForEdit: false,
                                              )));
                                },
                              )
                            : ordersList[index].editReturnRequest
                                ? Column(
                                  children: [
                                    DefaultButton(
                                        title:
                                            localizationStrings.edit_return_request,
                                        onClick: () {
                                          setCurrentAction(
                                              buttonName:
                                                  'EditReturnRequestButton');
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      ReturnRequestLayout(
                                                        orderDetails:
                                                            ordersList[index]
                                                                .details,
                                                        returnRequestId:
                                                            ordersList[index]
                                                                .returnRequestId,
                                                        isForEdit: true,
                                                      )));
                                        },
                                      ),
                                    8.verticalSpace,
                                    state is CancelOrderReturnRequestLoading
                                        ? const Center(
                                      child: DefaultLoader(),
                                    )
                                        : DefaultButton(
                                      title: localizationStrings
                                          .cancel_return_request,
                                      onClick: () {
                                        setCurrentAction(
                                            buttonName:
                                            'CancelReturnRequestButton');
                                        accountCubit.cancelOrderReturnRequest(
                                            ordersList[index].returnRequestId);
                                      },
                                    ),
                                  ],
                                )
                                : DefaultButton(
                                    title: localizationStrings
                                        .lbl_view_return_request,
                                    onClick: () {
                                      setCurrentAction(
                                          buttonName:
                                              'showReturnRequestButton');
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>  ReturnRequestDetailsLayout(returnRequestId: ordersList[index].returnRequestId.toString(),)));
                                    },
                                  ),
                        8.verticalSpace,
                        // if (!expired &&
                        //     returnMoneyWithWallet &&
                        //     deliveryStatus == 'delivered') ...{
                        if(ordersList[index].orderCanExchange ?? false)...{
                          SizedBox(
                            child: DefaultButton(
                              title: localizationStrings.lbl_exchange,
                              onClick: () {
                                setCurrentAction(
                                    buttonName: 'ExchangeItemButton');
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (
                                        _) => const ChooseProductsForExchange()));
                              },
                            ),
                          ),
                          8.horizontalSpace,
                        }
                      ],
                    ),
                  } else ...{
                    ordersList[index].showReturnRequest
                        ? DefaultButton(
                            title: localizationStrings.lbl_view_return_request,
                            onClick: () {
                              setCurrentAction(
                                  buttonName: 'showReturnRequestButton');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>  ReturnRequestDetailsLayout(returnRequestId: ordersList[index].returnRequestId.toString(),)));
                            },
                          )
                        : const SizedBox.shrink(),
                  },
                  10.verticalSpace,
                ],
              ),
            ),
            SizedBox(
              width: 15.w,
            ),
          ],
        ),
      ),
      //
      //
      scrollDirection: Axis.vertical,
      separatorBuilder: (context, index) => SizedBox(
        height: 0.h,
      ),
    );
  },
);
    return BlocConsumer<AccountCubit, AccountStates>(
        listener: (context, state) {
      if (state is ProductQuantityChanged) {
        accountCubit.currentOrderDetailsViewId = '0';
        accountCubit.getOrders();
        showTopModalSheetErrorMessage(
            context,
            state.isProductRemoved
                ? localizationStrings.removed_successfully
                : localizationStrings.quantity_changed_successfully);
      }
    }, builder: (context, state) {
      if (state is! AddressTypeChanged) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          for (int i = 0; i < activeKeys.length; i++) {
            Scrollable.ensureVisible(
                activeKeys[activeKeys.length - i - 1].currentContext ?? context,
                alignment: 0);
          }
        });
      }
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ConditionalBuilder(
          condition: ordersList.isNotEmpty,
          builder: (context) {
            return widget;
          },
          fallback: (context) => const EmptyError(),
        ),
      );
    });
  }
}

class NewOrderTab extends StatelessWidget {
  NewOrderTab({
    Key? key,
    required this.svgAssetLink,
    required this.title,
    required this.isSelected,
  }) : super(key: key);

  final String svgAssetLink;
  final String title;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 75.w,
      child: DefaultContainer(
        borderColor: isSelected ? primaryColor : Colors.transparent,
        backColor:
            isSelected ? primaryColor.withOpacity(0.03) : Colors.transparent,
        childWidget: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SvgPicture.asset(
              svgAssetLink,
              height: 30.h,
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: mainStyle(
                12.0,
                FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderProductItem extends StatelessWidget {
  const OrderProductItem(
      {Key? key,
      required this.orderProductDetail,
      required this.isOrderCancelled,
      required this.deliveryStatus,
      required this.paymentStatus,
      required this.isAvailableToEvaluate})
      : super(key: key);
  final OrderDetail orderProductDetail;
  final String deliveryStatus;
  final String paymentStatus;
  final bool isAvailableToEvaluate;
  final bool isOrderCancelled;

  @override
  Widget build(BuildContext context) {
    var localizationStrings = AppLocalizations.of(context);
    var commentController = TextEditingController();
    logg('paymentStatus ' + orderProductDetail.paymentStatus.toString());
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              // width: 180.w,
              child: SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    orderProductDetail.qty! > 0 || isOrderCancelled
                        ? const SizedBox.shrink()
                        : Text(
                            localizationStrings!.this_product_removed,
                            style: mainStyle(14.0, FontWeight.w600,
                                color: Colors.red),
                          ),
                    Text(
                      orderProductDetail.productDetails!.name.toString(),
                      style: mainStyle(14.0, FontWeight.w600),
                    ),
                    Text(
                      orderProductDetail.variant!,
                      style: mainStyle(14.0, FontWeight.w200),
                    ),
/*
                          to view variant details key + value
                          if (variations != null)

                            SizedBox(
                              height: 30.h,
                              child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: variations.length,
                                  shrinkWrap: true,
                                  padding: EdgeInsets.all(0.0),
                                  itemBuilder: (context, index) => Row(
                                        children: [
                                          // Text(variations!.keys.toList()[index].toString()+': ',
                                          // style: mainStyle(14.0, FontWeight.w600),),
                                          // const Text(': '),

                                          Text(variations!.values.toList()[index].toString(),
                                          style: mainStyle(14.0, FontWeight.w400),),
                                        ],
                                      ), separatorBuilder: (BuildContext context, int index) {
                                    return Text('_'); },),
                            ),
*/
                    Row(
                      children: [
                        Text(
                          localizationStrings!.price + ': '.toString(),
                          style: mainStyle(14.0, FontWeight.w600),
                        ),
                        Text(
                          orderProductDetail.productDetails!.price.toString(),
                          textAlign: TextAlign.center,
                          style: mainStyle(14.0, FontWeight.w600,
                              fontFamily: 'poppins',
                              decoration: TextDecoration.lineThrough,
                              decorationThickness: 2),
                        ),
                        SizedBox(
                          width: 5.w,
                        ),
                        Text(
                          orderProductDetail.productDetails!.offerPrice
                              .toString(),
                          style: mainStyle(14.0, FontWeight.w600,
                              fontFamily: 'poppins'),
                        ),
                      ],
                    ),
                    orderProductDetail.qty! > 0
                        ? Text(
                            localizationStrings.quantity +
                                ' ' +
                                orderProductDetail.qty.toString(),
                            style: mainStyle(14.0, FontWeight.w600),
                          )
                        : const SizedBox.shrink(),
                    if ((orderStatusCanRemoved.contains(deliveryStatus) &&
                            !(paymentStatus == 'paid' &&
                                !returnMoneyWithWallet) &&
                            !isAvailableToEvaluate &&
                            orderProductDetail.qty! > 0 &&
                        !isOrderCancelled))...{
                      5.verticalSpace,
                      SizedBox(
                        width: 0.3.sw,
                        child: DefaultButton(
                          title: localizationStrings.remove,
                          onClick: () {
                            setCurrentAction(buttonName: 'RemoveItemButton');
                            myAlertDialog(
                              context,
                              '',
                              alertDialogContent: ChangeQuantityWidget(
                                orderId: orderProductDetail.orderId!,
                                detailsId: orderProductDetail.id!,
                                isPaid: paymentStatus == 'paid',
                              ),
                            );
                          },
                        ),
                      ),
                    },
                    // if (orderProductDetail.hasRefundRequest == 1 &&
                    //     returnMoneyWithWallet) ...{
                    //   SizedBox(
                    //     width: 0.5.sw,
                    //     child: DefaultButton(
                    //       title: localizationStrings.refund_details,
                    //       onClick: () {
                    //         Navigator.push(
                    //             context,
                    //             MaterialPageRoute(
                    //                 builder: (_) => RefundDetailsLayout(
                    //                       imageUrl: orderProductDetail
                    //                           .productDetails!.images![0],
                    //                       detailsId: orderProductDetail.id!,
                    //                       name: orderProductDetail
                    //                           .productDetails!.name!,
                    //                       variant: orderProductDetail.variant,
                    //                     )));
                    //       },
                    //     ),
                    //   ),
                    // }
                    // BlocBuilder<ProductDetailsCubit, product_state.ProductDetailsStates>(
                    //   builder: (context, state) => QuantitySection(
                    //       availableQuantity:
                    //       detailsData.flashDealDetails != null
                    //           ? detailsData.flashDealMaxAllowedQuantity
                    //           .toString()
                    //           : productDetailsCubit.updatedVariation != null
                    //           ? min(
                    //           productDetailsCubit
                    //               .updatedVariation!.qty!,
                    //           10)
                    //           .toString()
                    //           : productDetailsCubit.productDetailsModel!
                    //           .data!.currentStock
                    //           .toString()),
                    // ),
                    // Text(
                    //   '  localizationStrings.soldBy' +
                    //       '0',
                    //   style: mainStyle(14.0, FontWeight.w200),
                    // ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 10.w,
            ),
            DefaultImage(
              backGroundImageUrl: orderProductDetail.productDetails!.thumbnail,
              width: 80.w,
              height: 90.w,
              borderColor: Colors.transparent,
            ),
          ],
        ),
        isAvailableToEvaluate
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        var accountCubit = AccountCubit.get(context);
                        accountCubit.resetSelectedImages();
                        accountCubit.setCurrentEvaluatingProductId(
                            orderProductDetail.productDetails!.id.toString());
                        // final ImagePicker imagePicker=ImagePicker();
                        defaultAlertDialog(context, 'Add your review',
                            alertDialogContent:
                                BlocConsumer<AccountCubit, AccountStates>(
                              listener: (context, state) {},
                              builder: (context, state) =>
                                  SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      height: 15.h,
                                    ),
                                    RatingBar.builder(
                                      initialRating: 3,
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemPadding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      onRatingUpdate: (rating) {
                                        accountCubit.setNewRating(rating);
                                      },
                                    ),
                                    SizedBox(
                                      height: 25.h,
                                    ),
                                    DefaultContainer(
                                        height: 120.h,
                                        borderColor:
                                            primaryColor.withOpacity(0.5),
                                        childWidget: TextFormField(
                                          controller: commentController,
                                          style:
                                              mainStyle(16.0, FontWeight.w300),
                                          obscureText: false,
                                          maxLines: null,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.all(10.h),
                                            // icon: Icon(Icons.send),
                                            hintText:
                                                'We are looking to hearing from you..',

                                            hintStyle: mainStyle(
                                                14.0, FontWeight.w300),
                                            // helperText: 'Helper Text',
                                            // counterText: '0 characters',
                                            border: InputBorder.none,
                                          ),
                                        )),
                                    SizedBox(
                                      height: 15.h,
                                    ),
                                    // ConditionalBuilder(
                                    //   condition:
                                    //       accountCubit.imageFiles!.isNotEmpty,
                                    //   builder: (context) => SizedBox(
                                    //     // color: Colors.grey.withOpacity(0.5),
                                    //     height: 120.w,
                                    //     width: 200.w,
                                    //     child: ListView.separated(
                                    //       physics: BouncingScrollPhysics(),
                                    //       itemCount:
                                    //           accountCubit.imageFiles!.length,
                                    //       scrollDirection: Axis.horizontal,
                                    //       shrinkWrap: true,
                                    //       itemBuilder: (context, index) =>
                                    //           Column(
                                    //         mainAxisAlignment:
                                    //             MainAxisAlignment.spaceEvenly,
                                    //         children: [
                                    //           DefaultContainer(
                                    //             height: 90.w,
                                    //             width: 90.w,
                                    //             borderColor: Colors.transparent,
                                    //             childWidget: Image.file(
                                    //                 File(accountCubit
                                    //                     .imageFiles![index]
                                    //                     .path),
                                    //                 fit: BoxFit.cover),
                                    //           ),
                                    //           GestureDetector(
                                    //             onTap: () {
                                    //               accountCubit.removePic(index);
                                    //             },
                                    //             child: DefaultContainer(
                                    //               borderColor:
                                    //                   Colors.transparent,
                                    //               height: 25.h,
                                    //               childWidget: Row(
                                    //                 mainAxisAlignment:
                                    //                     MainAxisAlignment
                                    //                         .spaceEvenly,
                                    //                 crossAxisAlignment:
                                    //                     CrossAxisAlignment.end,
                                    //                 children: [
                                    //                   Icon(
                                    //                     Icons.delete,
                                    //                     color: Colors.red,
                                    //                   ),
                                    //                   Text(
                                    //                     'Remove',
                                    //                     style: mainStyle(14.0,
                                    //                         FontWeight.w200),
                                    //                   ),
                                    //                 ],
                                    //               ),
                                    //             ),
                                    //           )
                                    //         ],
                                    //       ),
                                    //       separatorBuilder: (context, index) =>
                                    //           SizedBox(),
                                    //     ),
                                    //   ),
                                    //   fallback: (_) => const SizedBox(),
                                    // ),
                                    SizedBox(
                                      height: 15.h,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        accountCubit.openImages();
                                      },
                                      child: DefaultContainer(
                                        borderColor:
                                            primaryColor.withOpacity(0.5),
                                        height: 35.h,
                                        childWidget: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Upload pictures',
                                              style: mainStyle(
                                                  12.0, FontWeight.w400),
                                            ),
                                            SizedBox(
                                              width: 10.w,
                                            ),
                                            SvgPicture.asset(
                                                'assets/images/public/icons8_upload_to_cloud.svg')
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    DefaultButton(
                                        onClick: () {
                                          accountCubit.sendAndSaveReview(
                                              commentController.text);
                                        },
                                        title: 'Save review',
                                        backColor: primaryColor,
                                        borderColors: Colors.transparent,
                                        customHeight: 35.h,
                                        titleColor: Colors.white),
                                    // RatingBarIndicator(
                                    //   rating: 4.0,
                                    //   itemBuilder: (context, index) => Icon(
                                    //     Icons.star,
                                    //     color: mainGreenColor,
                                    //   ),
                                    //   itemCount: 5,
                                    //   itemSize: 20.0.sp,
                                    //   direction: Axis.horizontal,
                                    // )
                                  ],
                                ),
                              ),
                            ));
                      },
                      child: Text(
                        'Add your review for this product',
                        style: mainStyle(14.0, FontWeight.w600,
                            color: primaryColor),
                      ))
                ],
              )
            : SizedBox()
      ],
    );
  }
}
