import 'package:bloc/bloc.dart';
import 'package:clearance/core/constants/networkConstants.dart';
import 'package:clearance/core/main_cubits/cubit_main.dart';
import 'package:clearance/core/main_functions/main_funcs.dart';
import 'package:clearance/core/network/dio_helper.dart';
import 'package:clearance/core/shared_widgets/shared_widgets.dart';
import 'package:clearance/models/api_models/link-trancsaction_model.dart';
import 'package:clearance/modules/main_layout/sub_layouts/brand_products/brand_products_layout.dart';
import 'package:clearance/modules/main_layout/sub_layouts/categories/category_detailed_layout/category_detailed_layout.dart';
import 'package:clearance/modules/main_layout/sub_layouts/categories/sub_sub_category_layout/sub_sub_category_layout.dart';
import 'package:clearance/modules/main_layout/sub_layouts/product_details/product_details_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'fetch_link_information_state.dart';

class FetchLinkInformationCubit extends Cubit<FetchLinkInformationState> {
  FetchLinkInformationCubit() : super(GettingLinkInformationLoading());

  static FetchLinkInformationCubit get(context) => BlocProvider.of(context);
  LinkTransactionModel? linkTransactionModel;

  dealWithLink(String? link,BuildContext context) async{
    emit(GettingLinkInformationLoading());
    if(link!=null){
    await MainDioHelper.postData(
        url: fetchLinkTransactionEP, data: {'url': link}).then((value) {
          logg(value.data.toString());
      linkTransactionModel = LinkTransactionModel.fromJson(value.data);
      TransactionData e = linkTransactionModel!.data!;
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
        ).then((value) {
          emit(GettingLinkInformationSuccess());
        })
      }
          : e.resourceType == 'flash_deals'
          ? {
        MainCubit.get(context).getFlashProducts(),
        MainCubit.get(context).changeCurrentSelectedHomeSection(-1),
          emit(GettingLinkInformationSuccess())
      }
          : e.resourceType == 'category'
          ? navigateToWithoutNavBar(
          context,
          SubSubCategoryLayout(
            cateId: e.resourceId!.toString(),
          ),
          CategoryDetailedLayout.routeName).then((value) {
        emit(GettingLinkInformationSuccess());
      })
          : e.resourceType == 'product'
          ? navigateToWithoutNavBar(
          context,
          ProductDetailsLayout(
              productId: e.resourceId.toString()),
          ProductDetailsLayout.routeName).then((value) {
        emit(GettingLinkInformationSuccess());
      })
          : e.resourceType == 'brand'
          ? navigateToWithNavBar(
          context,
          BrandProductsLayout(
              resourceType: e.resourceType.toString(),
              resourceId: e.resourceId.toString()),
          BrandProductsLayout.routeName).then((value) {
        emit(GettingLinkInformationSuccess());
      })
          : logg(e.resourceId.toString());
    }
    ).catchError((error){
      logg('error with link occurs');
      logg(error.toString());
      emit(GettingLinkInformationSuccess());
    });
  }
  else{
    emit(GettingLinkInformationSuccess());
    logg('link is null');
    }
  }
}
