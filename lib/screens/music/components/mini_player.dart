import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marquee/marquee.dart';
import 'package:streamit_laravel/screens/music/services/audio_player_service.dart';
import 'package:streamit_laravel/screens/music/music_player_screen.dart';

/// Wrapper with swipe-to-dismiss functionality
class DismissibleMiniPlayer extends StatelessWidget {
  const DismissibleMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final svc = AudioPlayerService.to;
      if (svc.currentTrack.value == null) return const SizedBox.shrink();
      
      return Dismissible(
        key: const ValueKey('mini_player'),
        direction: DismissDirection.down,
        onDismissed: (_) => svc.stop(),
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red.withAlpha(77),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.close, color: Colors.red),
        ),
        child: const MiniPlayer(),
      );
    });
  }
}

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final svc = AudioPlayerService.to;
      if (svc.currentTrack.value == null) return const SizedBox.shrink();
      final track = svc.currentTrack.value!;
      return GestureDetector(
        onTap: () => Get.to(
          () => MusicPlayerScreen(track: track),
          transition: Transition.downToUp,
        ),
        child: Container(
          height: 64,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2E),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Color(0x66000000), blurRadius: 12, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() => LinearProgressIndicator(
                value: svc.progressPercent.clamp(0.0, 1.0),
                minHeight: 2,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
              )),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: (track.thumbnailUrl?.isNotEmpty == true)
                          ? CachedNetworkImage(
                              imageUrl: track.thumbnailUrl!,
                              width: 40, height: 40, fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => _art(),
                            )
                          : _art(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 18,
                          child: _MarqueeText(
                            text: track.title,
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 2),
                        SizedBox(
                          height: 14,
                          child: _MarqueeText(
                            text: track.displayArtist,
                            style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 11),
                          ),
                        ),
                      ],
                    )),
                    IconButton(
                      onPressed: () => svc.playPrevious(),
                      icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 4),
                    Obx(() => svc.isLoading.value
                        ? const SizedBox(
                            width: 28, height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6C63FF)),
                          )
                        : IconButton(
                            onPressed: () => svc.togglePlayPause(),
                            icon: Icon(
                              svc.isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white, size: 28,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          )),
                    const SizedBox(width: 4),
                    IconButton(
                      onPressed: () => svc.playNext(),
                      icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 22),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 2),
                    IconButton(
                      onPressed: () => svc.stop(),
                      icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _art() => Container(
    width: 40, height: 40,
    decoration: BoxDecoration(
      color: const Color(0x4D6C63FF),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.music_note_rounded, color: Color(0xFF6C63FF), size: 20),
  );
}

class _MarqueeText extends StatelessWidget {
  final String text;
  final TextStyle style;
  const _MarqueeText({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final span = TextSpan(text: text, style: style);
      final tp = TextPainter(text: span, maxLines: 1, textDirection: TextDirection.ltr);
      tp.layout(maxWidth: constraints.maxWidth);
      if (tp.didExceedMaxLines) {
        return Marquee(
          text: text,
          style: style,
          scrollAxis: Axis.horizontal,
          blankSpace: 60.0,
          velocity: 30.0,
          pauseAfterRound: const Duration(seconds: 2),
          startAfter: const Duration(seconds: 1),
          fadingEdgeStartFraction: 0.1,
          fadingEdgeEndFraction: 0.1,
        );
      }
      return Text(text, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
    });
  }
}
