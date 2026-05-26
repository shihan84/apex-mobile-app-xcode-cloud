// ignore_for_file: invalid_use_of_protected_member

import 'package:get/get.dart';
import 'package:streamit_laravel/generated/assets.dart';

import '../../main.dart';
import '../../utils/common_functions.dart';
import 'components/menu.dart';

class DashboardController extends GetxController {
  RxInt currentIndex = 0.obs;
  DateTime? currentBackPressTime;
  RxList<BottomBarItem> bottomNavItems = [
    BottomBarItem(
      title: () => locale.value.home,
      icon: Assets.iconsHouse,
      type: BottomItem.home.name,
      selectedIcon: Assets.iconsHouseFill,
    ),
    BottomBarItem(
      title: () => locale.value.shorts,
      icon: Assets.iconsVideoCamera,
      type: BottomItem.shorts.name,
      selectedIcon: Assets.iconsVideoCameraFill,
    ),
    BottomBarItem(
      title: () => locale.value.music,
      icon: Assets.iconsMusicNote,
      type: BottomItem.music.name,
      selectedIcon: Assets.iconsMusicNoteFill,
    ),
    if (appConfigs.value.enableLiveTv)
      BottomBarItem(
        title: () => locale.value.liveTv,
        icon: Assets.iconsTelevisionSimple,
        type: BottomItem.livetv.name,
        selectedIcon: Assets.iconsTelevisionSimpleFill,
      ),
    BottomBarItem(
      title: () => locale.value.profile,
      icon: Assets.iconsUserCircleGear,
      type: BottomItem.profile.name,
      selectedIcon: Assets.iconsUserCircleGearFill,
    ),
  ].obs;

  @override
  void onInit() {
    currentIndex(0);
    super.onInit();
  }

  void addDataOnBottomNav() {
    bottomNavItems.refresh();
  }
}