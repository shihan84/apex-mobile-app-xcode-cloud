import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/components/app_no_data_widget.dart';
import 'package:streamit_laravel/components/cached_image_widget.dart';
import 'package:streamit_laravel/models/base_response_model.dart';
import 'package:streamit_laravel/screens/content/filtered_content_list_screen.dart';
import 'package:streamit_laravel/screens/home/model/dashboard_res_model.dart';
import 'package:streamit_laravel/utils/api_end_points.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/utils/common_base.dart';
import 'package:streamit_laravel/utils/common_functions.dart';

import '../../../../components/app_scaffold.dart';
import '../../../../main.dart';

class LanguageListScreen extends StatelessWidget {
  final List<LanguageModel> languageList;
  final String title;

  const LanguageListScreen({
    super.key,
    required this.languageList,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoading: false.obs,
      scaffoldBackgroundColor: appScreenBackgroundDark,
      appBarTitleText: title,
      body: languageList.isEmpty
          ? Center(
              child: AppNoDataWidget(
                title: locale.value.noContentFound,
                retryText: '',
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: AnimatedWrap(
                runSpacing: 6,
                spacing: 6,
                listAnimationType: commonListAnimationType,
                itemCount: languageList.length,
                itemBuilder: (context, index) {
                  final LanguageModel language = languageList[index];
                  final dynamicSpacing = getDynamicSpacing(crossAxisChildrenCount: 4);
                  return GestureDetector(
                    onTap: () {
                      Get.to(
                        () => FilteredContentListScreen(title: language.name),
                        arguments: ArgumentModel(stringArgument: '${ApiRequestKeys.language}=${language.name}'),
                      );
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
                },
              ),
            ),
    );
  }
}