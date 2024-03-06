
abstract class AccountStates {}

class AccountInitial extends AccountStates {}
class LoadingWishListDataState extends AccountStates {}
class LoadingContactUsDataState extends AccountStates {}
class FailureContactUsDataState extends AccountStates {}
class SuccessContactUsDataState extends AccountStates {}
class WishListDataSuccessState extends AccountStates {}
class UploadImageLoading extends AccountStates {}
class UploadImageSuccess extends AccountStates {}
class UploadImageFailure extends AccountStates {}

class ConfirmReturnRequestLoading extends AccountStates {}
class ConfirmReturnRequestSuccess extends AccountStates {}
class ConfirmReturnRequestFailure extends AccountStates {}

class CancelOrderReturnRequestLoading extends AccountStates {}
class CancelOrderReturnRequestSuccess extends AccountStates {}
class CancelOrderReturnRequestFailure extends AccountStates {}

class GetOrderReturnRequestDataLoading extends AccountStates {}
class GetOrderReturnRequestDataSuccess extends AccountStates {}
class GetOrderReturnRequestDataFailure extends AccountStates {}

class RemoveImageFromServerLoading extends AccountStates {}
class RemoveImageFromServerSuccess extends AccountStates {
  final int imageIndex;
  final int productId;
   RemoveImageFromServerSuccess( {required this.imageIndex , required this.productId});
}
class RemoveImageFromServerFailure extends AccountStates {}

class SetQuantityFailure extends AccountStates {}
class SetSettingsLoadingState extends AccountStates {}
class SetSettingsSuccessState extends AccountStates {}
class SetSettingsFailureState extends AccountStates {}
class GetSettingsLoadingState extends AccountStates {}
class GetSettingsSuccessState extends AccountStates {}
class GetSettingsFailureState extends AccountStates {}
class ScrollingToActiveStatusLoadingState extends AccountStates {}
class ScrollingToActiveStatusSuccessfulState extends AccountStates {}
class SuccessPickedFiles extends AccountStates {}
class LoadingOrdersState extends AccountStates {}
class OrdersListSuccessState extends AccountStates {}
class ProductQuantityChanged extends AccountStates {
 final bool isProductRemoved;
 ProductQuantityChanged({this.isProductRemoved=false});
}
class ProductQuantityChanging extends AccountStates {}
class ProductQuantityChangingError extends AccountStates {}
class SavingAddressState extends AccountStates {}
class AddressTypeChanged extends AccountStates {}
class FilterApplied extends AccountStates {}
class SavingReviewListState extends AccountStates {}
class SuccessfullySaveReviewList extends AccountStates {}
class OrderCanceledSuccess extends AccountStates {}
class OrderCanceledError extends AccountStates {}
class OrderCancelLoading extends AccountStates {
  final bool fromWallet;
  OrderCancelLoading({required this.fromWallet});
}
class UpdateProfileSuccess extends AccountStates {
}
class LoadingState extends AccountStates {}
class GetProductInfoForRefundLoadingState extends AccountStates {}
class GetProductInfoForRefundSuccessState extends AccountStates {}
class GetProductInfoForRefundErrorState extends AccountStates {}
class RefundRequestLoadingState extends AccountStates {}
class RefundRequestSuccessState extends AccountStates {
  final String key;
  RefundRequestSuccessState({required this.key});
}
class RefundRequestCancelingErrorState extends AccountStates {}
class RefundRequestCancelingSuccessState extends AccountStates {
  final String key;
  final int index;
  RefundRequestCancelingSuccessState({required this.key,required this.index});
}
class RefundRequestCancelingLoadingState extends AccountStates {}
class RefundRequestUpdatingErrorState extends AccountStates {}
class RefundRequestUpdatingSuccessState extends AccountStates {
  final String key;
  RefundRequestUpdatingSuccessState({required this.key});
}
class RefundRequestUpdatingLoadingState extends AccountStates {}
class RefundRequestErrorState extends AccountStates {}
class GetRefundReasonsLoadingState extends AccountStates {}
class GetRefundReasonsSuccessState extends AccountStates {}
class GetRefundReasonsFailureState extends AccountStates {}
class GetPaymentDestinationsLoadingState extends AccountStates {}
class GetPaymentDestinationsSuccessState extends AccountStates {}
class GetPaymentDestinationsFailureState extends AccountStates {}
class GetRefundDetailsLoadingState extends AccountStates {}
class GetRefundDetailsSuccessState extends AccountStates {}
class GetRefundDetailsErrorState extends AccountStates {}
class GetWalletLoadingState extends AccountStates {}
class GetWalletSuccessState extends AccountStates {}
class GetWalletErrorState extends AccountStates {}
class ErrorUpdateProfile extends AccountStates {
  String? message;
  ErrorUpdateProfile({this.message});
}
class UpdateAccountPage extends AccountStates {}
class AddingAddressSuccessState extends AccountStates {
  final String? msg;

  AddingAddressSuccessState({required this.msg});

}
class ErrorLoadingDataState extends AccountStates {
  final String? msg;
  ErrorLoadingDataState({required this.msg});

}
class ErrorWishListDataState extends AccountStates {}
