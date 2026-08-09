import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:apexprime_tv/controllers/base_controller.dart';
import 'package:apexprime_tv/generated/assets.dart';
import 'package:apexprime_tv/main.dart';
import 'package:apexprime_tv/network/core_api.dart';
import 'package:apexprime_tv/screens/content/content_details_screen.dart';
import 'package:apexprime_tv/screens/content/model/content_model.dart';
import 'package:apexprime_tv/screens/profile/watching_profile/watching_profile_screen.dart';
import 'package:apexprime_tv/screens/walk_through/model/walkthrough_model.dart';
import 'package:apexprime_tv/screens/walk_through/walk_through_screen.dart';
import 'package:apexprime_tv/services/local_storage_service.dart';
import 'package:apexprime_tv/utils/common_functions.dart';

import '../utils/constants.dart';
import 'dashboard/dashboard_screen.dart';
import 'live_tv/live_tv_details/live_tv_details_screen.dart';
import 'splash/app_open_ad_screen.dart';

class SplashScreenController extends BaseListController<WalkthroughModel> {
  RxBool appNotSynced = false.obs;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  @override
  void onReady() {
    try {
      Get.changeThemeMode(ThemeMode.dark);
    } catch (e) {
      log('getThemeFromLocal from cache E: $e');
    }
    super.onReady();
  }

  @override
  Future<void> getListData({bool showLoader = true}) async {
    await CoreServiceApis.getOnboardingData().then(
      (value) {
        if (value.isNotEmpty) {
          listContent(value);
        } else {
          getDefaultWalkthroughPageList();
        }
      },
    ).catchError((e) {
      getDefaultWalkthroughPageList();
    });
  }

  void getDefaultWalkthroughPageList() {
    listContent.clear();
    listContent.add(WalkthroughModel(title: locale.value.walkthroughTitle1, image: Assets.walkthroughImagesWalkImage1, description: locale.value.walkthroughDesp1));
    listContent.add(WalkthroughModel(title: locale.value.walkthroughTitle2, image: Assets.walkthroughImagesWalkImage2, description: locale.value.walkthroughDesp2));
    listContent.add(WalkthroughModel(title: locale.value.walkthroughTitle3, image: Assets.walkthroughImagesWalkImage3, description: locale.value.walkthroughDesp3));
  }

  Future<void> init() async {
    if (await getBoolFromLocal(SharedPreferenceConst.IS_FIRST_TIME, defaultValue: true)) {
      await getListData();
    }

    await Future.wait(
      [
        getCacheData(),
        getDeviceInfo(),
        getAppConfigurations().then(
          (value) async {
            // Wait a minimal delay for UI to settle, then navigate
            await Future.delayed(
              const Duration(milliseconds: 500),
              () => navigateFromSplash(),
            );
          },
        ).catchError((e) async {
          log('Config error: $e');
          appNotSynced(!await getBoolFromLocal(SharedPreferenceConst.IS_APP_CONFIGURATION_SYNCED_ONCE));
          // Navigate anyway with fallback config
          await Future.delayed(
            const Duration(milliseconds: 500),
            () => navigateFromSplash(),
          );
        }),
      ],
    ).catchError((e) async {
      log('Splash init error: $e');
      // Navigate to dashboard as fallback — never leave user on blank screen
      await Future.delayed(
        const Duration(milliseconds: 300),
        () => Get.offAll(() => DashboardScreen(), duration: const Duration(milliseconds: 500), curve: Curves.linearToEaseOut),
      );
    });
  }

  /// Decides the next screen after splash and optionally shows an app-open ad first.
  Future<void> navigateFromSplash() async {
    if (appConfigs.value.status == false && appNotSynced.value) {
      log('Using fallback configuration');
    }

    final bool isFirstTime = await getBoolFromLocal(SharedPreferenceConst.IS_FIRST_TIME, defaultValue: true);
    final bool userLoggedIn = await getBoolFromLocal(SharedPreferenceConst.IS_LOGGED_IN, defaultValue: false) || isLoggedIn.value;

    Future<void> goToNext() async {
      if (isFirstTime) {
        Get.off(() => WalkThroughScreen(walkthroughPageList: listContent));
        await setBoolToLocal(SharedPreferenceConst.IS_FIRST_TIME, false);
      } else if (userLoggedIn) {
        Get.off(() => WatchingProfileScreen(), arguments: true);
      } else {
        Get.offAll(() => DashboardScreen(), duration: const Duration(milliseconds: 500), curve: Curves.linearToEaseOut);
      }
    }

    // Show app-open custom ad if configured
    if (appConfigs.value.appOpenAd.isAvailable) {
      Get.off(
        () => AppOpenAdScreen(
          ad: appConfigs.value.appOpenAd,
          onCompleted: goToNext,
        ),
      );
      return;
    }

    await goToNext();
  }

  void handleDeepLinking({required String deepLink}) {
    if (deepLink.split("/")[2] == VideoType.movie || deepLink.split("/")[2] == VideoType.episode || deepLink.split("/")[2] == VideoType.tvshow || deepLink.split("/")[2] == VideoType.video) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAll(() => ContentDetailsScreen(), arguments: PosterDataModel(id: int.parse(deepLink.split("/").last), details: ContentData(type: VideoType.episode)));
      });
    } else if (deepLink.split("/")[2] == locale.value.liveTv) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAll(() => LiveContentDetailsScreen(), arguments: PosterDataModel(id: int.parse(deepLink.split("/").last), details: ContentData(type: VideoType.liveTv)));
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAll(() => DashboardScreen());
      });
    }
  }
}