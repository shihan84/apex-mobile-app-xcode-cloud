import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/components/app_no_data_widget.dart';
import 'package:streamit_laravel/components/app_scaffold.dart';
import 'package:streamit_laravel/main.dart';
import 'package:streamit_laravel/screens/content/components/content_poster_component.dart';
import 'package:streamit_laravel/screens/content/content_list_shimmer.dart';
import 'package:streamit_laravel/screens/content/model/content_model.dart';
import 'package:streamit_laravel/screens/rented_content/rental_list_controller.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/utils/common_base.dart';
import 'package:streamit_laravel/utils/common_functions.dart';
import 'package:streamit_laravel/utils/empty_error_state_widget.dart';

class RentalListScreen extends StatelessWidget {
  RentalListScreen({super.key});

  final RentalListController rentedContentController = Get.find<RentalListController>();

  @override
  Widget build(BuildContext context) {
    final dynamicSpacing = getDynamicSpacing();
    return Obx(
      () => NewAppScaffold(
        isPinnedAppbar: true,
        scrollController: rentedContentController.scrollController,
        isLoading: rentedContentController.currentPage.value == 1 ? false.obs : rentedContentController.isLoading,
        currentPage: rentedContentController.currentPage,
        scaffoldBackgroundColor: appScreenBackgroundDark,
        appBarTitleText: locale.value.payPerView,
        body: Obx(
          () => SnapHelperWidget(
            future: rentedContentController.listContentFuture.value,
            initialData: cachedRentedContentList.isNotEmpty ? cachedRentedContentList : null,
            loadingWidget: ContentListShimmer(
              width: dynamicSpacing.$1,
              spacing: dynamicSpacing.$2,
            ),
            errorBuilder: (error) {
              return AppNoDataWidget(
                title: error,
                retryText: locale.value.reload,
                imageWidget: const ErrorStateWidget(),
                onRetry: rentedContentController.onRetry,
              ).visible(!rentedContentController.isLoading.value);
            },
            onSuccess: (res) {
              return Obx(
                () => rentedContentController.listContent.isEmpty
                    ? AppNoDataWidget(
                        title: locale.value.noPayPerViewContent,
                        subTitle: locale.value.browseAndRentContentToWatchInstantly,
                        retryText: locale.value.reload,
                        imageWidget: const ErrorStateWidget(),
                        onRetry: () {
                          rentedContentController.onRetry();
                        },
                      ).center().visible(!rentedContentController.isLoading.value)
                    : AnimatedWrap(
                        runSpacing: dynamicSpacing.$2,
                        spacing: dynamicSpacing.$2,
                        listAnimationType: commonListAnimationType,
                        itemCount: rentedContentController.listContent.length,
                        itemBuilder: (p0, index) {
                          PosterDataModel poster = rentedContentController.listContent[index];
                          return ContentListComponent(contentData: poster);
                        },
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}