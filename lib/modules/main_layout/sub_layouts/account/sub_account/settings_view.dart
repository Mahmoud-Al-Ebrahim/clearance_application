import 'package:clearance/core/error_screens/show_error_message.dart';
import 'package:clearance/core/styles_colors/styles_colors.dart';
import 'package:clearance/main.dart';
import 'package:clearance/modules/auth_screens/cubit/cubit_auth.dart';
import 'package:clearance/modules/main_layout/sub_layouts/cart/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:clearance/core/constants/startup_settings.dart';
import 'package:clearance/core/main_cubits/states_main.dart';
import 'package:clearance/core/shared_widgets/shared_widgets.dart';
import 'package:restart_app/restart_app.dart';
import '../../../../../core/cache/cache.dart';
import '../../../../../core/main_cubits/cubit_main.dart';
import '../../../../../core/main_functions/main_funcs.dart';
import '../../../../../l10n/l10n.dart';
import '../account_shared_widgets/account_shared_widgets.dart';
import '../cubit/account_cubit.dart';
import '../cubit/account_state.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({Key? key}) : super(key: key);
  static String routeName = 'settingsView';

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {

  @override
  void initState() {
    setCurrentScreen(screenName: 'SettingsView');

    AccountCubit.get(context).getUserSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    lastScreen = 'SettingsView';
    var localizationStrings = AppLocalizations.of(context);
    var mainCubit = MainCubit.get(context);
    var accountCubit = AccountCubit.get(context);
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(56.0.h),
          child: DefaultAppBarWithTitleAndBackButton(
              title: localizationStrings!.setting),
        ),
        body: BlocConsumer<AccountCubit, AccountStates>(
          listener: (context, state) {
            if (state is SetSettingsFailureState) {
              showTopModalSheetErrorMessage(
                  context, localizationStrings.something_went_wrong);
            }
          },
          builder: (context, state) {
            if (accountCubit.mySettingsModel == null) {
              return Center(child: DefaultLoader(customHeight: 40.h,));
            }
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              child: Column(children: [
                15.verticalSpace,
                Container(
                    height: 65.h,
                    decoration: BoxDecoration(
                      color: const Color(0xffffffff),
                      border: Border.all(width: 1.0, color: primaryColor),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        (state is SetSettingsLoadingState)
                            ? DefaultLoader(
                          customHeight: 30.h,
                        )
                            : Switch(
                            value: accountCubit.mySettingsModel!.data!.isStopWhatsappMessages=="1",
                            activeColor: Colors.green,
                            onChanged: (bool value) {
                              setCurrentAction(buttonName: 'ChangeEnableWhatsappMessagesButton');
                              accountCubit.stopWhatsAppNotification(
                                  AuthCubit
                                      .get(context)
                                      .userInfoModel!
                                      .data!
                                      .id!,
                                  value ? 1 : 0);
                            }),
                        10.horizontalSpace,
                        Text(
                          localizationStrings.enable_whatsapp_notification,
                          style: mainStyle(18, FontWeight.w500),
                        )
                      ],
                    )),
              ]),
            );
          },
        ));
  }
}

class SettingRow extends StatelessWidget {
  const SettingRow({
    Key? key,
    required this.svgPath,
    required this.title,
    required this.selectedValue,
  }) : super(key: key);

  final String svgPath;
  final String title;
  final String selectedValue;

  @override
  Widget build(BuildContext context) {
    var mainCubit = MainCubit.get(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 230.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(svgPath),
              SizedBox(
                width: 10.w,
              ),
              Text(title)
            ],
          ),
        ),
        Text('> $selectedValue')
      ],
    );
  }
}
