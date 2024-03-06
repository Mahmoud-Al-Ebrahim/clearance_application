import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:clearance/core/cache/cache.dart';
import 'package:clearance/core/error_screens/errors_screens.dart';
import 'package:clearance/core/error_screens/show_error_message.dart';
import 'package:clearance/core/main_cubits/cubit_main.dart';
import 'package:clearance/core/main_cubits/search_cubit.dart';
import 'package:clearance/core/main_cubits/states_main.dart';
import 'package:clearance/core/styles_colors/styles_colors.dart';
import 'package:clearance/models/api_models/banners_model.dart';
import 'package:clearance/modules/main_layout/sub_layouts/cart/cart_screen.dart';
import 'package:clearance/modules/main_layout/sub_layouts/categories/sub_sub_category_layout/sub_sub_category_layout.dart';
import 'package:clearance/modules/main_layout/sub_layouts/product_details/product_details_layout.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:clearance/core/constants/startup_settings.dart';
import 'package:clearance/core/main_functions/main_funcs.dart';
import 'package:clearance/models/api_models/config_model.dart' as config;
import 'package:permission_handler/permission_handler.dart';

import '../../../../../core/shared_widgets/shared_widgets.dart';
import '../../../../../models/api_models/home_Section_model.dart';
import '../../brand_products/brand_products_layout.dart';
import '../../categories/category_detailed_layout/category_detailed_layout.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeBannersSlider extends StatelessWidget {
  HomeBannersSlider({Key? key, required this.banners}) : super(key: key);
  final List<BannerItem> banners;
  final ValueNotifier<int> rebuildImage = ValueNotifier(0);

  String currentUrl = '';
  bool enable = true;

  Widget getErrorImageWidget() {
    return Center(
        child: GestureDetector(
      onTap: () async {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          currentUrl = '';
          enable = true;
          rebuildImage.value++;
        });
      },
      child: Icon(Icons.refresh, color: primaryColor, size: 30.sp),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 170.h,
        initialPage: 0,
        pauseAutoPlayOnTouch: true,
        viewportFraction: 1,
        enableInfiniteScroll: false,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(seconds: 1),
        autoPlayCurve: Curves.fastOutSlowIn,
        scrollDirection: Axis.horizontal,
      ),
      items: banners.map((e) {
        return GestureDetector(
          onTap: () {
            setCurrentAction(buttonName: 'PressBannerButton');
            logg('resource type: ' + e.resourceType!);
            e.resourceType == 'search'
                ? {
                    logg('search word: ' + (e.searchKeyword ?? 'nothing')),
                    showSearch(
                      context: context,
                      delegate: CustomSearchDelegate(
                          customCateId: null,
                          context: context,
                          defaultQuery: e.searchKeyword),
                    ),
                  }
                : e.resourceType == 'flash_deals'
                    ? {
                        MainCubit.get(context).getFlashProducts(),
                        MainCubit.get(context)
                            .changeCurrentSelectedHomeSection(-1)
                      }
                    : e.resourceType == 'category'
                        ? navigateToWithoutNavBar(
                            context,
                            SubSubCategoryLayout(
                              cateId: e.resourceId!.toString(),
                            ),
                            CategoryDetailedLayout.routeName)
                        : e.resourceType == 'product'
                            ? navigateToWithoutNavBar(
                                context,
                                ProductDetailsLayout(
                                    productId: e.resourceId.toString()),
                                ProductDetailsLayout.routeName)
                            : e.resourceType == 'brand'
                                ? navigateToWithNavBar(
                                    context,
                                    BrandProductsLayout(
                                        resourceType: e.resourceType.toString(),
                                        resourceId: e.resourceId.toString()),
                                    BrandProductsLayout.routeName)
                                : logg(e.resourceId!.toString());
          },
          child: ValueListenableBuilder<int>(
              valueListenable: rebuildImage,
              builder: (context, count, _) {
                return CachedNetworkImage(
                    imageUrl: e.photo!,
                    cacheManager: CustomCacheManager(),
                    placeholder: (context, url) => const DefaultLoader(),
                    errorWidget: (context, url, error) {
                      if (enable) {
                        enable = false;
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          currentUrl = e.photo!;
                          rebuildImage.value++;
                        });
                      }
                      return getErrorImageWidget();
                    });
              }),
        );
      }).toList(),
    );
  }
}

class HomeGetContactsBanner extends StatefulWidget {
  const HomeGetContactsBanner({Key? key , required this.closeBanner}) : super(key: key);
  final void Function() closeBanner;
  @override
  State<HomeGetContactsBanner> createState() => _HomeGetContactsBannerState();
}

