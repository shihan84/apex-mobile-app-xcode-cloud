import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:streamit_laravel/network/core_api.dart';
import 'package:streamit_laravel/screens/music/models/music_model.dart';
import 'package:streamit_laravel/screens/music/services/audio_player_service.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final int playlistId;
  final String playlistName;
  final String? coverUrl;
  const PlaylistDetailScreen({super.key, required this.playlistId, required this.playlistName, this.coverUrl});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  bool _loading = true;
  Map<String, dynamic>? _playlist;
  List<Music> _tracks = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final res = await CoreServiceApis.getPlaylistDetail(widget.playlistId);
    if (res.status && res.data != null) {
      final data = res.data is Map ? res.data as Map<String, dynamic> : <String, dynamic>{};
      final rawTracks = data['tracks'] as List? ?? [];
      setState(() {
        _playlist = data;
        _tracks = rawTracks.map((t) => Music.fromJson(t as Map<String, dynamic>)).toList();
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coverUrl = _playlist?['cover_art_url'] as String? ?? widget.coverUrl;
    final desc = _playlist?['description'] as String? ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : CustomScrollView(slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: const Color(0xFF0F0F1A),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(fit: StackFit.expand, children: [
                    coverUrl != null && coverUrl.isNotEmpty
                        ? CachedNetworkImage(imageUrl: coverUrl, fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _defaultCover())
                        : _defaultCover(),
                    Container(decoration: const BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xFF0F0F1A)]),
                    )),
                  ]),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
              SliverToBoxAdapter(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.playlistName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 8),
                  Text('\${_tracks.length} tracks', style: const TextStyle(color: Colors.white38, fontSize: 13)),
                  const SizedBox(height: 16),
                  if (_tracks.isNotEmpty)
                    Row(children: [
                      Expanded(child: ElevatedButton.icon(
                        onPressed: () => AudioPlayerService.to.playTrack(_tracks.first, trackQueue: _tracks, index: 0),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Play All'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF), foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      )),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          AudioPlayerService.to.toggleShuffle();
                          AudioPlayerService.to.playTrack(_tracks.first, trackQueue: _tracks, index: 0);
                        },
                        icon: const Icon(Icons.shuffle_rounded, size: 18),
                        label: const Text('Shuffle'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ]),
                  const SizedBox(height: 20),
                  const Text('TRACKS', style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                ]),
              )),
              SliverList(delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final t = _tracks[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('\${i + 1}', style: const TextStyle(color: Colors.white38, fontSize: 14, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: (t.thumbnailUrl?.isNotEmpty == true)
                            ? CachedNetworkImage(imageUrl: t.thumbnailUrl!, width: 44, height: 44, fit: BoxFit.cover)
                            : Container(width: 44, height: 44, color: const Color(0xFF2A2A3E),
                                child: const Icon(Icons.music_note_rounded, color: Color(0xFF6C63FF), size: 20)),
                      ),
                    ]),
                    title: Text(t.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(t.displayArtist, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    trailing: Text(t.formattedDuration, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    onTap: () => AudioPlayerService.to.playTrack(t, trackQueue: _tracks, index: i),
                  );
                },
                childCount: _tracks.length,
              )),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ]),
    );
  }

  Widget _defaultCover() => Container(
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1A2A3E), Color(0xFF0F0F1A)])),
    child: const Center(child: Icon(Icons.queue_music_rounded, color: Color(0xFF6C63FF), size: 80)),
  );
}
