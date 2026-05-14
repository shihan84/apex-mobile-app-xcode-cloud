import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/components/cached_image_widget.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/utils/common_base.dart';

import '../models/playlist_model.dart';

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;

  const PlaylistCard({
    super.key,
    required this.playlist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: appColorSecondary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Playlist thumbnail
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: playlist.thumbnailUrl != null
                  ? CachedImageWidget(
                      url: playlist.thumbnailUrl!,
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.playlist_play, color: Colors.white, size: 32),
                    ),
            ),
            
            const SizedBox(width: 16),
            
            // Playlist info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    playlist.name,
                    style: primaryTextStyle(
                      size: 16,
                      weight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (playlist.description != null)
                    Text(
                      playlist.description!,
                      style: secondaryTextStyle(size: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.music_note, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${playlist.formattedTrackCount} tracks',
                        style: secondaryTextStyle(size: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        playlist.formattedDuration,
                        style: secondaryTextStyle(size: 12),
                      ),
                      const Spacer(),
                      if (playlist.isFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: appColorPrimary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Featured',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
