import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apexprime_tv/components/cached_image_widget.dart';
import 'package:apexprime_tv/generated/assets.dart';
import 'package:apexprime_tv/screens/auth/other/notification_screen.dart';
import 'package:apexprime_tv/utils/colors.dart';
import 'package:apexprime_tv/utils/common_base.dart';
import 'package:apexprime_tv/utils/common_functions.dart';

class SliderTopWidget extends StatelessWidget {
  const SliderTopWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const CachedImageWidget(
          url: Assets.assetsAppMiniLogo,
          height: 30,
          width: 30,
        ),
        if (isLoggedIn.value)
          IconButton(
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            onPressed: () {
              doIfLogin(
                onLoggedIn: () {
                  Get.to(() => NotificationScreen());
                },
              );
            },
            icon: Badge.count(
              isLabelVisible: appUnReadNotificationCount.value > 0,
              padding: EdgeInsets.zero,
              backgroundColor: appColorPrimary,
              count: appUnReadNotificationCount.value,
              textStyle: commonW600PrimaryTextStyle(size: 10),
              child: IconWidget(
                imgPath: Assets.iconsBell,
                size: 24,
              ),
            ),
          )
      ],
    );
  }
}