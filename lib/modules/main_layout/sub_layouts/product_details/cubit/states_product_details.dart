abstract class ProductDetailsStates {}

class ProductDetailsInitializeState extends ProductDetailsStates {}

class LoadingProductDetailsState extends ProductDetailsStates {}
class AddingToCartState extends ProductDetailsStates {
  final bool buyNowButton;
  AddingToCartState({this.buyNowButton=false});
}

class PleaseChooseVariantState extends ProductDetailsStates {
  String message;
  String? quantity;
  bool fromBuyNowButton;
  PleaseChooseVariantState({required this.message , this.quantity , this.fromBuyNowButton=false});
}
class ChoiceChangedState extends ProductDetailsStates {
  final bool popScreen;
  ChoiceChangedState({ this.popScreen=false});

}
class QuantityChangedState extends ProductDetailsStates {
}
class SuccessAddingToCartState extends ProductDetailsStates {
  final String? msg;
  final bool moveToPayment;
  SuccessAddingToCartState({required this.msg , this.moveToPayment=false});
}

class ProductDetailsDataLoadedSuccessState extends ProductDetailsStates {}

class ErrorLoadingDataState extends ProductDetailsStates {}
class ErrorAddingToCartState extends ProductDetailsStates {}
