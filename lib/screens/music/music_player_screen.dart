import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:streamit_laravel/screens/music/services/audio_player_service.dart';
import 'models/music_model.dart';

class MusicPlayerScreen extends StatelessWidget {
  final Music track;
  const MusicPlayerScreen({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    final svc = AudioPlayerService.to;
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 32),
          onPressed: () => Get.back(),
        ),
        title: Column(children: [
          Text('NOW PLAYING', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11, letterSpacing: 2)),
          const SizedBox(height: 2),
          Obx(() => Text(svc.currentTrack.value?.albumName ?? '', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.more_vert_rounded, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Obx(() {
        final current = svc.currentTrack.value ?? track;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(children: [
            const SizedBox(height: 24),
            // Album Art
            Hero(
              tag: 'player_art_${current.id}',
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.width - 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: const Color(0xFF6C63FF).withValues(alpha: 0.4), blurRadius: 40, offset: const Offset(0, 20))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: (current.thumbnailUrl?.isNotEmpty == true)
                      ? CachedNetworkImage(imageUrl: current.thumbnailUrl!, fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _defaultArt())
                      : _defaultArt(),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Title & Like
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(current.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(current.displayArtist, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 15)),
              ])),
              IconButton(
                icon: Icon(current.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: current.isLiked ? const Color(0xFF6C63FF) : Colors.white, size: 26),
                onPressed: () {},
              ),
            ]),
            const SizedBox(height: 24),
            // Seek bar
            Obx(() => Column(children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  activeTrackColor: const Color(0xFF6C63FF),
                  inactiveTrackColor: Colors.white24,
                  thumbColor: Colors.white,
                  overlayColor: const Color(0xFF6C63FF).withValues(alpha: 0.2),
                ),
                child: Slider(
                  value: svc.progressPercent.clamp(0.0, 1.0),
                  onChanged: (v) => svc.seekTo(Duration(milliseconds: (v * svc.duration.value.inMilliseconds).round())),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(svc.positionText, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                  Text(svc.durationText, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
                ]),
              ),
            ])),
            const SizedBox(height: 16),
            // Controls
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              // Shuffle
              Obx(() => IconButton(
                icon: Icon(Icons.shuffle_rounded, color: svc.isShuffle.value ? const Color(0xFF6C63FF) : Colors.white.withValues(alpha: 0.6), size: 22),
                onPressed: () => svc.toggleShuffle(),
              )),
              // Previous
              IconButton(icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 36), onPressed: () => svc.playPrevious()),
              // Play/Pause
              Obx(() => GestureDetector(
                onTap: () => svc.togglePlayPause(),
                child: Container(
                  width: 64, height: 64,
                  decoration: const BoxDecoration(color: Color(0xFF6C63FF), shape: BoxShape.circle),
                  child: svc.isLoading.value
                      ? const Padding(padding: EdgeInsets.all(18), child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Icon(svc.isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 36),
                ),
              )),
              // Next
              IconButton(icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 36), onPressed: () => svc.playNext()),
              // Repeat
              Obx(() {
                IconData icon;
                Color color;
                switch (svc.repeatMode.value) {
                  case AudioRepeatMode.one: icon = Icons.repeat_one_rounded; color = const Color(0xFF6C63FF); break;
                  case AudioRepeatMode.all: icon = Icons.repeat_rounded; color = const Color(0xFF6C63FF); break;
                  default: icon = Icons.repeat_rounded; color = Colors.white.withValues(alpha: 0.6);
                }
                return IconButton(icon: Icon(icon, color: color, size: 22), onPressed: () => svc.toggleRepeat());
              }),
            ]),
          ]),
        );
      }),
    );
  }

  Widget _defaultArt() => Container(
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF2A2A3E), Color(0xFF1A1A2E)])),
    child: const Center(child: Icon(Icons.music_note_rounded, color: Color(0xFF6C63FF), size: 80)),
  );
}
