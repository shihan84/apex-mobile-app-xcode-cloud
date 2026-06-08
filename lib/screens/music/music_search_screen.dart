import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:streamit_laravel/network/core_api.dart';
import 'package:streamit_laravel/screens/music/album_detail_screen.dart';
import 'package:streamit_laravel/screens/music/models/music_model.dart';
import 'package:streamit_laravel/screens/music/playlist_detail_screen.dart';
import 'package:streamit_laravel/screens/music/services/audio_player_service.dart';

class MusicSearchScreen extends StatefulWidget {
  const MusicSearchScreen({super.key});

  @override
  State<MusicSearchScreen> createState() => _MusicSearchScreenState();
}

class _MusicSearchScreenState extends State<MusicSearchScreen> {
  final _ctrl = TextEditingController();
  Timer? _debounce;
  bool _loading = false;
  List<Music> _tracks = [];
  List<Map<String, dynamic>> _albums = [];
  List<Map<String, dynamic>> _playlists = [];
  bool _hasSearched = false;

  void _onChanged(String q) {
    _debounce?.cancel();
    if (q.trim().length < 2) {
      setState(() { _tracks = []; _albums = []; _playlists = []; _hasSearched = false; });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(q.trim()));
  }

  Future<void> _search(String q) async {
    setState(() => _loading = true);
    final res = await CoreServiceApis.searchMusicGlobal(q);
    if (res.status && res.data != null) {
      final data = res.data as Map<String, dynamic>;
      setState(() {
        _tracks = (data['tracks'] as List? ?? [])
            .map((t) => Music.fromJson(t as Map<String, dynamic>)).toList();
        _albums = List<Map<String, dynamic>>.from(data['albums'] as List? ?? []);
        _playlists = List<Map<String, dynamic>>.from(data['playlists'] as List? ?? []);
        _hasSearched = true;
      });
    }
    setState(() => _loading = false);
  }

  @override
  void dispose() { _ctrl.dispose(); _debounce?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final hasResults = _tracks.isNotEmpty || _albums.isNotEmpty || _playlists.isNotEmpty;
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white), onPressed: () => Get.back()),
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          onChanged: _onChanged,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Search tracks, albums, playlists...',
            hintStyle: TextStyle(color: Colors.white.withAlpha(100), fontSize: 15),
            border: InputBorder.none,
            suffixIcon: _ctrl.text.isNotEmpty
                ? IconButton(icon: const Icon(Icons.clear, color: Colors.white54), onPressed: () { _ctrl.clear(); _onChanged(''); })
                : null,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : !_hasSearched
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.search_rounded, color: Colors.white.withAlpha(60), size: 72),
                  const SizedBox(height: 16),
                  Text('Search for music', style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 16)),
                ]))
              : !hasResults
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.music_off_rounded, color: Colors.white.withAlpha(60), size: 64),
                      const SizedBox(height: 16),
                      Text('No results for "\${_ctrl.text}"', style: TextStyle(color: Colors.white.withAlpha(100))),
                    ]))
                  : ListView(padding: const EdgeInsets.only(bottom: 100), children: [
                      if (_tracks.isNotEmpty) ...[
                        _sectionHeader('TRACKS'),
                        ..._tracks.map((t) => ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: ClipRRect(borderRadius: BorderRadius.circular(6),
                            child: (t.thumbnailUrl?.isNotEmpty == true)
                                ? CachedNetworkImage(imageUrl: t.thumbnailUrl!, width: 48, height: 48, fit: BoxFit.cover)
                                : Container(width: 48, height: 48, color: const Color(0xFF2A2A3E),
                                    child: const Icon(Icons.music_note_rounded, color: Color(0xFF6C63FF)))),
                          title: Text(t.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(t.displayArtist, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          trailing: Text(t.formattedDuration, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                          onTap: () => AudioPlayerService.to.playTrack(t, trackQueue: _tracks),
                        )),
                      ],
                      if (_albums.isNotEmpty) ...[
                        _sectionHeader('ALBUMS'),
                        ..._albums.map((a) => ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: ClipRRect(borderRadius: BorderRadius.circular(8),
                            child: (a['cover_art_url'] as String?)?.isNotEmpty == true
                                ? CachedNetworkImage(imageUrl: a['cover_art_url'] as String, width: 48, height: 48, fit: BoxFit.cover)
                                : Container(width: 48, height: 48, color: const Color(0xFF2A2A3E),
                                    child: const Icon(Icons.album_rounded, color: Color(0xFF6C63FF)))),
                          title: Text(a['title'] as String? ?? '', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                          subtitle: Text(a['artist_name'] as String? ?? '', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white38),
                          onTap: () => Get.to(() => AlbumDetailScreen(
                            albumId: a['id'] as int,
                            albumTitle: a['title'] as String? ?? '',
                            coverUrl: a['cover_art_url'] as String?,
                          )),
                        )),
                      ],
                      if (_playlists.isNotEmpty) ...[
                        _sectionHeader('PLAYLISTS'),
                        ..._playlists.map((p) => ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: ClipRRect(borderRadius: BorderRadius.circular(8),
                            child: (p['cover_art_url'] as String?)?.isNotEmpty == true
                                ? CachedNetworkImage(imageUrl: p['cover_art_url'] as String, width: 48, height: 48, fit: BoxFit.cover)
                                : Container(width: 48, height: 48, color: const Color(0xFF1A2A3E),
                                    child: const Icon(Icons.queue_music_rounded, color: Color(0xFF6C63FF)))),
                          title: Text(p['name'] as String? ?? '', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white38),
                          onTap: () => Get.to(() => PlaylistDetailScreen(
                            playlistId: p['id'] as int,
                            playlistName: p['name'] as String? ?? '',
                            coverUrl: p['cover_art_url'] as String?,
                          )),
                        )),
                      ],
                    ]),
    );
  }

  Widget _sectionHeader(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Text(title, style: const TextStyle(color: Colors.white38, fontSize: 11, letterSpacing: 2, fontWeight: FontWeight.w600)),
  );
}
