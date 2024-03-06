import 'package:clearance/core/constants/startup_settings.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../appMainInitial.dart';
import '../../../../core/main_functions/main_funcs.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({ Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    setCurrentScreen(screenName: 'SplashScreen');

    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: (20)),
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    lastScreen='SplashScreen';
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'assets/images/splash.json',

          controller: _controller,
          height: MediaQuery.of(context).size.height * 0.2,
          animate: true,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward().whenComplete(() =>

                  navigateToAndFinishUntil(context, const RouteEngine())
              );
          },
        ),
      ),
    );
  }
}