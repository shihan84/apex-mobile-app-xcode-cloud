import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/components/app_no_data_widget.dart';
import 'package:streamit_laravel/components/app_scaffold.dart';
import 'package:streamit_laravel/main.dart';
import 'package:streamit_laravel/routes/app_routes.dart';
import 'package:streamit_laravel/screens/content/components/content_poster_component.dart';
import 'package:streamit_laravel/screens/content/content_list_controller.dart';
import 'package:streamit_laravel/screens/content/content_list_shimmer.dart';
import 'package:streamit_laravel/screens/content/model/content_model.dart';
import 'package:streamit_laravel/screens/slider/banner_widget.dart';
import 'package:streamit_laravel/utils/common_base.dart';
import 'package:streamit_laravel/utils/common_functions.dart';
import 'package:streamit_laravel/utils/empty_error_state_widget.dart';
import 'package:streamit_laravel/utils/extension/string_extension.dart';

class ContentListScreen extends StatelessWidget {
  final String? title;

  const ContentListScreen({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    // Get dynamic grid size (width + spacing)
    final dynamicSpacing = getDynamicSpacing();

    return GetBuilder(
      init: Get.find<ContentListController>(),
      builder: (contentListController) => Obx(
        () {
          final sliderCtrl = contentListController.sliderController;
          final bool showBanner = sliderCtrl.isLoading.value || sliderCtrl.listContent.isNotEmpty;

          return NewAppScaffold(
            isPinnedAppbar: true,
            scrollController: contentListController.scrollController,
            currentPage: contentListController.currentPage,
            isLoading: contentListController.isLoading,
            expandedHeight: showBanner ? Get.height * 0.40 : kToolbarHeight,
            appBarTitleText: title ?? sliderCtrl.sliderType.value.getContentTypeTitle(),
            topbarChild: showBanner
                ? BannerWidget(
                    expandedHeight: Get.height * 0.50,
                    sliderController: sliderCtrl,
                    tag: AppRoutes.banner,
                  )
                : const SizedBox.shrink(),
            onRefresh: contentListController.init,
            body: SnapHelperWidget(
              future: contentListController.listContentFuture.value,
              loadingWidget: ContentListShimmer(
                width: dynamicSpacing.$1,
                spacing: dynamicSpacing.$2,
              ),
              onSuccess: (response) {
                return Obx(
                  () {
                    if (contentListController.listContent.isEmpty && !contentListController.isLoading.value) {
                      return AppNoDataWidget(
                        title: locale.value.noContentFound,
                        subTitle: "${locale.value.no} ${contentListController.argumentData.stringArgument.getContentTypeTitle()} ${locale.value.isAvailableInThisCategory}",
                        retryText: locale.value.reload,
                        imageWidget: const ErrorStateWidget(),
                        onRetry: contentListController.onRetry,
                      );
                    }
                    return AnimatedWrap(
                      listAnimationType: commonListAnimationType,
                      runSpacing: dynamicSpacing.$2,
                      spacing: dynamicSpacing.$2,
                      itemCount: contentListController.listContent.length,
                      itemBuilder: (context, index) {
                        final PosterDataModel content = contentListController.listContent[index];
                        return ContentListComponent(contentData: content);
                      },
                    );
                  },
                );
              },
              errorBuilder: (error) {
                return AppNoDataWidget(
                  title: error,
                  retryText: locale.value.reload,
                  imageWidget: const ErrorStateWidget(),
                  onRetry: contentListController.onRefresh,
                ).center().visible(!contentListController.isLoading.value);
              },
            ),
          );
        },
      ),
    );
  }
}