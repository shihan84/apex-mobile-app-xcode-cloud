import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/components/cached_image_widget.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/utils/common_base.dart';

import '../models/music_model.dart';
import '../artist_tracks_screen.dart';
import '../genre_browse_screen.dart';

class MusicFeed extends StatelessWidget {
  final RxList<Music> music;
  final Function(Music) onTrackTap;
  final Function(Music) onLike;
  final ScrollController? scrollController;

  const MusicFeed({
    super.key,
    required this.music,
    required this.onTrackTap,
    required this.onLike,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: music.length,
      itemBuilder: (context, index) {
        final track = music[index];
        return MusicCard(
          track: track,
          onTap: () => onTrackTap(track),
          onLike: () => onLike(track),
        );
      },
    );
  }
}

class MusicCard extends StatelessWidget {
  final Music track;
  final VoidCallback onTap;
  final VoidCallback onLike;

  const MusicCard({
    super.key,
    required this.track,
    required this.onTap,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
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
            // Album art
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: track.thumbnailUrl != null
                  ? CachedImageWidget(
                      url: track.thumbnailUrl!,
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.album, color: Colors.white, size: 32),
                    ),
            ),
            
            const SizedBox(width: 16),
            
            // Track info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    track.title,
                    style: primaryTextStyle(
                      size: 16,
                      weight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () => Get.to(() => ArtistTracksScreen(artistName: track.displayArtist)),
                    child: Text(
                      track.displayArtist,
                      style: secondaryTextStyle(size: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (track.albumName != null)
                    Text(
                      track.displayAlbum,
                      style: secondaryTextStyle(size: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.grey, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        track.formattedDuration,
                        style: secondaryTextStyle(size: 12),
                      ),
                      const Spacer(),
                      // Like button
                      GestureDetector(
                        onTap: onLike,
                        child: Row(
                          children: [
                            Icon(
                              track.isLiked ? Icons.favorite : Icons.favorite_border,
                              color: track.isLiked ? Colors.red : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              track.formattedLikeCount,
                              style: secondaryTextStyle(size: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Play count
                      Row(
                        children: [
                          Icon(Icons.play_arrow, color: Colors.grey, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            track.formattedPlayCount,
                            style: secondaryTextStyle(size: 12),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Premium badge
                      if (track.isPremium)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: appColorPrimary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'PREMIUM',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      // Explicit badge
                      if (track.isExplicit)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'EXPLICIT',
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
