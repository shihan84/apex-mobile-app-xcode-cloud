import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:apexprime_tv/components/cached_image_widget.dart';
import 'package:apexprime_tv/models/base_response_model.dart';
import 'package:apexprime_tv/screens/content/filtered_content_list_screen.dart';
import 'package:apexprime_tv/screens/home/model/dashboard_res_model.dart';
import 'package:apexprime_tv/utils/api_end_points.dart';
import 'package:apexprime_tv/utils/common_base.dart';

import '../../../../components/shimmer_widget.dart';
import 'language_list_screen.dart';

class LanguageComponent extends StatelessWidget {
  final CategoryListModel languageDetails;
  final bool isLoading;

  const LanguageComponent({super.key, required this.languageDetails, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    if (languageDetails.data.isEmpty) return const SizedBox.shrink();
    final dynamicSpacing = getDynamicSpacing(crossAxisChildrenCount: 4);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        viewAllWidget(
          label: languageDetails.name.capitalizeEachWord(),
          showViewAll: (languageDetails.data as List<LanguageModel>).length >= 10,
          onButtonPressed: () {
            Get.to(
              () => LanguageListScreen(
                languageList: languageDetails.data as List<LanguageModel>,
                title: languageDetails.name.capitalizeEachWord(),
              ),
            );
          },
        ),
        HorizontalList(
          physics: isLoading ? const NeverScrollableScrollPhysics() : const AlwaysScrollableScrollPhysics(),
          spacing: dynamicSpacing.$2,
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemCount: languageDetails.data.length,
          itemBuilder: (context, index) {
            LanguageModel language = languageDetails.data[index];
            if (isLoading) {
              return ShimmerWidget(
                height: 60,
                width: dynamicSpacing.$1,
              );
            } else {
              return GestureDetector(
                onTap: () {
                  Get.to(() => FilteredContentListScreen(title: language.name), arguments: ArgumentModel(stringArgument: '${ApiRequestKeys.language}=${language.name}', intArgument: 1));
                },
                child: Stack(
                  children: [
                    Hero(
                      tag: 'language_${language.id}',
                      child: CachedImageWidget(
                        url: language.languageImage,
                        height: dynamicSpacing.$1,
                        width: dynamicSpacing.$1,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        radius: 6,
                      ),
                    ),
                    IgnorePointer(
                      ignoring: true,
                      child: Container(
                        height: dynamicSpacing.$1,
                        width: dynamicSpacing.$1,
                        foregroundDecoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              black.withValues(alpha: 0.0),
                              black.withValues(alpha: 0.2),
                              black.withValues(alpha: 0.5),
                              black.withValues(alpha: 0.9),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      bottom: 8,
                      start: 2,
                      end: 2,
                      child: Center(
                        child: Marquee(
                          child: Text(
                            language.name,
                            textAlign: TextAlign.center,
                            style: boldTextStyle(
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
          },
        ),
      ],
    );
  }
}