import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:bot_toast/bot_toast.dart';
import 'package:clearance/core/constants/networkConstants.dart';
import 'package:clearance/core/global_blocs/sensitive_connectivity/connectivity_observer.dart';
import 'package:clearance/core/global_blocs/sensitive_connectivity/sensitive_connectivity_bloc.dart';
import 'package:clearance/core/main_cubits/fetch_link_information_cubit/fetch_link_information_cubit.dart';
import 'package:clearance/core/main_cubits/search_cubit.dart';
import 'package:clearance/modules/main_layout/sub_layouts/brand_products/brand_products/brand_products_cubit.dart';
import 'package:clearance/modules/main_layout/sub_layouts/product_details/cubit/required_product_details_cubit.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uni_links/uni_links.dart';

import 'package:clearance/core/constants/startup_settings.dart';

import 'package:clearance/core/main_cubits/cubit_main.dart';

import 'package:clearance/core/main_cubits/states_main.dart';
import 'package:clearance/core/network/dio_helper.dart';
import 'package:clearance/core/styles_colors/styles_colors.dart';
import 'package:clearance/modules/auth_screens/cubit/states_auth.dart';
import 'package:clearance/modules/main_layout/sub_layouts/product_details/cubit/cubit_product_details.dart';
import 'core/bloc_observer.dart';
import 'core/cache/cache.dart';
import 'core/main_functions/main_funcs.dart';
import 'core/shared_widgets/shared_widgets.dart';
import 'firebase_options.dart';
import 'l10n/l10n.dart';
import 'modules/auth_screens/cubit/cubit_auth.dart';
import 'modules/auth_screens/guest_login_screen.dart';
import 'modules/main_layout/main_layout.dart';
import 'modules/main_layout/sub_layouts/account/cubit/account_cubit.dart';
import 'modules/main_layout/sub_layouts/cart/cart_screen.dart';
import 'modules/main_layout/sub_layouts/cart/cubit/cart_cubit.dart';
import 'modules/main_layout/sub_layouts/categories/cubit/cubit_categories.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'modules/main_layout/sub_layouts/main_payment/cubit/cubit_payment.dart';
import 'modules/main_layout/sub_layouts/splash/splash_screen.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void mainAppInitialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  await MainDioHelper.init();
  baseLink = getCachedServerUrl() ?? stagingLink;
  if (!kDebugMode ) {
    FlutterError.onError = (FlutterErrorDetails error) {
      if (error.toString () !=''){
      MainDioHelper.postData(url: storeErrorEP, token: getCachedToken(), data: {
      "error_description": 'User-Agent: ' 'device OS:' +
      (Platform.isAndroid ? 'Android' : 'IOS') +
      ' , application version: $appVersionName , language:' +
      getCachedLocal().toString() +
      '\n' +
      'token: ' +
      getCachedToken().toString() +
      '\ndevice id: ' +
      deviceId.toString() +
      '\nlast_endpoint: $lastEndPointUrl\nlast_screen: $lastScreen\nlast_clicked_button: $lastClickedButton\n${error.toString()}\nscreen_trace: ${screenTrace.toString()}'
      });
      }
    };
  }
  await setStartingSettings();
  await Firebase.initializeApp(
    name: 'clearance',
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((value) {
    logg('firebase initialized.... response value:' + value.toString());
    if (enableFirebaseMessaging) {
      setupInteractedMessage();
    }
  });
  if (enableCrashlytics) {
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);
    FlutterError.onError = (error) {
      if (!kDebugMode && error.toString()!='') {
        MainDioHelper.postData(
            url: storeErrorEP,
            token: getCachedToken(),
            data: {
              "error_description": 'User-Agent: ' 'device OS:' +
                  (Platform.isAndroid ? 'Android' : 'IOS') +
                  ' , application version: $appVersionName , language:' +
                  getCachedLocal().toString() +
                  '\n' +
                  'token: ' +
                  getCachedToken().toString() +
                  '\ndevice id: ' +
                  deviceId.toString() +
                  '\nlast_endpoint: $lastEndPointUrl\nlast_screen: $lastScreen\nlast_clicked_button: $lastClickedButton\n${error.toString()}\nscreen_trace: ${screenTrace.toString()}'
            });
      }
      FirebaseCrashlytics.instance.recordFlutterFatalError(error);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    Isolate.current.addErrorListener(RawReceivePort((pair) async {
      final List<dynamic> errorAndStacktrace = pair;
      await FirebaseCrashlytics.instance.recordError(
        errorAndStacktrace.first,
        errorAndStacktrace.last,
      );
    }).sendPort);
  }
  if (enableFirebaseMessaging) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  logg('Started at ${DateTime.now()}');

  BlocOverrides.runZoned(
    () {
      runApp(const MainAppInitializeClass());
    },
    blocObserver: MyBlocObserver(),
  );

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  await analytics.logBeginCheckout(
      value: 10.0,
      currency: 'USD',
      items: [
        AnalyticsEventItem(itemName: 'Socks', itemId: 'xjw73ndnw', price: 10.0),
      ],
      coupon: '10PERCENTOFF');
}

