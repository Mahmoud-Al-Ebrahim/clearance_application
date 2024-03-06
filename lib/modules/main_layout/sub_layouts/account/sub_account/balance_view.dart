import 'package:clearance/core/main_functions/main_funcs.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/cubit/account_cubit.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/cubit/account_state.dart';
import 'package:clearance/modules/main_layout/sub_layouts/account/wallet/wallet_transactions_table.dart';
import 'package:clearance/modules/main_layout/sub_layouts/cart/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../../core/constants/startup_settings.dart';
import '../../../../../core/shared_widgets/shared_widgets.dart';
import '../../../../../core/styles_colors/styles_colors.dart';
import '../account_shared_widgets/account_shared_widgets.dart';

class WalletView extends StatefulWidget {
  const WalletView({Key? key}) : super(key: key);
  static String routeName = 'balanceView';

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    setCurrentScreen(screenName: 'WalletView');

    controller.addListener(transactionPagination);
    super.initState();
  }

  void transactionPagination() {
    if (!controller.hasClients) return;
    if (controller.position.maxScrollExtent >= (controller.offset * 0.5) &&
        (AccountCubit.get(context).state is! GetWalletLoadingState) &&
        (AccountCubit.get(context).walletModel?.totalWalletTransaction !=
            AccountCubit.get(context).walletTransactions.length)) {
      AccountCubit.get(context).getWalletDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    lastScreen = 'WalletView';

    var localizationStrings = AppLocalizations.of(context);
    var accountCubit = AccountCubit.get(context);
    if(accountCubit.walletModel==null){
      accountCubit.getWalletDetails();
    }
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(56.0.h),
          child:  DefaultAppBarWithTitleAndBackButton(title: localizationStrings!.wallet),
        ),
        body: BlocBuilder<AccountCubit, AccountStates>(
          builder: (context, state) {
            if (state is GetWalletLoadingState &&
                accountCubit.walletModel == null) {
              return const Center(child: DefaultLoader());
            }
            return Padding(
              padding: EdgeInsets.only(bottom: 0.05.sh),
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  children: [
                    Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 26.0.w, vertical: 10.h),
                        child: Column(
                          children: [
                            AccountItemContainer(
                              title: localizationStrings.balance,
                              svgPath: 'assets/images/account/Card_icon.svg',
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  height: 25.h,
                                ),
                                DefaultContainer(
                                  backColor: primaryColor,
                                  borderColor: primaryColor,
                                  height: 58.h,
                                  width: double.infinity,
                                  childWidget: Center(
                                      child: Text(
                                        accountCubit.walletModel!.totalWalletBalanceFormatted.toString(),
                                    style: mainStyle(28.0, FontWeight.w800,
                                        color: Colors.white),
                                  )),
                                ),
                              ],
                            ),
                          ],
                        )),
                    const WalletTransactionTable(),
                    10.verticalSpace,
                    (state is GetWalletLoadingState &&
                            accountCubit.walletModel != null)
                        ? CircularProgressIndicator(
                            color: primaryColor,
                          )
                        : const SizedBox.shrink()
                  ],
                ),
              ),
            );
          },
        ));
  }
}
