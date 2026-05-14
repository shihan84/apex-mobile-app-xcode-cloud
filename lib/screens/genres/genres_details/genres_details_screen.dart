import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/components/app_no_data_widget.dart';
import 'package:streamit_laravel/main.dart';
import 'package:streamit_laravel/screens/content/components/content_poster_component.dart';
import 'package:streamit_laravel/screens/content/content_list_shimmer.dart';
import 'package:streamit_laravel/screens/content/model/content_model.dart';
import 'package:streamit_laravel/screens/genres/genres_details/genres_details_controller.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/utils/common_base.dart';
import 'package:streamit_laravel/utils/common_functions.dart';
import 'package:streamit_laravel/utils/empty_error_state_widget.dart';
import 'package:streamit_laravel/utils/extension/string_extension.dart';

import '../../../components/app_scaffold.dart';
import '../model/genres_model.dart';
import 'components/genre_profile_component.dart';

class GenresDetailsScreen extends StatelessWidget {
  final GenreModel genreDetails;

  GenresDetailsScreen({super.key, required this.genreDetails});

  final GenresDetailsController contentListController = Get.find<GenresDetailsController>();

  @override
  Widget build(BuildContext context) {
    final dynamicSpacing = getDynamicSpacing();
    return NewAppScaffold(
      isPinnedAppbar: true,
      scrollController: contentListController.scrollController,
      appBarTitleText: genreDetails.name,
      scaffoldBackgroundColor: appScreenBackgroundDark,
      expandedHeight: Get.height * 0.45,
      topbarChild: GenreProfileComponent(genreDetail: genreDetails),
      appBarBottomWidget: contentListController.availableFilter.isNotEmpty
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
      onRefresh: () => contentListController.getListData(showLoader: false),
      body: Obx(
        () => SnapHelperWidget(
          future: contentListController.listContentFuture.value,
          loadingWidget: ContentListShimmer(
            width: dynamicSpacing.$1,
            spacing: dynamicSpacing.$2,
          ),
          onSuccess: (response) {
            return Obx(() {
              if (contentListController.isLoading.value) {
                return ContentListShimmer(
                  width: dynamicSpacing.$1,
                  spacing: dynamicSpacing.$2,
                );
              }
              if (contentListController.listContent.isEmpty && !contentListController.isLoading.value) {
                return AppNoDataWidget(
                  title: locale.value.noContentInGenre,
                  subTitle: locale.value.noContentAvailableInThisGenre,
                  retryText: locale.value.reload,
                  imageWidget: const ErrorStateWidget(),
                  onRetry: () => contentListController.getListData(),
                );
              }
              return AnimatedWrap(
                listAnimationType: commonListAnimationType,
                spacing: dynamicSpacing.$2,
                runSpacing: dynamicSpacing.$2,
                crossAxisAlignment: WrapCrossAlignment.center,
                runAlignment: WrapAlignment.center,
                itemCount: contentListController.listContent.length,
                itemBuilder: (context, index) {
                  final PosterDataModel content = contentListController.listContent[index];
                  return ContentListComponent(contentData: content);
                },
              );
            });
          },
          errorBuilder: (error) {
            return AppNoDataWidget(
              title: error,
              retryText: locale.value.reload,
              imageWidget: const ErrorStateWidget(),
              onRetry: () => contentListController.getListData(),
            ).visible(!contentListController.isLoading.value);
          },
        ),
      ),
    );
  }
}