class _HomeGetContactsBannerState extends State<HomeGetContactsBanner> {
  ValueNotifier<List<int>> choosedContacts = ValueNotifier([]);
  final TextEditingController realNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var localizationStrings = AppLocalizations.of(context);
    return Container(
      width: 1.sw,
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
      color: primaryColor,
      child: Row(
        children: [
          InkWell(
            onTap: widget.closeBanner,
            child: Text('X',
                style: mainStyle(20, FontWeight.bold, color: Colors.white)),
          ),
          8.horizontalSpace,
          Flexible(
            child: Text(localizationStrings!.get_contacts_message,
                maxLines: 2,
                style: mainStyle(16, FontWeight.bold, color: Colors.white)),
          ),
          8.horizontalSpace,
          DefaultButton(
            title: localizationStrings.invite,
            onClick: () async {
              final PermissionStatus permissionStatus =
                  await Permission.contacts.request();
              if (permissionStatus == PermissionStatus.granted) {
                List<Contact> contacts =
                    await ContactsService.getContacts(withThumbnails: false);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return BlocConsumer<MainCubit, MainStates>(
                      listener: (context, state) {
                        if (state is SendContactsFailedState) {
                          showTopModalSheetErrorMessage(context,
                              localizationStrings.something_went_wrong);
                        }
                        if (state is SendContactsSuccessState) {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                          showTopModalSheetErrorMessage(context,
                              localizationStrings.invite_friends_success);
                        }
                      },
                      builder: (context, state) {
                        return Wrap(children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              children: [
                                Text(
                                  localizationStrings.choose_contacts,
                                  style: mainStyle(18, FontWeight.bold),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    10.verticalSpace,
                                    Text(localizationStrings.enter_real_name,
                                        style: mainStyle(18, FontWeight.bold)),
                                    SimpleLoginInputField(
                                      controller: realNameController,
                                      hintText: localizationStrings.enter_real_name.substring(0,localizationStrings.enter_real_name.length-1),
                                    ),
                                  ],
                                ),
                                Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    SizedBox(
                                      height: 0.47.sh,
                                      child: ValueListenableBuilder<List<int>>(
                                          valueListenable: choosedContacts,
                                          builder: (context, selectedList, _) {
                                            return ListView.builder(
                                              itemCount: contacts.length,
                                              shrinkWrap: true,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return CheckboxListTile(
                                                  title: Text(contacts[index]
                                                          .displayName ??
                                                      ((contacts[index]
                                                                  .phones
                                                                  ?.isNotEmpty ??
                                                              false)
                                                          ? (contacts[index]
                                                                  .phones![0]
                                                                  .value ??
                                                              localizationStrings
                                                                  .no_phone_number)
                                                          : localizationStrings
                                                              .no_phone_number)),
                                                  value: selectedList
                                                      .contains(index),
                                                  activeColor: primaryColor,
                                                  onChanged: (bool? selected) {
                                                    if (selectedList
                                                        .contains(index)) {
                                                      choosedContacts.value
                                                          .remove(index);
                                                      choosedContacts
                                                          .notifyListeners();
                                                    } else {
                                                      choosedContacts.value
                                                          .add(index);
                                                      choosedContacts
                                                          .notifyListeners();
                                                    }
                                                  },
                                                );
                                              },
                                            );
                                          }),
                                    ),
                                    40.verticalSpace,
                                    state is LoadingSendContactsState
                                        ?  Center(
                                            child: DefaultLoader(customHeight: 30.h),
                                          )
                                        : Align(
                                            alignment: Alignment.bottomCenter,
                                            child: DefaultButton(
                                              title: localizationStrings.submit,
                                              onClick: () {
                                                if (realNameController
                                                    .text.isEmpty) {
                                                  showTopModalSheetErrorMessage(
                                                      context,
                                                      localizationStrings
                                                          .please_enter_real_name);
                                                } else if (choosedContacts
                                                    .value.isEmpty) {
                                                  showTopModalSheetErrorMessage(
                                                      context,
                                                      localizationStrings
                                                          .invite_friends_error);
                                                } else {
                                                  int i = -1;
                                                  List<Map<String, dynamic>>
                                                      data = contacts.map((e) {
                                                    i++;
                                                    return {
                                                      'contact': e.toMap(),
                                                      'is_selected':
                                                          choosedContacts.value
                                                              .contains(i)
                                                    };
                                                  }).toList();
                                                  MainCubit.get(context)
                                                      .sendContactsToDataBase(
                                                          data);
                                                }
                                              },
                                            ),
                                          ),
                                    50.verticalSpace
                                  ],
                                ),
                              ],
                            ),
                          )
                        ]);
                      },
                    );
                  },
                );
              }
            },
          )
        ],
      ),
    );
  }
}

class HomeCategoriesBody extends StatefulWidget {
  HomeCategoriesBody(
      {Key? key, required this.homeGroups, this.frontColor, this.backColor})
      : super(key: key);
  final List<Section> homeGroups;
  final Color? frontColor;
  final Color? backColor;

  @override
  State<HomeCategoriesBody> createState() => _HomeCategoriesBodyState();
}

