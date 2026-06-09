import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:streamit_laravel/network/core_api.dart';
import 'package:streamit_laravel/screens/music/music_controller.dart';
import 'package:streamit_laravel/screens/music/services/audio_player_service.dart';
import 'models/music_model.dart';

class MusicPlayerScreen extends StatefulWidget {
  final Music track;
  const MusicPlayerScreen({super.key, required this.track});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String? _lyrics;
  bool _lyricsLoading = false;
  Color _gradientTop = const Color(0xFF1A1A2E);
  Color _gradientBottom = const Color(0xFF0F0F1A);
  String? _lastArtUrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabCtrl.addListener(() {
      if (_tabCtrl.index == 1 && _lyrics == null && !_lyricsLoading) _loadLyrics();
    });
    final svc = AudioPlayerService.to;
    _extractColors(svc.currentTrack.value?.thumbnailUrl);
    ever(svc.currentTrack, (track) => _extractColors(track?.thumbnailUrl));
  }

  Future<void> _extractColors(String? url) async {
    if (url == null || url.isEmpty || url == _lastArtUrl) return;
    _lastArtUrl = url;
    try {
      final pg = await PaletteGenerator.fromImageProvider(
        NetworkImage(url),
        size: const Size(100, 100),
        maximumColorCount: 8,
      );
      final dominant = pg.dominantColor?.color ?? const Color(0xFF1A1A2E);
      if (mounted) {
        setState(() {
          _gradientTop = dominant.withAlpha(220);
          _gradientBottom = Color.lerp(dominant, Colors.black, 0.85)!.withAlpha(255);
        });
      }
    } catch (_) {}
  }

  Future<void> _loadLyrics() async {
    final svc = AudioPlayerService.to;
    final track = svc.currentTrack.value ?? widget.track;
    setState(() => _lyricsLoading = true);
    final res = await CoreServiceApis.getMusicLyrics(track.id);
    setState(() {
      _lyrics = res.status ? (res.data?['lyrics'] as String? ?? track.lyrics ?? 'No lyrics available') : (track.lyrics ?? 'No lyrics available');
      _lyricsLoading = false;
    });
  }

  Future<void> _toggleLike(AudioPlayerService svc) async {
    final track = svc.currentTrack.value ?? widget.track;
    final wasLiked = track.isLiked;
    // Optimistic update
    svc.currentTrack.value = track.copyWith(isLiked: !wasLiked);
    try {
      Get.find<MusicController>().likeMusic(track.id);
    } catch (_) {
      // Revert on error
      svc.currentTrack.value = track.copyWith(isLiked: wasLiked);
    }
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final svc = AudioPlayerService.to;
    return Scaffold(
      backgroundColor: _gradientBottom,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 32),
          onPressed: () => Get.back(),
        ),
        title: Column(children: [
          Text("NOW PLAYING", style: TextStyle(color: Colors.white.withAlpha(130), fontSize: 11, letterSpacing: 2)),
          const SizedBox(height: 2),
          Obx(() => Text(svc.currentTrack.value?.albumName ?? "", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFF6C63FF),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [Tab(text: "Player"), Tab(text: "Lyrics")],
        ),
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_gradientTop, _gradientBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: TabBarView(controller: _tabCtrl, children: [
          _buildPlayer(svc),
          _buildLyrics(),
        ]),
      ),
    );
  }

  Widget _buildPlayer(AudioPlayerService svc) {
    return Obx(() {
      final current = svc.currentTrack.value ?? widget.track;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(children: [
          const SizedBox(height: 20),
          Hero(
            tag: "player_art_\${current.id}",
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.width - 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Color(0x666C63FF), blurRadius: 40, offset: Offset(0, 20))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: (current.thumbnailUrl?.isNotEmpty == true)
                    ? CachedNetworkImage(imageUrl: current.thumbnailUrl!, fit: BoxFit.cover, errorWidget: (_, __, ___) => _defaultArt())
                    : _defaultArt(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                height: 28,
                child: _MarqueeOrText(
                  text: current.title,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                height: 20,
                child: _MarqueeOrText(
                  text: current.displayArtist,
                  style: const TextStyle(color: Color(0x996C63FF), fontSize: 15),
                ),
              ),
            ])),
            Obx(() {
              final liked = svc.currentTrack.value?.isLiked ?? current.isLiked;
              return IconButton(
                icon: Icon(
                  liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: liked ? const Color(0xFF6C63FF) : Colors.white,
                  size: 26,
                ),
                onPressed: () => _toggleLike(svc),
              );
            }),
          ]),
          const SizedBox(height: 20),
          Obx(() => Column(children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: const Color(0xFF6C63FF),
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.white,
                overlayColor: const Color(0x336C63FF),
              ),
              child: Slider(
                value: svc.progressPercent.clamp(0.0, 1.0),
                onChanged: (v) => svc.seekTo(Duration(milliseconds: (v * svc.duration.value.inMilliseconds).round())),
              ),
            ),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(svc.positionText, style: const TextStyle(color: Color(0x80FFFFFF), fontSize: 12)),
                Text(svc.durationText, style: const TextStyle(color: Color(0x80FFFFFF), fontSize: 12)),
              ])),
          ])),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Obx(() => IconButton(
              icon: Icon(Icons.shuffle_rounded, color: svc.isShuffle.value ? const Color(0xFF6C63FF) : const Color(0x99FFFFFF), size: 22),
              onPressed: () => svc.toggleShuffle(),
            )),
            IconButton(icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 36), onPressed: () => svc.playPrevious()),
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
            IconButton(icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 36), onPressed: () => svc.playNext()),
            Obx(() {
              IconData icon; Color color;
              switch (svc.repeatMode.value) {
                case AudioRepeatMode.one: icon = Icons.repeat_one_rounded; color = const Color(0xFF6C63FF); break;
                case AudioRepeatMode.all: icon = Icons.repeat_rounded; color = const Color(0xFF6C63FF); break;
                default: icon = Icons.repeat_rounded; color = const Color(0x99FFFFFF);
              }
              return IconButton(icon: Icon(icon, color: color, size: 22), onPressed: () => svc.toggleRepeat());
            }),
          ]),
        ]),
      );
    });
  }

  Widget _buildLyrics() {
    if (_lyricsLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)));
    final text = _lyrics;
    if (text == null) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.lyrics_outlined, color: Colors.white24, size: 64),
      const SizedBox(height: 16),
      Text("Tap Player tab then Lyrics to load", style: TextStyle(color: Colors.white.withAlpha(80))),
    ]));
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.8)),
    );
  }

  Widget _defaultArt() => Container(
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF2A2A3E), Color(0xFF1A1A2E)])),
    child: const Center(child: Icon(Icons.music_note_rounded, color: Color(0xFF6C63FF), size: 80)),
  );
}

class _MarqueeOrText extends StatelessWidget {
  final String text;
  final TextStyle style;
  const _MarqueeOrText({required this.text, required this.style});

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
          blankSpace: 80.0,
          velocity: 35.0,
          pauseAfterRound: const Duration(seconds: 2),
          startAfter: const Duration(seconds: 1),
          fadingEdgeStartFraction: 0.08,
          fadingEdgeEndFraction: 0.08,
        );
      }
      return Text(text, style: style, maxLines: 1);
    });
  }
}
