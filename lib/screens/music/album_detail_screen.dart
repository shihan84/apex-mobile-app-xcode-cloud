import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apexprime_tv/network/core_api.dart';
import 'package:apexprime_tv/screens/music/models/music_model.dart';
import 'package:apexprime_tv/screens/music/services/audio_player_service.dart';

class AlbumDetailScreen extends StatefulWidget {
  final int albumId;
  final String albumTitle;
  final String? coverUrl;
  const AlbumDetailScreen({super.key, required this.albumId, required this.albumTitle, this.coverUrl});

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  bool _loading = true;
  Map<String, dynamic>? _album;
  List<Music> _tracks = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await CoreServiceApis.getAlbumDetail(widget.albumId);
    if (res.status && res.data != null) {
      final data = res.data is Map ? res.data as Map<String, dynamic> : <String, dynamic>{};
      final rawTracks = data['tracks'] as List? ?? [];
      setState(() {
        _album = data;
        _tracks = rawTracks.map((t) => Music.fromJson(t as Map<String, dynamic>)).toList();
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coverUrl = _album?['cover_art_url'] as String? ?? widget.coverUrl;
    final artist = _album?['artist_name'] as String? ?? '';
    final genre = _album?['genre'] as String? ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : CustomScrollView(slivers: [
              SliverAppBar(
                expandedHeight: 280,
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
                  Text(widget.albumTitle, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(artist, style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Row(children: [
                    if (genre.isNotEmpty) ...[
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(20)),
                        child: Text(genre, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                      const SizedBox(width: 8),
                    ],
                    Text('\${_tracks.length} tracks', style: const TextStyle(color: Colors.white54, fontSize: 13)),
                  ]),
                  const SizedBox(height: 20),
                  if (_tracks.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () => AudioPlayerService.to.playTrack(_tracks.first, trackQueue: _tracks, index: 0),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Play All'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  const SizedBox(height: 24),
                  const Text('TRACKS', style: TextStyle(color: Colors.white38, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                ]),
              )),
              SliverList(delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final t = _tracks[i];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: (t.thumbnailUrl?.isNotEmpty == true)
                          ? CachedNetworkImage(imageUrl: t.thumbnailUrl!, width: 48, height: 48, fit: BoxFit.cover)
                          : Container(width: 48, height: 48, color: const Color(0xFF2A2A3E),
                              child: const Icon(Icons.music_note_rounded, color: Color(0xFF6C63FF))),
                    ),
                    title: Text(t.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(t.displayArtist, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(t.formattedDuration, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                      const SizedBox(width: 8),
                      const Icon(Icons.more_vert_rounded, color: Colors.white38, size: 20),
                    ]),
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
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF2A2A3E), Color(0xFF1A1A2E)])),
    child: const Center(child: Icon(Icons.album_rounded, color: Color(0xFF6C63FF), size: 80)),
  );
}
