import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/components/app_logo_widget.dart';
import 'package:streamit_laravel/components/no_internet_widget.dart';
import 'package:streamit_laravel/controllers/connectivity_controller.dart';
import 'package:streamit_laravel/main.dart';
import 'package:streamit_laravel/utils/common_functions.dart';

import '../components/app_scaffold.dart';
import '../utils/colors.dart';
import 'splash_controller.dart';

class SplashScreen extends StatelessWidget {
  final String deepLink;
  final bool? link;

  SplashScreen({super.key, this.deepLink = "", this.link});

  final SplashScreenController splashController = Get.find<SplashScreenController>();

  @override
  Widget build(BuildContext context) {
    if (link == true) {
      splashController.handleDeepLinking(deepLink: deepLink);
    }
    ConnectivityController.instance.onInternetRestored = () async {
      await getAppConfigurations(
        loaderOnOff: (bool isLoading) {
          splashController.setLoading(isLoading);
        },
      ).then((value) => splashController.init());
    };
    return NewAppScaffold(
      scrollController: splashController.scrollController,
      hideAppBar: true,
      applyLeadingBackButton: false,
      scaffoldBackgroundColor: appScreenBackgroundDark,
      isLoading: splashController.isLoading,
      isScrollableWidget: false,
      body: Container(
        width: Get.width,
        height: Get.height,
        color: appScreenBackgroundDark,
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: AppLoaderWidget(
            size: Size(Get.width - 2, Get.height - 2),
          ),
        ),
      ),
    );
  }
}