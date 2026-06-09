import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streamit_laravel/screens/music/models/music_model.dart';
import 'package:streamit_laravel/screens/music/music_controller.dart';
import 'package:streamit_laravel/screens/music/music_player_screen.dart';
import 'package:streamit_laravel/screens/music/music_screen.dart';
import 'package:streamit_laravel/screens/music/services/audio_player_service.dart';

class MusicHomeRow extends StatelessWidget {
  const MusicHomeRow({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MusicController>();
    return Obx(() {
      final tracks = ctrl.featuredMusic;
      if (tracks.isEmpty) return const SizedBox.shrink();
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 8, 12),
          child: Row(children: [
            const Expanded(child: Text('Featured Music',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
            TextButton(
              onPressed: () => Get.to(() => MusicScreen()),
              child: const Text('See all', style: TextStyle(color: Color(0xFF6C63FF), fontSize: 13)),
            ),
          ]),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: tracks.length,
            itemBuilder: (context, i) {
              final t = tracks[i];
              return GestureDetector(
                onTap: () {
                  _saveRecentlyPlayed(t);
                  AudioPlayerService.to.playTrack(t, trackQueue: tracks.toList(), index: i);
                  Get.to(() => MusicPlayerScreen(track: t), transition: Transition.downToUp);
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E2E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: (t.thumbnailUrl?.isNotEmpty == true)
                          ? CachedNetworkImage(imageUrl: t.thumbnailUrl!, height: 130, width: 140, fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => _artPlaceholder())
                          : _artPlaceholder(),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                      child: Text(t.title,
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(t.displayArtist,
                        style: const TextStyle(color: Color(0x80FFFFFF), fontSize: 11),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ]);
    });
  }

  Widget _artPlaceholder() => Container(
    height: 130, width: 140,
    color: const Color(0xFF2A2A3E),
    child: const Icon(Icons.music_note_rounded, color: Color(0xFF6C63FF), size: 40),
  );

  static Future<void> _saveRecentlyPlayed(Music track) async {
    const key = 'music_recently_played';
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(key) ?? [];
      final existing = raw.map((s) {
        try { return Music.fromJson(jsonDecode(s) as Map<String, dynamic>); }
        catch (_) { return null; }
      }).whereType<Music>().toList();
      final updated = [track, ...existing.where((t) => t.id != track.id)].take(10).toList();
      await prefs.setStringList(key, updated.map((t) => jsonEncode(t.toJson())).toList());
    } catch (_) {}
  }
}
