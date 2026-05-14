import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/components/cached_image_widget.dart';
import 'package:streamit_laravel/generated/assets.dart';
import 'package:streamit_laravel/routes/app_routes.dart';
import 'package:streamit_laravel/screens/auth/other/notification_screen.dart';
import 'package:streamit_laravel/screens/home/shimmer_home.dart';
import 'package:streamit_laravel/screens/slider/banner_widget.dart';
import 'package:streamit_laravel/screens/slider/slider_top_widget.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/utils/common_base.dart';
import 'package:streamit_laravel/utils/common_functions.dart';

import '../../components/app_scaffold.dart';
import '../../main.dart';
import 'components/category_list_component.dart';
import 'home_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeController get homeScreenController => Get.find<HomeController>();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sliderCtrl = homeScreenController.sliderController;
      final bool showBanner = sliderCtrl.isLoading.value || sliderCtrl.listContent.isNotEmpty;

      return NewAppScaffold(
        applyLeadingBackButton: false,
        scrollController: homeScreenController.scrollController,
        appBarChild: SliderTopWidget(),
        expandedHeight: showBanner ? Get.height * 0.36 : kToolbarHeight,
        isPinnedAppbar: true,
        scaffoldBackgroundColor: appScreenBackgroundDark,
        bodyPadding: EdgeInsets.zero,
        onRefresh: homeScreenController.init,
        titleWidget: const CachedImageWidget(
          url: Assets.assetsAppMiniLogo,
          height: 30,
          width: 30,
        ),
        actions: [
          if (isLoggedIn.value && selectedAccountProfile.value.isChildProfile.validate() == 0)
            IconButton(
              onPressed: () {
                doIfLogin(
                  onLoggedIn: () {
                    Get.to(() => NotificationScreen());
                  },
                );
              },
              icon: Obx(() {
                return Badge.count(
                  isLabelVisible: appUnReadNotificationCount.value > 0,
                  textStyle: commonW500PrimaryTextStyle(size: 10),
                  padding: EdgeInsets.zero,
                  backgroundColor: appColorPrimary,
                  count: appUnReadNotificationCount.value > 0 ? appUnReadNotificationCount.value : 0,
                  child: IconWidget(
                    imgPath: Assets.iconsBell,
                    size: 24,
                  ),
                );
              }),
            )
        ],
        topbarChild: showBanner
            ? BannerWidget(
                sliderController: sliderCtrl,
                tag: AppRoutes.home,
              )
            : const SizedBox.shrink(),
        body: Obx(
          () => AnimatedWrap(
            listAnimationType: commonListAnimationType,
            children: [
              SnapHelperWidget(
                future: homeScreenController.dashboardDetailsFuture.value,
                initialData: cachedDashboardDetailResponse,
                loadingWidget: const ShimmerHome(),
                errorBuilder: (error) {
                  return const SizedBox.shrink();
                },
                onSuccess: (res) {
                  return CategoryListComponent(
                    categoryList: homeScreenController.dashboardOtherDetailsSectionList,
                    onRemoveAd: (mainIndex, listIndex) {
                      homeScreenController.removeAdFromSection(mainIndex, listIndex);
                    },
                  );
                },
              ),
              Obx(
                () => ShimmerHome().visible(homeScreenController.showCategoryShimmer.value),
              ),
            ],
          ),
        ),
      );
    });
  }
}