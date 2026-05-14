import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/components/app_scaffold.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/utils/common_base.dart';

import '../../utils/common_functions.dart';
import 'shorts_controller.dart';
import 'components/short_video_player.dart';
import 'components/shorts_feed.dart';
import 'models/short_model.dart';

class ShortsScreen extends StatefulWidget {
  ShortsScreen({super.key});

  @override
  State<ShortsScreen> createState() => _ShortsScreenState();
}

class _ShortsScreenState extends State<ShortsScreen> {
  ShortsController get shortsController => Get.find<ShortsController>();

  @override
  void initState() {
    super.initState();
    shortsController.getShorts();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Obx(() => shortsController.isLoading.value
          ? Center(child: CircularProgressIndicator())
          : shortsController.shorts.isEmpty
              ? Center(
                  child: Text(
                    'No shorts available',
                    style: primaryTextStyle(size: 16),
                  ),
                )
              : ShortsFeed(
                  shorts: shortsController.shorts,
                  onLoadMore: shortsController.loadMoreShorts,
                  onRefresh: shortsController.refreshShorts,
                  hasMore: shortsController.hasMore.value,
                )),
    );
  }
}
