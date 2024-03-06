
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/startup_settings.dart';
import '../../../../../core/main_functions/main_funcs.dart';
import '../../../../../core/shared_widgets/shared_widgets.dart';
import '../../../../../core/styles_colors/styles_colors.dart';
import '../../../../auth_screens/sign_in_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class JoinUsScreen extends StatefulWidget {
  const JoinUsScreen({Key? key}) : super(key: key);
  static String routeName='JoinUsScreen';

  @override
  State<JoinUsScreen> createState() => _JoinUsScreenState();
}

class _JoinUsScreenState extends State<JoinUsScreen> {

  @override
  void initState() {
    setCurrentScreen(screenName: 'JoinUsScreen');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    lastScreen='JoinUsScreen';

    var localizationStrings = AppLocalizations.of(context);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0.h),
        child: const DefaultAppBarWithOnlyBackButton(),
      ),
      body:  Center(
        child: InkWell(
          onTap: () {
            navigateToWithoutNavBar(context, const SignInScreen(),
                SignInScreen.routeName);
          },
          child: DefaultContainer(
              height: 45.h,
              width: 0.35.sw,
              backColor: Colors.white.withOpacity(0.5),
              borderColor: primaryColor,
              childWidget: Center(
                child: Text(
                  localizationStrings!.joinUs,
                  style: mainStyle(20.0, FontWeight.w600,
                      color: primaryColor),
                ),
              )),
        ),
      ),
    );
  }
}