Future<void> setupInteractedMessage() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  NotificationService.initialize();

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  logg('User granted permission: ${settings.authorizationStatus}');

  RemoteMessage? initialMessage = await messaging.getInitialMessage();

  if (initialMessage != null) {
    _handleMessage(initialMessage);
  }

  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  FirebaseMessaging.onMessage.listen(_handleMessage);
}

Future<void> _handleMessage(RemoteMessage message) async {
  logg('got message');

  if (Platform.isAndroid) {
    logg('got message in android platform');

    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'notifications_high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
      );

      NotificationService.showNotification(
          notification, channel.id, channel.name);
    }
  } else {
    logg('Got msg in non-android platform');
  }
}

void _handleMessageOpenedApp(RemoteMessage message) {
  logg(' message opened');
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    name: 'clearance',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  logg("Handling a background message: ${message.messageId}");
}

class MainAppInitializeClass extends StatefulWidget {
  const MainAppInitializeClass({Key? key}) : super(key: key);

  @override
  State<MainAppInitializeClass> createState() => _MainAppInitializeClassState();
}

class _MainAppInitializeClassState extends State<MainAppInitializeClass> {
  @override
  Widget build(BuildContext context) {
    lastScreen = 'MainAppInitializeClass';
    logg('MainAppInitializeClass build');
    preChacheProcesses(context);
    return MultiBlocProvider(providers: [
      BlocProvider(create: (BuildContext context) => CategoriesCubit()),
      BlocProvider(create: (BuildContext context) => ProductDetailsCubit()),
      BlocProvider(create: (BuildContext context) => AuthCubit()),
      BlocProvider(create: (BuildContext context) => CartCubit()),
      BlocProvider(create: (BuildContext context) => AccountCubit()),
      BlocProvider(create: (BuildContext context) => PaymentCubit()),
      BlocProvider(create: (BuildContext context) => SearchCubit()),
      BlocProvider(create: (BuildContext context) => MainCubit()),
      BlocProvider(create: (BuildContext context) => BrandProductsCubit()),
      BlocProvider(
          create: (BuildContext context) => FetchLinkInformationCubit()),
      BlocProvider(
          create: (BuildContext context) => RequiredProductDetailsCubit()),
      BlocProvider(
          create: (BuildContext context) => SensitiveConnectivityBloc()),
    ], child: const MainAppMaterialApp());
  }
}

class FirstStartChooseDefaultLangScreen extends StatefulWidget {
  const FirstStartChooseDefaultLangScreen({Key? key}) : super(key: key);

  @override
  State<FirstStartChooseDefaultLangScreen> createState() => _FirstStartChooseDefaultLangScreenState();
}

class _FirstStartChooseDefaultLangScreenState extends State<FirstStartChooseDefaultLangScreen> {

  @override
  void initState() {
    setCurrentScreen(screenName: 'FirstStartChooseDefaultLangScreen');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mainCubit = MainCubit.get(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                SizedBox(
                  height: 150.h,
                ),
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
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      Center(
                        child: CustomPaint(
                          size: const Size(double.infinity, 400),
                          painter: CurvedPainter(),
                        ),
                      ),
                      Positioned(
                        bottom: 150.h,
                        child: SizedBox(
                          width: 1.sw,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: L10n.all
                                .map((locale) =>
                                    BlocConsumer<MainCubit, MainStates>(
                                      listener: (context, state) {},
                                      builder: (context, state) => Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            logg('ssssss: ' +
                                                mainCubit.appLocale.toString());
                                            logg(locale.toString());
                                            mainCubit.setLocale(
                                                locale, context, true, true);
                                          },
                                          child: DefaultContainer(
                                              height: 45.h,
                                              width: 0.35.sw,
                                              backColor:
                                                  Colors.white.withOpacity(0.5),
                                              borderColor: primaryColor,
                                              childWidget: Center(
                                                  child: Text(
                                                locale.languageCode == 'en'
                                                    ? 'English'
                                                    : 'العربية',
                                                style: mainStyle(
                                                    14.0, FontWeight.w600),
                                              ))),
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class CurvedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 15;

    var path = Path();

    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.7,
        size.width * 0.5, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.9,
        size.width * 1.0, size.height * 0.8);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class MainAppMaterialApp extends StatefulWidget {
  const MainAppMaterialApp({Key? key}) : super(key: key);
  static String routeName = '/mainAppMaterialAppRoute';

  @override
  State<MainAppMaterialApp> createState() => _MainAppMaterialAppState();
}

class _MainAppMaterialAppState extends State<MainAppMaterialApp> {

  @override
  void initState() {
    setCurrentScreen(screenName: 'MainAppMaterialApp');
    saveDeviceId();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: newSoftGreyColorAux,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));
    super.initState();
  }

  void saveDeviceId() async {
    deviceId = (await MainCubit.get(context).getDeviceId());
  }

  final botToastBuilder = BotToastInit();

  @override
  Widget build(BuildContext context) {
    logg('MainAppMaterialApp build');
    lastScreen = 'MainAppMaterialApp';
    var mainCubit = MainCubit.get(context)..getSavedAppLocale();
    AuthCubit.get(context).getLocalUserData();
    mainCubit.checkConnectivity().then((value) {
      if (value == true) {
      } else {
        logg('error in connection');
      }
      return;
    });
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => BlocConsumer<MainCubit, MainStates>(
        listener: (context, state) {},
        builder: (context, state) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Clearance',
          locale: mainCubit.appLocale,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            fontFamily: 'Tajawal',
          ),
          supportedLocales: L10n.all,
          builder: (context, child) {
            ConnectivityObserver.createInstance(context);
            return botToastBuilder(context, child);
          },
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
          routes: {
            '/': (context) =>
                Platform.isIOS ? const SplashScreen() : const RouteEngine(),
          },
        ),
      ),
    );
  }
}

