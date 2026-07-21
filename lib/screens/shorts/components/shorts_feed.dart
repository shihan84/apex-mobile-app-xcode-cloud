import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:apexprime_tv/components/cached_image_widget.dart';
import 'package:apexprime_tv/utils/colors.dart';
import 'package:apexprime_tv/utils/common_base.dart';

import '../models/short_model.dart';

class ShortsFeed extends StatelessWidget {
  final RxList<Short> shorts;
  final VoidCallback? onLoadMore;
  final Future<void> Function()? onRefresh;
  final bool hasMore;

  const ShortsFeed({
    super.key,
    required this.shorts,
    this.onLoadMore,
    this.onRefresh,
    this.hasMore = false,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo is ScrollEndNotification && hasMore && onLoadMore != null) {
          onLoadMore!();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: onRefresh ?? () async {},
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemCount: shorts.length,
          itemBuilder: (context, index) {
            final short = shorts[index];
            return ShortVideoCard(
              short: short,
              onTap: () {
                // TODO: Navigate to short detail screen
                log('Tapped on short: ${short.name}');
              },
              onLike: () {
                // TODO: Implement like functionality
                log('Liked short: ${short.name}');
              },
              onShare: () {
                // TODO: Implement share functionality
                log('Shared short: ${short.name}');
              },
            );
          },
        ),
      ),
    );
  }
}

class ShortVideoCard extends StatelessWidget {
  final Short short;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onShare;

  const ShortVideoCard({
    super.key,
    required this.short,
    required this.onTap,
    required this.onLike,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Get.width,
        height: Get.height * 0.8,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // Video thumbnail
            Positioned.fill(
              child: short.thumbnailUrl != null
                  ? CachedImageWidget(
                      url: short.thumbnailUrl!,
                      fit: BoxFit.cover,
                      width: Get.width,
                      height: Get.height * 0.8,
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),
            ),
            
            // Top overlay with creator info
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  // Creator avatar
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  const Spacer(),
                  // More options
                  GestureDetector(
                    onTap: () {
                      // TODO: Show more options
                    },
                    child: Icon(Icons.more_vert, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Bottom overlay with actions and info
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Short title
                  Text(
                    short.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Stats and actions
                  Row(
                    children: [
                      // View count
                      Row(
                        children: [
                          Icon(Icons.visibility, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            short.formattedViewCount,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Like button
                      GestureDetector(
                        onTap: onLike,
                        child: Row(
                          children: [
                            Icon(
                              short.isLiked ? Icons.favorite : Icons.favorite_border,
                              color: short.isLiked ? Colors.red : Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              short.formattedLikeCount,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Share button
                      GestureDetector(
                        onTap: onShare,
                        child: Icon(Icons.share, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Duration indicator
            if (short.duration != null)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    short.formattedDuration,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
