import 'package:clearance/core/constants/startup_settings.dart';
import 'package:clearance/core/styles_colors/styles_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../core/shared_widgets/shared_widgets.dart';

class BehaviorsStackLayout extends StatelessWidget {
  const BehaviorsStackLayout({Key? key}) : super(key: key);
  static String routeName = 'BehaviorsStackLayout';

  @override
  Widget build(BuildContext context) {
    var localizationStrings = AppLocalizations.of(context);

    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(56.0.h),
          child: const DefaultAppBarWithTitleAndBackButton(
              title: 'Behaviors Stack'),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  screenTrace.length,
                  (index) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.h)..copyWith(bottom: index==(screenTrace.length-1) ? 20.h : 0),
                    child: Text(
                      '${screenTrace.length - index}- ${screenTrace[index]}',
                      style: mainStyle(16, FontWeight.w400),
                    ),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(0, -20.h),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15.0.w),
                  child: DefaultButton(
                      title: localizationStrings!.lbl_share,
                      borderColors: primaryColor,
                      onClick: () async {
                        String text = "";
                        for (int i = 0; i < screenTrace.length; i++) {
                          text += screenTrace[i];
                          await Share.share(text);
                        }
                      }),
                ),
              ),
            ),
          ],
        ));
  }
}
