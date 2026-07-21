import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:apexprime_tv/components/app_no_data_widget.dart';
import 'package:apexprime_tv/components/app_scaffold.dart';
import 'package:apexprime_tv/components/cached_image_widget.dart';
import 'package:apexprime_tv/generated/assets.dart';
import 'package:apexprime_tv/main.dart';
import 'package:apexprime_tv/screens/content/components/content_poster_component.dart';
import 'package:apexprime_tv/screens/content/content_list_shimmer.dart';
import 'package:apexprime_tv/screens/content/filtered_content_list_controller.dart';
import 'package:apexprime_tv/screens/content/model/content_model.dart';
import 'package:apexprime_tv/utils/colors.dart';
import 'package:apexprime_tv/utils/common_base.dart';
import 'package:apexprime_tv/utils/common_functions.dart';
import 'package:apexprime_tv/utils/extension/string_extension.dart';

class FilteredContentListScreen extends StatelessWidget {
  final String title;

  final bool showFilter;

  FilteredContentListScreen({
    super.key,
    required this.title,
    this.showFilter = true,
  });

  final FilteredContentListController contentListController = Get.find<FilteredContentListController>();

  @override
  Widget build(BuildContext context) {
    final dynamicSpacing = getDynamicSpacing();
    return Obx(
      () => NewAppScaffold(
        appBarTitleText: title,
        scrollController: contentListController.scrollController,
        expandedHeight: Get.height * 0.07,
        currentPage: contentListController.currentPage,
        onRefresh: () => contentListController.getListData(showLoader: false),
        isPinnedAppbar: true,
        appBarBottomWidget: contentListController.availableFilter.isNotEmpty && showFilter
            ? Align(
                alignment: Alignment.centerLeft,
                child: HorizontalList(
                  itemCount: contentListController.availableFilter.length,
                  itemBuilder: (context, index) {
                    String tab = contentListController.availableFilter[index];
                    return Obx(
                      () => Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: boxDecorationDefault(
                          color: contentListController.currentFilterIndex.value == index ? appColorPrimary : Colors.transparent,
                          borderRadius: radius(20),
                          border: Border.all(color: contentListController.currentFilterIndex.value == index ? appColorPrimary : iconColor),
                        ),
                        child: Text(
                          tab.getContentTypeTitle(),
                          style: primaryTextStyle(size: 14),
                        ),
                      ).onTap(
                        () {
                          contentListController.currentFilterIndex.value = index;
                          contentListController.getListData();
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                    );
                  },
                ),
              )
            : null,
        body: SnapHelperWidget(
          future: contentListController.listContentFuture.value,
          loadingWidget: ContentListShimmer(
            width: dynamicSpacing.$1,
            spacing: dynamicSpacing.$2,
          ),
          onSuccess: (response) {
            return Obx(() {
              if (contentListController.isLoading.value)
                return ContentListShimmer(
                  width: dynamicSpacing.$1,
                  spacing: dynamicSpacing.$2,
                );
              if (contentListController.listContent.isEmpty && !contentListController.isLoading.value) {
                return AppNoDataWidget(
                  title: locale.value.noContentFound,
                  subTitle: locale.value.noContentMatchesFilter,
                  retryText: locale.value.reload,
                  imageWidget: CachedImageWidget(url: Assets.imagesRental, color: textSecondaryColorGlobal, height: 120),
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
            });
          },
          errorBuilder: (error) {
            return Obx(
              () => AppNoDataWidget(
                title: error,
                retryText: locale.value.reload,
                imageWidget: CachedImageWidget(url: Assets.imagesRental, color: textSecondaryColorGlobal, height: 120),
                onRetry: contentListController.onRetry,
              ).center().visible(!contentListController.isLoading.value),
            );
          },
        ),
      ),
    );
  }
}