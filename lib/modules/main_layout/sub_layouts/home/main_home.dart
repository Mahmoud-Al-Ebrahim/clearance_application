import 'package:clearance/core/error_screens/errors_screens.dart';
import 'package:clearance/core/main_cubits/states_main.dart' as main_states;
import 'package:clearance/core/network/dio_helper.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/cubit/account_cubit.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/cubit/account_state.dart';
import 'package:clearance/modules/main_layout/sub_layouts/cart/cart_screen.dart';
import 'package:clearance/modules/main_layout/sub_layouts/categories/cubit/cubit_categories.dart';
import 'package:clearance/modules/main_layout/sub_layouts/categories/cubit/states_categories.dart';
import 'package:clearance/modules/main_layout/sub_layouts/collection/collection_layout.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:convert' as convert;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:clearance/core/main_cubits/cubit_main.dart';
import 'package:clearance/core/shared_widgets/shared_widgets.dart';
import 'package:clearance/models/api_models/home_Section_model.dart';
import 'package:clearance/modules/main_layout/sub_layouts/home/widgets/home_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/cache/cache.dart';
import '../../../../core/constants/startup_settings.dart';
import '../../../../core/constants/networkConstants.dart';
import '../../../../core/error_screens/show_error_message.dart';
import '../../../../core/main_functions/main_funcs.dart';
import '../../../../core/shimmer/main_shimmers.dart';
import '../../../../core/styles_colors/styles_colors.dart';
import '../../../auth_screens/cubit/cubit_auth.dart';
import '../brand_products/brand_products/brand_products_cubit.dart';
import '../categories/sub_sub_category_layout/sub_sub_category_layout.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({Key? key}) : super(key: key);

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  final scrollController = ScrollController();
  final homeScrollController = ScrollController();

  @override
  void initState() {
    scrollController.addListener(pagination);
    homeScrollController.addListener(homePagination);
    homeScrollController.addListener(() {
      print('loading');
      MainCubit.get(context).lazyLoading(homeScrollController);
    });
    AccountCubit.get(context)..getRefundReasons()..getPaymentDestinations();
    setCurrentScreen(screenName: 'MainHomeScreen');
    super.initState();
  }

  void pagination() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent / 1.1 &&
        BrandProductsCubit.get(context).state is! LoadingBrandProductsState &&
        BrandProductsCubit.get(context).brandProductsModel!.totalSize !=
            BrandProductsCubit.get(context).products.length) {
      logg('productsScrollController.position.pixels>='
          'productsScrollController.position.maxScrollExtent/1.5');
      logg('totalsize: ' +
          BrandProductsCubit.get(context)
              .brandProductsModel!
              .totalSize
              .toString());
      logg('current product list length: ' +
          BrandProductsCubit.get(context).products.length.toString());
      BrandProductsCubit.get(context)
          .getBrandProducts(resourceId: '27', resourceType: 'brand');
    }
  }

  final ValueNotifier<bool> showFloatingActionButton = ValueNotifier(false);
  final ValueNotifier<bool> showInviteFriendsBanner = ValueNotifier(true);

  void homePagination() {

    if (homeScrollController.position.pixels >= 0.5.sh) {
      showFloatingActionButton.value = true;
    } else {
      showFloatingActionButton.value = false;
    }
    if(MainCubit.get(context).currentSelectedHomeSectionIndex<0){
      return ;
    }
    if (!homeScrollController.hasClients) return;
    if (homeScrollController.position.maxScrollExtent >=
            (homeScrollController.offset * 0.5) &&
        CategoriesCubit.get(context).state
            is! LoadingFilteredCategoryProductsState &&
        (CategoriesCubit.get(context)
                .productsFilteredByCateModel
                ?.data
                ?.totalSize !=
            CategoriesCubit.get(context)
                .sectionProducts[
                    MainCubit.get(context).currentSelectedHomeSectionIndex]
                .length) &&
        MainCubit.get(context).currentSelectedHomeSectionIndex >= 0) {
      logg('productsScrollController.position.pixels>='
          'productsScrollController.position.maxScrollExtent/1.5');
      CategoriesCubit.get(context).getFilteredCategoryProducts(
          MainCubit.get(context)
              .homeSectionModel!
              .data![MainCubit.get(context).currentSelectedHomeSectionIndex]
              .id
              .toString(),
          getCachedToken(),
          context: context,
          sectionIndex: MainCubit.get(context).currentSelectedHomeSectionIndex,
          pageNumber: MainCubit.get(context).pageNumberForSections[
              MainCubit.get(context).currentSelectedHomeSectionIndex],
          pagination: true);
    }
  }

  final scrollingKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    lastScreen = 'MainHomeScreen';
    WidgetsFlutterBinding.ensureInitialized();
    var mainCubit = MainCubit.get(context)..getLocalHomeSectionData(context);
    var authCubit = AuthCubit.get(context);
    var categoriesCubit = CategoriesCubit.get(context);
    var localizationsString = AppLocalizations.of(context);
    return BlocConsumer<MainCubit, main_states.MainStates>(
      listener: (context, state) {
        if (state is main_states.DataLoadedSuccessState ||
            state is main_states.ErrorLoadingDataState) {
          if (showWhatsAppContact!) {
            AccountCubit.get(context).getContactUsInformation();
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          extendBodyBehindAppBar: true,
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
          floatingActionButton: ValueListenableBuilder<bool>(
              valueListenable: showFloatingActionButton,
              builder: (context, show, _) {
                return Visibility(
                  visible: show,
                  child: Transform.translate(
                    offset: Offset(0, -20.h),
                    child: FloatingActionButton(
                      onPressed: () {
                        setCurrentAction(buttonName: 'ScrollUpButton');
                        homeScrollController.position.ensureVisible(
                          scrollingKey.currentContext!.findRenderObject()!,
                          alignment: 0,
                          // How far into view the item should be scrolled (between 0 and 1).
                          duration: const Duration(seconds: 1),
                        );
                      },
                      backgroundColor: primaryColor,
                      focusColor: Colors.transparent,
                      child: Icon(
                        Icons.arrow_upward,
                        color: mainBackgroundColor,
                      ),
                    ),
                  ),
                );
              }),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(56.0.h),
            child: BlocBuilder<MainCubit, main_states.MainStates>(
              builder: (context, state) {
                return SearchAppBar(
                    customCateId: null, isBackButtonEnabled: false);
              },
            ),
          ),
          body: RefreshIndicator(
            color: mainBackgroundColor,
            backgroundColor: primaryColor,
            triggerMode: RefreshIndicatorTriggerMode.onEdge,
            onRefresh: () async {
              logg('refresh');
              setCurrentAction(buttonName: 'RefreshHomeButton');
              mainCubit.getConfigData();
              mainCubit.getBanners();
              mainCubit.getHomeSection(context);
              categoriesCubit.loadCategories();
            },
            child: Stack(
              alignment: getCachedLocal() == 'en'
                  ? Alignment.bottomLeft
                  : Alignment.bottomRight,
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: homeScrollController,
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              ValueListenableBuilder<bool>(
                                valueListenable:showInviteFriendsBanner ,
                                builder: (context,show,_) {
                                  return Visibility(
                                      visible: (authCubit.userInfoModel!.data!.isVerifiedEmail == 1 ||
                                          authCubit.userInfoModel!.data!.isVerifiedPhone == 1 ||
                                          authCubit.verifiedNow) && authCubit.userInfoModel!.data!.canInviteFriends && show,
                                      child:  HomeGetContactsBanner(
                                        closeBanner: (){
                                          showInviteFriendsBanner.value=false;
                                        },
                                      ),);
                                }
                              ),
                              BlocConsumer<MainCubit, main_states.MainStates>(
                                listener: (context, state) {
                                  if (state is main_states
                                          .ChangeCurrentSelectedHomeSectionState &&
                                      !state.fromTop) {
                                    homeScrollController.position.ensureVisible(
                                      scrollingKey.currentContext!
                                          .findRenderObject()!,
                                      alignment: 1,
                                      // How far into view the item should be scrolled (between 0 and 1).
                                      duration: const Duration(seconds: 1),
                                    );
                                  }
                                },
                                builder: (context, state) => ConditionalBuilder(
                                  condition: mainCubit.homeSectionModel != null,
                                  builder: (context) =>
                                      MainHomeBodyWithoutFilter(
                                    mainCubit: mainCubit,
                                    key: scrollingKey,
                                  ),
                                  fallback: (context) => SizedBox(
                                      height: 0.8.sh,
                                      child:
                                          const Center(child: DefaultLoader())),
                                ),
                              ),
                            ],
                          ),
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
                      offset: Offset(
                          getCachedLocal() == 'en' ? 10.w : -10.w, -20.h),
                      child: Visibility(
                        visible: showWhatsAppContact ?? true,
                        child: InkWell(
                          onTap: () async {
                            setCurrentAction(buttonName: 'WhatsAppButton');
                            launchUrl(
                                Uri.parse(
                                    'https://wa.me/${AccountCubit.get(context).contactUsModel!.data!.whatsAppPhone}/?text=${Uri.parse(AccountCubit.get(context).contactUsModel!.data!.whatsappMessage ?? localizationsString!.lbl_whatsapp_message)}'),
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
          ),
        );
      },
    );
  }
}

class MainHomeBodyWithoutFilter extends StatefulWidget {
  const MainHomeBodyWithoutFilter({
    Key? key,
    required this.mainCubit,
  }) : super(key: key);

  final MainCubit mainCubit;

  @override
  State<MainHomeBodyWithoutFilter> createState() =>
      _MainHomeBodyWithoutFilterState();
}

class _MainHomeBodyWithoutFilterState extends State<MainHomeBodyWithoutFilter> {
  final scrollController = ScrollController();
  final tabsScrollController = ScrollController();
  final ValueNotifier<bool> showTabsScrollingButton = ValueNotifier(false);
  final scrollingKey = GlobalKey();

  @override
  void initState() {
    scrollController.addListener(pagination);
    tabsScrollController.addListener(() {
      if (!tabsScrollController.hasClients) return;
      showTabsScrollingButton.value =
          (tabsScrollController.position.maxScrollExtent > 2.sw);
    });
    super.initState();
  }

  void pagination() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent / 1.1 &&
        MainCubit.get(context).state
            is! main_states.LoadingFlashProductsState &&
        MainCubit.get(context).flashProductsModel!.totalSize !=
            MainCubit.get(context).products.length) {
      logg('productsScrollController.position.pixels>='
          'productsScrollController.position.maxScrollExtent/1.5');
      logg('totalsize: ' +
          MainCubit.get(context).flashProductsModel!.totalSize.toString());
      logg('current product list length: ' +
          MainCubit.get(context).products.length.toString());
      MainCubit.get(context).getFlashProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    var localizationStrings = AppLocalizations.of(context);
    return BlocConsumer<MainCubit, main_states.MainStates>(
      listener: (context, state) {},
      builder: (context, state) => Column(
        children: [
          ConditionalBuilder(
              condition: widget.mainCubit.homeSectionModel!.data != null,
              builder: (context) => SizedBox(
                    height: 50.h,
                    child: Row(
                      children: [
                        Visibility(
                          visible: showFlashDeals ?? false,
                          child: GestureDetector(
                            onTap: () {
                              setCurrentAction(
                                  buttonName:
                                      'ChangeHomeTabToFlashDealsButton');
                              widget.mainCubit
                                  .changeCurrentSelectedHomeSection(-1);
                              MainCubit.get(context).getFlashProducts();
                            },
                            child: Container(
                              height: 40.h,
                              margin: EdgeInsetsDirectional.only(start: 5.w),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                width: 2.h,
                                color: widget.mainCubit
                                            .currentSelectedHomeSectionIndex ==
                                        -1
                                    ? primaryColor
                                    : Colors.transparent,
                              ))),
                              child: Row(
                                children: [
                                  Text(
                                    localizationStrings!.flash_deal,
                                    style: mainStyle(15.0, FontWeight.w700,
                                        color: titleColor),
                                  ),
                                  Image.asset(
                                    'assets/images/thunder.gif',
                                    height: 20.h,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: showCollectionGrid ?? true,
                          child: GestureDetector(
                            onTap: () {
                              setCurrentAction(
                                  buttonName:
                                      'ChangeHomeTabToCollectionButton');
                              widget.mainCubit
                                  .changeCurrentSelectedHomeSection(-2);
                            },
                            child: Container(
                              height: 40.h,
                              margin: EdgeInsetsDirectional.only(start: 5.w),
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                width: 2.h,
                                color: widget.mainCubit
                                            .currentSelectedHomeSectionIndex ==
                                        -2
                                    ? primaryColor
                                    : Colors.transparent,
                              ))),
                              child: Center(
                                child: Text(
                                  localizationStrings.lbl_collection,
                                  style: mainStyle(15.0, FontWeight.w700,
                                      color: titleColor),
                                ),
                              ),
                            ),
                          ),
                        ),
                        5.horizontalSpace,
                        ValueListenableBuilder<bool>(
                            valueListenable: showTabsScrollingButton,
                            builder: (context, show, _) {
                              return Visibility(
                                visible: show,
                                child: InkWell(
                                  onTap: () {
                                    setCurrentAction(
                                        buttonName: 'ScrollRightButton');
                                    tabsScrollController.position.ensureVisible(
                                      scrollingKey.currentContext!
                                          .findRenderObject()!,
                                      alignment: 0,
                                      duration: const Duration(seconds: 1),
                                    );
                                  },
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 5.w),
                                    decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(6.r)),
                                    child: Icon(
                                      getCachedLocal() == 'en'
                                          ? Icons.keyboard_double_arrow_left
                                          : Icons.keyboard_double_arrow_right,
                                      size: 20.sp,
                                      color: mainBackgroundColor,
                                    ),
                                  ),
                                ),
                              );
                            }),
                        5.horizontalSpace,
                        Expanded(
                          child: ListView.builder(
                              shrinkWrap: false,
                              controller: tabsScrollController,
                              key: scrollingKey,
                              itemCount: widget
                                  .mainCubit.homeSectionModel!.data!.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (BuildContext context, int index) {
                                return GestureDetector(
                                  onTap: () {
                                    setCurrentAction(
                                        buttonName:
                                            'ChangeHomeTabTo${widget.mainCubit.homeSectionModel!.data![index].category!}Button');
                                    widget.mainCubit
                                        .changeCurrentSelectedHomeSection(
                                            index);
                                    CategoriesCubit.get(context)
                                      ..updateCatIndex(MainCubit.get(context)
                                          .homeSectionModel!
                                          .data![MainCubit.get(context)
                                              .currentSelectedHomeSectionIndex]
                                          .id
                                          .toString())
                                      ..resetFilters();
                                  },
                                  child: Container(
                                      height: 40.h,
                                      decoration: BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: widget.mainCubit
                                                            .currentSelectedHomeSectionIndex
                                                            .toString() ==
                                                        index.toString()
                                                    ? primaryColor
                                                    : Colors.transparent,
                                                width: 2.h)),
                                        color: Colors.white,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: Center(
                                          child: Text(
                                            widget.mainCubit.homeSectionModel!
                                                .data![index].category!,
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            maxLines: 3,
                                            style: mainStyle(
                                                15.0,
                                                widget.mainCubit
                                                            .currentSelectedHomeSectionIndex
                                                            .toString() ==
                                                        index.toString()
                                                    ? FontWeight.w700
                                                    : FontWeight.w400,
                                                color: Colors.black,
                                                textHeight: 1),
                                          ),
                                        ),
                                      )),
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
              fallback: (context) => SizedBox(
                    height: 50.h,
                    child: const Center(child: EmptyError()),
                  )),
          3.verticalSpace,
          if (widget.mainCubit.currentSelectedHomeSectionIndex == -1) ...{
            BlocConsumer<BrandProductsCubit, BrandProductsState>(
                listener: (context, state) {},
                builder: (context, state) {
                  logg('brand products state changed');
                  return Stack(
                    children: [
                      SizedBox(
                        height: 1.sh,
                        child: ConditionalBuilder(
                          condition:
                              MainCubit.get(context).flashProductsModel != null,
                          builder: (context) => SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              children: [
                                ProductsGridView(
                                  isInHome: false,
                                  crossAxisCount: 2,
                                  towByTowJustTitle: false,
                                  isInProductView: true,
                                  productsList: MainCubit.get(context).products,
                                ),
                                SizedBox(
                                  height: 120.h,
                                )
                              ],
                            ),
                          ),
                          fallback: (context) =>
                              const Center(child: DefaultLoader()),
                        ),
                      ),
                      state is LoadingBrandProductsState
                          ? Positioned(
                              bottom: 30.h,
                              child: SizedBox(
                                  width: 1.sw,
                                  child: Center(
                                      child: CircularProgressIndicator(
                                    color: primaryColor,
                                  ))))
                          : const SizedBox.shrink()
                    ],
                  );
                })
          },
          if (widget.mainCubit.currentSelectedHomeSectionIndex == -2) ...{
            ConditionalBuilder(
                condition: widget.mainCubit.banners != null,
                builder: (context) {
                  return HomeBannersSlider(
                    banners: widget.mainCubit.banners!,
                  );
                },
                fallback: (context) => ShimmerContainerWidget(
                      height: 190.h,
                    )),
            ListView.separated(
              separatorBuilder: (context, index) => Divider(
                thickness: 10.h,
              ),
              itemCount: widget.mainCubit.sections.length,
              padding: const EdgeInsets.all(0),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return CollectionLayout(
                    homeSection: widget.mainCubit.sections[index],
                    index: index);
              },
            ),
          },
          if (widget.mainCubit.currentSelectedHomeSectionIndex >= 0) ...{
            ConditionalBuilder(
              condition: widget
                  .mainCubit
                  .homeSectionModel!
                  .data![widget.mainCubit.currentSelectedHomeSectionIndex]
                  .subCategories!
                  .isNotEmpty,
              builder: (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      height: widget
                                  .mainCubit
                                  .homeSectionModel!
                                  .data![widget.mainCubit
                                      .currentSelectedHomeSectionIndex]
                                  .subCategories!
                                  .length <=
                              4
                          ? 150
                          : 280.w,
                      child: GridView.count(
                        physics: const BouncingScrollPhysics(),
                        crossAxisCount: widget
                                    .mainCubit
                                    .homeSectionModel!
                                    .data![widget.mainCubit
                                        .currentSelectedHomeSectionIndex]
                                    .subCategories!
                                    .length <=
                                4
                            ? 1
                            : 2,
                        childAspectRatio: widget
                                    .mainCubit
                                    .homeSectionModel!
                                    .data![widget.mainCubit
                                        .currentSelectedHomeSectionIndex]
                                    .subCategories!
                                    .length <=
                                4
                            ? 130.w / 85.w
                            : 110.w / 75.w,
                        padding: const EdgeInsets.all(0),
                        shrinkWrap: true,
                        mainAxisSpacing: 1.h,
                        crossAxisSpacing: 1.w,
                        scrollDirection: Axis.horizontal,
                        children: List.generate(
                            widget
                                .mainCubit
                                .homeSectionModel!
                                .data![widget
                                    .mainCubit.currentSelectedHomeSectionIndex]
                                .subCategories!
                                .length,
                            (index) => GestureDetector(
                                  onTap: () async {
                                    logg(AuthCubit.get(context)
                                        .userInfoModel!
                                        .data!
                                        .id
                                        .toString());
                                    await FirebaseAnalytics.instance.logEvent(
                                        name: 'category_tracking',
                                        parameters: {
                                          'userID': AuthCubit.get(context)
                                              .userInfoModel!
                                              .data!
                                              .id
                                              .toString(),
                                          'category_id': widget
                                              .mainCubit
                                              .homeSectionModel!
                                              .data![widget.mainCubit
                                                  .currentSelectedHomeSectionIndex]
                                              .subCategories![index]
                                              .id
                                              .toString(),
                                          'category_name': widget
                                              .mainCubit
                                              .homeSectionModel!
                                              .data![widget.mainCubit
                                                  .currentSelectedHomeSectionIndex]
                                              .subCategories![index]
                                              .name,
                                          'server': baseLink.contains('www')
                                              ? 'production'
                                              : 'staging',
                                          'server_url': baseLink
                                        });
                                    navigateToWithNavBar(
                                        context,
                                        SubSubCategoryLayout(
                                          cateId: widget
                                              .mainCubit
                                              .homeSectionModel!
                                              .data![widget.mainCubit
                                                  .currentSelectedHomeSectionIndex]
                                              .subCategories![index]
                                              .id!
                                              .toString(),
                                        ),
                                        SubSubCategoryLayout.routeName);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: DefaultImage(
                                            height: !showSubCategoryTitle
                                                ? 100.w
                                                : 80.w,
                                            width: 100.w,
                                            borderColor: Colors.transparent,
                                            backGroundImageUrl: widget
                                                .mainCubit
                                                .homeSectionModel!
                                                .data![widget.mainCubit
                                                    .currentSelectedHomeSectionIndex]
                                                .subCategories![index]
                                                .icon,
                                            boxFit: BoxFit.contain,
                                          ),
                                        ),
                                        showSubCategoryTitle
                                            ? Text(
                                                widget
                                                    .mainCubit
                                                    .homeSectionModel!
                                                    .data![widget.mainCubit
                                                        .currentSelectedHomeSectionIndex]
                                                    .subCategories![index]
                                                    .name
                                                    .toString(),
                                                textAlign: TextAlign.center,
                                                style: mainStyle(
                                                    14, FontWeight.w400),
                                              )
                                            : const SizedBox.shrink()
                                      ],
                                    ),
                                  ),
                                )),
                      )),
                ],
              ),
              fallback: (context) => const EmptyError(),
            ),
            ConditionalBuilder(
                condition: widget.mainCubit.banners != null,
                builder: (context) {
                  return HomeBannersSlider(
                    banners: widget.mainCubit.banners!,
                  );
                },
                fallback: (context) => ShimmerContainerWidget(
                      height: 190.h,
                    )),
            ConditionalBuilder(
                condition: widget
                    .mainCubit
                    .homeSectionModel!
                    .data![widget.mainCubit.currentSelectedHomeSectionIndex]
                    .sections!
                    .isNotEmpty,
                builder: (context) => HomeSectionsMainView(
                      homeGroups: widget
                          .mainCubit
                          .homeSectionModel!
                          .data![
                              widget.mainCubit.currentSelectedHomeSectionIndex]
                          .sections!,
                    ),
                fallback: (context) => EmptyError()),
            SizedBox(
              height: 10.h,
            ),
            BlocBuilder<CategoriesCubit, CategoriesStates>(
                builder: (context, state) {
              return ProductsGridView(
                isInHome: false,
                crossAxisCount: 2,
                towByTowJustTitle: false,
                isInProductView: true,
                showNoProductsMessage: false,
                productsList: CategoriesCubit.get(context).sectionProducts[
                    widget.mainCubit.currentSelectedHomeSectionIndex],
              );
            }),
            BlocBuilder<CategoriesCubit, CategoriesStates>(
              builder: (context, state) {
                if (state is LoadingFilteredCategoryProductsState) {
                  return CircularProgressIndicator(
                    color: primaryColor,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          }
        ],
      ),
    );
  }
}

class HomeSectionsMainView extends StatelessWidget {
  const HomeSectionsMainView({
    Key? key,
    required this.homeGroups,
    this.frontColor,
    this.backColor,
  }) : super(key: key);

  final List<Section> homeGroups;
  final Color? backColor;
  final Color? frontColor;

  @override
  Widget build(BuildContext context) {
    return ConditionalBuilder(
        condition: homeGroups.isNotEmpty,
        builder: (context) {
          return HomeCategoriesBody(
            homeGroups: homeGroups,
            backColor: backColor,
            frontColor: frontColor,
          );
        },
        fallback: (context) => const DefaultLoader());
  }
}
