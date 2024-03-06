import 'package:clearance/core/error_screens/errors_screens.dart';
import 'package:clearance/core/main_cubits/search_cubit.dart';
import 'package:clearance/core/main_cubits/search_states.dart';
import 'package:clearance/core/shared_widgets/shared_widgets.dart';
import 'package:clearance/core/styles_colors/styles_colors.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/wallet/exchange_payment_destination_layout.dart';
import 'package:clearance/modules/main_layout/sub_layouts/cart/cart_screen.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/dimensions.dart';
import '../../../../../core/constants/startup_settings.dart';
import '../../../../../core/main_functions/main_funcs.dart';

class ChooseProductsForExchange extends StatefulWidget {
  const ChooseProductsForExchange({Key? key}) : super(key: key);

  @override
  State<ChooseProductsForExchange> createState() =>
      _ChooseProductsForExchangeState();
}

class _ChooseProductsForExchangeState extends State<ChooseProductsForExchange> {
  final TextEditingController searchController = TextEditingController();

  void pagination() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent / 1.1 &&
        SearchCubit.get(context).state is! LoadingSearchResults &&
        SearchCubit.get(context).filteredProductsModel!.data!.totalSize !=
            SearchCubit.get(context).products.length) {
      logg('productsScrollController.position.pixels>='
          'productsScrollController.position.maxScrollExtent/1.5');
      logg('totalsize: ' +
          SearchCubit.get(context)
              .filteredProductsModel!
              .data!
              .totalSize
              .toString());
      logg('current product list length: ' +
          SearchCubit.get(context).products.length.toString());
      SearchCubit.get(context).getSearchResults(searchController.text, '');
    }
  }

  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var localizationStrings = AppLocalizations.of(context);
    var searchCubit = SearchCubit.get(context);
    scrollController.addListener(pagination);
    if (searchController.text.length >= 3 && !searchCubit.inSearchProcess) {
      searchCubit.getSearchResults(searchController.text, '',
          withPagination: false);
    }
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(170.0.h),
          child: SearchAppBarForExchange(
            title: localizationStrings!.lbl_exchange,
            searchController: searchController,
            currentPage: 2,
            onSearch: (String? text) {
              searchCubit.initSearch(null);
            },
            stepCount: 3,
            isBackButtonEnabled: true,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: Transform.translate(
                  offset: Offset(0, -20.h),
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                               ExchangePaymentDestinationLayout(
                              )));
                    },
                    backgroundColor: primaryColor,
                      elevation: 0,
                    focusColor: Colors.transparent,
                      splashColor: Colors.transparent,
                    child: Text( localizationStrings.next,style: mainStyle(18, FontWeight.bold , color: mainBackgroundColor),)
                  ),
                ),
        body: searchController.text.length < 3
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Text(
                      localizationStrings!.searchTermMustBeLonger,
                    ),
                  )
                ],
              )
            : BlocConsumer<SearchCubit, SearchStates>(
                listener: (context, state) {
                  // TODO: implement listener
                },
                builder: (context, state) {
                  return Stack(
                    children: [
                      ConditionalBuilder(
                        condition: searchCubit.filteredProductsModel != null,
                        builder: (context) => (searchCubit
                                .filteredProductsModel!
                                .data!
                                .products!
                                .isNotEmpty)
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: defaultHorizontalPadding * 3,
                                    vertical: defaultHorizontalPadding * 3),
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  child: ProductsGridView(
                                    isInHome: false,
                                    crossAxisCount: 2,
                                    towByTowJustTitle: false,
                                    fromSearch: true,
                                    forExchange: true,
                                    productsList: searchCubit.products,
                                  ),
                                ),
                              )
                            : const Center(child: EmptyError()),
                        fallback: (context) =>
                            const Center(child: DefaultLoader()),
                      ),
                      state is LoadingSearchResults
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
                },
              ));
  }
}
