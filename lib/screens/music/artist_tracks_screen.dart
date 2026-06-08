import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:streamit_laravel/network/core_api.dart';
import 'package:streamit_laravel/screens/music/models/music_model.dart';
import 'package:streamit_laravel/screens/music/music_player_screen.dart';
import 'package:streamit_laravel/screens/music/services/audio_player_service.dart';

class ArtistTracksScreen extends StatefulWidget {
  final String artistName;
  const ArtistTracksScreen({super.key, required this.artistName});
  @override
  State<ArtistTracksScreen> createState() => _ArtistTracksScreenState();
}

class _ArtistTracksScreenState extends State<ArtistTracksScreen> {
  bool _loading = true;
  List<Music> _tracks = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final res = await CoreServiceApis.getTracksByArtist(widget.artistName);
    final data = res.data;
    final list = data is List ? data : (data is Map ? (data['data'] as List? ?? []) : <dynamic>[]);
    setState(() {
      _tracks = list.map((t) => Music.fromJson(t as Map<String, dynamic>)).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: const Color(0xFF0F0F1A),
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white), onPressed: () => Get.back()),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF6C63FF), Color(0xFF0F0F1A)])),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(height: 40),
                Container(width: 80, height: 80, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x336C63FF)), child: const Icon(Icons.person_rounded, color: Color(0xFF6C63FF), size: 44)),
                const SizedBox(height: 10),
                Text(widget.artistName, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
        ),
        if (_loading)
          const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF))))
        else if (_tracks.isEmpty)
          const SliverFillRemaining(child: Center(child: Text('No tracks found', style: TextStyle(color: Colors.white54))))
        else ...[
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(children: [
              Text('${_tracks.length} Tracks', style: const TextStyle(color: Colors.white54, fontSize: 14)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => AudioPlayerService.to.playTrack(_tracks.first, trackQueue: _tracks, index: 0),
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: const Text('Play All'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              ),
            ]),
          )),
          SliverList(delegate: SliverChildBuilderDelegate((ctx, i) {
            final t = _tracks[i];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              leading: ClipRRect(borderRadius: BorderRadius.circular(6),
                child: (t.thumbnailUrl?.isNotEmpty == true)
                    ? CachedNetworkImage(imageUrl: t.thumbnailUrl!, width: 48, height: 48, fit: BoxFit.cover)
                    : Container(width: 48, height: 48, color: const Color(0xFF2A2A3E), child: const Icon(Icons.music_note_rounded, color: Color(0xFF6C63FF)))),
              title: Text(t.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(t.albumName ?? t.genre ?? '', style: const TextStyle(color: Colors.white54, fontSize: 12)),
              trailing: Text(t.formattedDuration, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              onTap: () {
                AudioPlayerService.to.playTrack(t, trackQueue: _tracks, index: i);
                Get.to(() => MusicPlayerScreen(track: t), transition: Transition.downToUp);
              },
            );
          }, childCount: _tracks.length)),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ]),
    );
  }
}
