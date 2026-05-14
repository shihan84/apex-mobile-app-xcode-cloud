import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:media_kit/media_kit.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/locale/language_en.dart';
import 'package:streamit_laravel/routes/app_routes.dart';
import 'package:streamit_laravel/screens/auth/model/app_configuration_res.dart';
import 'package:streamit_laravel/screens/auth/model/login_response.dart';
import 'package:streamit_laravel/screens/coming_soon/model/coming_soon_response.dart';
import 'package:streamit_laravel/screens/home/model/dashboard_res_model.dart';
import 'package:streamit_laravel/screens/live_tv/model/live_tv_dashboard_response.dart';
import 'package:streamit_laravel/services/encryption_service.dart';
import 'package:streamit_laravel/services/hive_service.dart';
import 'package:streamit_laravel/services/in_app_purhcase_service.dart';
import 'package:streamit_laravel/services/local_storage_service.dart';
import 'package:streamit_laravel/services/notification_service.dart';
import 'package:streamit_laravel/utils/page_transition_builder.dart';

import 'app_theme.dart';
import 'bindings/app_bindings.dart';
import 'configs.dart';
import 'locale/app_localizations.dart';
import 'locale/languages.dart';
import 'screens/content/model/content_model.dart';
import 'screens/profile/model/profile_detail_resp.dart';
import 'utils/colors.dart';
import 'utils/common_base.dart';
import 'utils/common_functions.dart';
import 'utils/constants.dart';

Rx<BaseLanguage> locale = LanguageEn().obs;

InAppPurchaseService inAppPurchaseService = InAppPurchaseService();
HiveService hiveService = HiveService();
DashboardDetailResponse? cachedDashboardDetailResponse;
LiveChannelDashboardResponse? cachedLiveTvDashboard;
ProfileDetailResponse? cachedProfileDetails;

RxList<ComingSoonModel> cachedComingSoonList = RxList<ComingSoonModel>();
RxList<PosterDataModel> cachedContinueWatchList = RxList<PosterDataModel>();
RxList<PosterDataModel> cachedWatchList = RxList<PosterDataModel>();
RxList<PosterDataModel> cachedRentedContentList = RxList<PosterDataModel>();
RxList<Cast> cachedPersonList = RxList();
RxList<PosterDataModel> cachedSliderList = RxList();
bool isNotificationRead = false;

const platform = MethodChannel('flutter.iqonic.streamitlaravel.com.channel');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  setupGlobalFontConfig();

  await Firebase.initializeApp().then((value) {
    if (kReleaseMode) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    }
    NotificationService().init();
  }).catchError(onError);
// Initialize encryption service
  await EncryptionService.initialize();

  // Initialize local storage
  await LocalStorage.init();
  
  // Clear corrupted secure storage from old git version (one-time fix)
  try {
    bool needsClear = await getBoolFromLocal('NEEDS_STORAGE_CLEAR_V1', defaultValue: true);
    if (needsClear) {
      LocalStorage.clearAll();
      await setBoolToLocal('NEEDS_STORAGE_CLEAR_V1', false);
      print('Cleared corrupted secure storage from old version');
    }
  } catch (e) {
    print('Error clearing storage: $e');
  }
  
  hiveService.init();

  appButtonBackgroundColorGlobal = appColorPrimary;
  defaultAppButtonRadius = defaultRadius;
  defaultAppButtonElevation = 0;
  defaultAppButtonTextColorGlobal = primaryTextColor;
  passwordLengthGlobal = 8;

  selectedLanguageCode(await getStringFromLocal(SELECTED_LANGUAGE_CODE) ?? DEFAULT_LANGUAGE);

  await initialize(aLocaleLanguageList: languageList(), defaultLanguage: selectedLanguageCode.value);

  final BaseLanguage temp = await const AppLocalizations().load(Locale(selectedLanguageCode.value));
  locale = temp.obs;
  locale.value = await const AppLocalizations().load(Locale(selectedLanguageCode.value));

  Map<String, dynamic>? cachedConfigKey = await getJsonFromLocal(SharedPreferenceConst.CACHE_CONFIGURATION_RESPONSE);
  if (cachedConfigKey != null) {
    appConfigs(ConfigurationResponse.fromJson(cachedConfigKey));
  }

  isLoggedIn(await getBoolFromLocal(SharedPreferenceConst.IS_LOGGED_IN));
  setBoolToLocal(SharedPreferenceConst.IS_LOGGED_IN, isLoggedIn.value);

  Map<String, dynamic>? cachedLoginUserDataKey = await getJsonFromLocal(SharedPreferenceConst.USER_DATA);
  if (cachedLoginUserDataKey != null) {
    loginUserData(UserData.fromJson(cachedLoginUserDataKey));
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: AppRoutes.splash,
      navigatorKey: navigatorKey,
      title: APP_NAME,
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.noTransition,
      supportedLocales: LanguageDataModel.languageLocales(),
      getPages: AppRoutes.routes,
      localizationsDelegates: const [
        AppLocalizations(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) => Locale(selectedLanguageCode.value),
      fallbackLocale: const Locale(DEFAULT_LANGUAGE),
      locale: Locale(selectedLanguageCode.value),
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      builder: (context, child) {
        return FToastBuilder()(
            context,
            Theme(
              data: AppTheme.darkTheme.copyWith(
                pageTransitionsTheme: PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: AppPageTransitionsBuilder(),
                    TargetPlatform.iOS: AppPageTransitionsBuilder(),
                  },
                ),
              ),
              child: child!,
            ));
      },
      initialBinding: BindingsBuilder(() {
        AppBindings().dependencies();
      }),
      /*  onGenerateRoute: (settings) {
        if (settings.name.validate().split('/').last.isDigit()) {
          return MaterialPageRoute(
            builder: (context) {
              return SplashScreen(deepLink: settings.name.validate(), link: true);
            },
          );
        } else {
          return MaterialPageRoute(builder: (_) => SplashScreen());
        }
      },*/
    );
  }
}