class RouteEngine extends StatefulWidget {
  const RouteEngine({Key? key}) : super(key: key);

  @override
  State<RouteEngine> createState() => _RouteEngineState();
}

class _RouteEngineState extends State<RouteEngine> {

  Future<void> initUniLinks() async {
    try {
      final link = await getInitialLink();
      logg('listener working');
      logg(link.toString());
      await FetchLinkInformationCubit.get(context).dealWithLink(link, context);
    } on PlatformException {
      // return?
    }
  }
  @override
  void initState() {
    setCurrentScreen(screenName: 'RouteEngine');
    initUniLinks();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mainCubit = MainCubit.get(context);
    var authCubit = AuthCubit.get(context);
    lastScreen = 'RouteEngine';
    mainCubit.getMainCacheUserData();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: BlocBuilder<FetchLinkInformationCubit, FetchLinkInformationState>(
            builder: (context, fetchLinkInformationState) {
          print('ss: ' + fetchLinkInformationState.toString());
          return BlocConsumer<MainCubit, MainStates>(
            listener: (context, state) {},
            builder: (context, state) => ConditionalBuilder(
              condition: mainCubit.defaultLang != null,
              builder: (context) => ConditionalBuilder(
                condition: state is! ConnectionStateChanging,
                builder: (context) => mainCubit.isConnected
                    ? BlocConsumer<AuthCubit, AuthStates>(
                        listener: (context, authState) {
                          if (authState is CheckingAuthStateError &&
                              authState.requestRegisterGuest) {
                            logg('checking error');
                            MainCubit.get(context).getDeviceId().then((value) {
                              logg(value.toString());
                              authCubit.guestLogin(
                                  deviceUniqueId: value.toString(),
                                  context: context);
                            });
                          }
                        },
                        builder: (context, authState) {
                          return ConditionalBuilder(
                              condition: (authState is! CheckingAuthState),
                              builder: (context) => ConditionalBuilder(
                                    condition: authCubit.isUserAuth,
                                    builder: (context) => ConditionalBuilder(
                                      condition: fetchLinkInformationState
                                          is GettingLinkInformationSuccess,
                                      builder: (context) => const MainLayout(),
                                      fallback: (context) =>  const LoadingWithLogoWidget()
                                    ),
                                    fallback: (context) =>
                                        const GuestLoginScreen(),
                                  ),
                              fallback: (context) {
                                return const LoadingWithLogoWidget();
                              });
                        },
                      )
                    : const Center(child: DefaultLoader()),
                fallback: (context) => const Center(child: DefaultLoader()),
              ),
              fallback: (context) => const FirstStartChooseDefaultLangScreen(),
            ),
          );
        }));
  }
}

class LoadingWithLogoWidget extends StatelessWidget{
  const LoadingWithLogoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
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
  }

}

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future initialize() async {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/launcher2');

    InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    if (!Platform.isIOS) {
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
      );
    }
  }

  static Future showNotification(RemoteNotification? notification,
      String channelId, String channelName) async {
    logg('viewing local notification');
    logg('channelId:' + channelId);
    logg('channelName:' + channelName);
    logg('message:' + notification.toString());
    logg('viewing local notification');
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      enableLights: true,
      enableVibration: true,
      priority: Priority.high,
      importance: Importance.max,
      largeIcon: const DrawableResourceAndroidBitmap("@mipmap/launcher2"),
      styleInformation: const MediaStyleInformation(
        htmlFormatContent: true,
        htmlFormatTitle: true,
      ),
      playSound: true,
    );
    logg('android details set');
    logg('showing');
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'notifications_high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    logg('showing _flutterLocalNotificationsPlugin');
    await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification!.title ?? 'message without title',
        notification.body ?? 'message without body',
        NotificationDetails(
          android: androidDetails,
        ));
  }
}

Future<void> preChacheProcesses(BuildContext context) async {
  precacheImage(
      CacheHelper.getData(key: 'rectangularCurvedLogoUrl') == null
          ? const AssetImage('assets/icons/clearance2.png')
          : (FileImage(
                  File(CacheHelper.getData(key: 'rectangularCurvedLogoUrl')))
              as ImageProvider),
      context);
}