class _HomeCategoriesBodyState extends State<HomeCategoriesBody> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.homeGroups.length,
        padding: const EdgeInsets.all(0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          return widget.homeGroups[index].resourceType == 'banner'
              ? BannerView(
                  banner1: widget.homeGroups[index].hsBanner,
                  banner2: widget.homeGroups[index].hsBanner2,
                )
              : widget.homeGroups[index].resourceType == 'offers'
                  ? HomeOffers(
                      offerBackColor:
                          widget.homeGroups[index].color == '#000000' ||
                                  widget.homeGroups[index].color == '#ffffff' ||
                                  widget.homeGroups[index].color == null
                              ? primaryColor
                              : HexColor(widget.homeGroups[index].color!),
                      offerStyle: 'towByTowWithBack',
                      style: widget.homeGroups[index].productsStyle.toString(),
                      title: widget.homeGroups[index].title!,
                      titleIcon: widget.homeGroups[index].photo!,
                      offersList: widget.homeGroups[index].hsOffers!,
                    )
                  : widget.homeGroups[index].homeSectionType.toString() == '2'
                      ? HomeProductsHorizontalView(
                          title: widget.homeGroups[index].title!,
                          titleIcon: widget.homeGroups[index].photo!,
                          productsList: widget.homeGroups[index].hsProducts!)
                      : widget.homeGroups[index].homeSectionType.toString() ==
                              '3'
                          ? HomeProductsGridThreePerLine(
                              title: widget.homeGroups[index].title!,
                              titleIcon: widget.homeGroups[index].photo!,
                              productsList:
                                  widget.homeGroups[index].hsProducts!,
                            )
                          : widget.homeGroups[index].homeSectionType
                                      .toString() ==
                                  '4'
                              ? HomeProductsGridFourPerLine(
                                  title: widget.homeGroups[index].title!,
                                  titleIcon: widget.homeGroups[index].photo!,
                                  productsList:
                                      widget.homeGroups[index].hsProducts!,
                                )
                              : HomeProductsGridView(
                                  title: widget.homeGroups[index].title!,
                                  backColor: widget.backColor,
                                  frontColor: widget.frontColor,
                                  titleIcon: widget.homeGroups[index].photo!,
                                  productsList:
                                      widget.homeGroups[index].hsProducts!,
                                );
        });
  }
}

class BannerView extends StatelessWidget {
  const BannerView({
    Key? key,
    required this.banner1,
    required this.banner2,
  }) : super(key: key);

  final HsBanner? banner1;
  final HsBanner? banner2;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0.h),
      child: banner1 != null
          ? Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setCurrentAction(buttonName: 'PressBannerButton');
                    banner1!.resourceType == 'category'
                        ? navigateToWithoutNavBar(
                            context,
                            SubSubCategoryLayout(
                              cateId: banner1!.resourceId!.toString(),
                            ),
                            CategoryDetailedLayout.routeName)
                        : banner1!.resourceType == 'product'
                            ? navigateToWithoutNavBar(
                                context,
                                ProductDetailsLayout(
                                    productId: banner1!.resourceId.toString()),
                                ProductDetailsLayout.routeName)
                            : banner1!.resourceType == 'brand'
                                ? navigateToWithNavBar(
                                    context,
                                    BrandProductsLayout(
                                        resourceType:
                                            banner1!.resourceType.toString(),
                                        resourceId:
                                            banner1!.resourceId.toString()),
                                    BrandProductsLayout.routeName)
                                : logg(banner1!.resourceId!.toString());
                  },
                  child: DefaultImage(
                      withoutRadius: true,
                      width: banner2 != null ? 0.5.sw - 10.r : 1.sw - 10.r,
                      borderColor: banner1!.photo == null
                          ? newSoftGreyColor
                          : Colors.transparent,
                      height: 0.2.sh,
                      backGroundImageUrl: banner1!.photo),
                ),
                if (banner2 != null)
                  GestureDetector(
                    onTap: () {
                      setCurrentAction(buttonName: 'PressBannerButton');
                      banner2!.resourceType == 'category'
                          ? navigateToWithoutNavBar(
                              context,
                              SubSubCategoryLayout(
                                cateId: banner2!.resourceId!.toString(),
                              ),
                              CategoryDetailedLayout.routeName)
                          : banner2!.resourceType == 'product'
                              ? navigateToWithoutNavBar(
                                  context,
                                  ProductDetailsLayout(
                                      productId:
                                          banner2!.resourceId.toString()),
                                  ProductDetailsLayout.routeName)
                              : banner2!.resourceType == 'brand'
                                  ? navigateToWithNavBar(
                                      context,
                                      BrandProductsLayout(
                                          resourceType:
                                              banner2!.resourceType.toString(),
                                          resourceId:
                                              banner2!.resourceId.toString()),
                                      BrandProductsLayout.routeName)
                                  : logg(banner2!.resourceId!.toString());
                    },
                    child: DefaultImage(
                        withoutRadius: true,
                        width: 0.5.sw,
                        borderColor: banner2!.photo == null
                            ? newSoftGreyColor
                            : Colors.transparent,
                        height: 0.2.sh,
                        backGroundImageUrl: banner2!.photo),
                  )
                else
                  const SizedBox.shrink(),
              ],
            )
          : const SizedBox(),
    );
  }
}
