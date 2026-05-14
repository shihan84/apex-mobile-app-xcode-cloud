import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/components/cached_image_widget.dart';
import 'package:streamit_laravel/generated/assets.dart';
import 'package:streamit_laravel/main.dart';
import 'package:streamit_laravel/screens/content/model/content_model.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/utils/common_base.dart';
import 'package:streamit_laravel/utils/extension/string_extension.dart';
import 'package:streamit_laravel/video_players/video_screen.dart';

import '../../../utils/common_functions.dart';
import '../models/hive_content_model.dart';

class DownloadComponent extends StatelessWidget {
  final HiveContentModel content;
  final Function(String title) onDelete;
  final Map<String, dynamic>? parsedContent;

  const DownloadComponent({
    super.key,
    required this.content,
    required this.onDelete,
    this.parsedContent,
  });

  @override
  Widget build(BuildContext context) {
    if (parsedContent == null) {
      return _ErrorPlaceholder(onDelete: onDelete(''));
    }

    final contentModel = ContentModel.fromContentJson(parsedContent!);
    // Set local file path for offline playback
    contentModel.localFilePath = content.localFilePath;

    // Hide age-restricted content from downloads list
    if (contentModel.details.isAgeRestrictedContent.getBoolInt() && selectedAccountProfile.value.isChildProfile.getBoolInt()) {
      return const Offstage();
    }

    return GestureDetector(
      onTap: () {
        Get.to(
          () => VideoScreen(title: contentModel.details.name, isFromDownloads: true),
          arguments: contentModel,
        );
      },
      child: Container(
        decoration: boxDecorationDefault(color: cardColor, borderRadius: radius(6)),
        child: Column(
          children: [
            _thumbnailComponent(),
            Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 16,
                  children: [
                    Text(
                      () {
                        if (contentModel.isEpisode) {
                          final episodeName = contentModel.details.tvShowData?.episodeName.validate();
                          if (episodeName != null && episodeName.isNotEmpty) return episodeName;

                          final detailsName = contentModel.details.name.validate();
                          if (detailsName.isNotEmpty) return detailsName;

                          final showName = contentModel.details.tvShowData?.name.validate() ?? '';
                          if (showName.isNotEmpty) return showName;
                        }

                        if (contentModel.details.tvShowData != null && contentModel.details.tvShowData!.name.validate().isNotEmpty) {
                          return contentModel.details.tvShowData!.name.validate();
                        }

                        return contentModel.details.name.validate();
                      }(),
                      style: commonPrimaryTextStyle(),
                    ).expand(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: IconWidget(imgPath: Assets.iconsTrash, color: appColorPrimary),
                      onPressed: () {
                        onDelete('${contentModel.details.name} ${contentModel.details.type.getContentTypeTitle()}');
                      },
                    ),
                  ],
                ),
                readMoreTextWidget(
                  contentModel.details.description,
                  trimLines: 3,
                ),
                8.height,
              ],
            ).paddingSymmetric(horizontal: 12, vertical: 8),
          ],
        ),
      ),
    );
  }

  Widget _thumbnailComponent() {
    final hasLocalThumb = content.localThumbnailPath != null && content.localThumbnailPath!.isNotEmpty;

    return Stack(
      children: [
        CachedImageWidget(
          url: hasLocalThumb ? content.localThumbnailPath.validate() : Assets.iconsWarning,
          width: Get.width,
          height: Get.height * 0.16,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          topLeftRadius: 6,
          topRightRadius: 6,
        ),
        Container(
          width: Get.width,
          height: Get.height * 0.16,
          decoration: boxDecorationDefault(
            borderRadius: BorderRadiusDirectional.only(
              topStart: radiusCircular(6),
              topEnd: radiusCircular(6),
            ),
            gradient: LinearGradient(
              colors: [
                black.withValues(alpha: 0.001),
                black.withValues(alpha: 0.002),
                black.withValues(alpha: 0.5),
                black.withValues(alpha: 0.7),
                black.withValues(alpha: 0.9),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        PositionedDirectional(
          bottom: ResponsiveSize.getBottom(4),
          start: ResponsiveSize.getStart(6),
          end: ResponsiveSize.getEnd(6),
          child: _progress(),
        )
      ],
    );
  }

  Widget _progress() {
    final percent = content.watchedProgress.clamp(0, 100);
    if (percent == 0) return const Offstage();

    return LinearProgressIndicator(
      value: percent / 100,
      backgroundColor: Colors.grey[800],
      valueColor: AlwaysStoppedAnimation<Color>(appColorPrimary),
      minHeight: 4,
    );
  }
}

class _ErrorPlaceholder extends StatelessWidget {
  final VoidCallback onDelete;

  const _ErrorPlaceholder({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationDefault(color: cardColor, borderRadius: radius(6)),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(child: Text(locale.value.unableToLoadDownload, style: const TextStyle(color: Colors.white))),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: IconWidget(imgPath: Assets.iconsTrash, color: appColorPrimary),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}