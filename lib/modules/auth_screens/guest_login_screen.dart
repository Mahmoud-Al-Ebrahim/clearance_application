import 'dart:io';

import 'package:clearance/core/cache/cache.dart';
import 'package:clearance/core/constants/startup_settings.dart';
import 'package:clearance/modules/auth_screens/cubit/cubit_auth.dart';
import 'package:clearance/modules/auth_screens/cubit/states_auth.dart';
import 'package:clearance/modules/main_layout/sub_layouts/cart/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/main_cubits/cubit_main.dart';
import '../../core/main_functions/main_funcs.dart';

class GuestLoginScreen extends StatefulWidget {
  const GuestLoginScreen({Key? key}) : super(key: key);

  @override
  State<GuestLoginScreen> createState() => _GuestLoginScreenState();
}

class _GuestLoginScreenState extends State<GuestLoginScreen> {

  @override
  void initState() {
    setCurrentScreen(screenName: 'GuestLoginScreen');

    if(getCachedToken()==null) {
      MainCubit.get(context)
          .getDeviceId()
          .then((value) {
        logg(value.toString());
        AuthCubit.get(context).guestLogin(
            deviceUniqueId: value.toString(),
            context: context);
      });
    }
    else{
      MainCubit.get(context).updateToken();
      AuthCubit.get(context).checkUserAuth(context);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    lastScreen='GuestLoginScreen';
    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context,state){
      },
      builder: (context, state) {
        return  Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CacheHelper.getData(key: 'rectangularCurvedLogoUrl') == null
                  ? Image.asset(
                'assets/icons/clearance2.png',
                height: 0.15.sh,
                width: 0.5.sw,
              )
                  : Image.file(
                File(CacheHelper.getData(
                    key: 'rectangularCurvedLogoUrl')),
                height: 0.15.sh,
                width: 0.5.sw,
              ),
              const DefaultLoader(),
            ],
          ),
        );
      },
    );
  }
}
