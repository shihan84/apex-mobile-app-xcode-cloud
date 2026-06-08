import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:streamit_laravel/network/core_api.dart';
import 'package:streamit_laravel/screens/music/models/music_model.dart';
import 'package:streamit_laravel/screens/music/music_player_screen.dart';
import 'package:streamit_laravel/screens/music/services/audio_player_service.dart';

class GenreBrowseScreen extends StatefulWidget {
  const GenreBrowseScreen({super.key});
  @override
  State<GenreBrowseScreen> createState() => _GenreBrowseScreenState();
}

class _GenreBrowseScreenState extends State<GenreBrowseScreen> {
  List<Map<String, dynamic>> _categories = [];
  bool _loading = true;
  String? _selected;
  List<Music> _tracks = [];
  bool _tracksLoading = false;

  static const List<Color> _palette = [
    Color(0xFF6C63FF), Color(0xFFE91E8C), Color(0xFF00BCD4),
    Color(0xFF4CAF50), Color(0xFFFF5722), Color(0xFF9C27B0),
    Color(0xFF2196F3), Color(0xFFFF9800),
  ];

  static const List<String> _fallbackGenres = ['Pop', 'Rock', 'Hip Hop', 'R&B', 'Jazz', 'Classical', 'Electronic', 'Country'];

  @override
  void initState() { super.initState(); _loadCategories(); }

  Future<void> _loadCategories() async {
    try {
      final res = await CoreServiceApis.getMusicCategories();
      final list = res.data is List ? res.data as List : [];
      setState(() { _categories = list.cast<Map<String, dynamic>>(); });
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _selectGenre(String genre) async {
    setState(() { _selected = genre; _tracksLoading = true; });
    try {
      final res = await CoreServiceApis.getTracksByGenre(genre);
      final data = res.data;
      final list = data is List ? data : (data is Map ? (data['data'] as List? ?? []) : <dynamic>[]);
      setState(() {
        _tracks = list.map((t) => Music.fromJson(t as Map<String, dynamic>)).toList();
      });
    } catch (_) { setState(() => _tracks = []); }
    setState(() => _tracksLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final genres = _categories.isNotEmpty
        ? _categories.map((c) => c['name'] as String? ?? '').where((n) => n.isNotEmpty).toList()
        : _fallbackGenres;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A), elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white), onPressed: () => Get.back()),
        title: const Text('Browse by Genre', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : Column(children: [
              SizedBox(
                height: 56,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: genres.length,
                  itemBuilder: (ctx, i) {
                    final g = genres[i];
                    final sel = _selected == g;
                    return GestureDetector(
                      onTap: () => _selectGenre(g),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? _palette[i % _palette.length] : const Color(0xFF1E1E2E),
                          borderRadius: BorderRadius.circular(24),
                          border: sel ? null : Border.all(color: Colors.white12),
                        ),
                        child: Text(g, style: TextStyle(color: sel ? Colors.white : Colors.white70, fontWeight: FontWeight.w600, fontSize: 13)),
                      ),
                    );
                  },
                ),
              ),
              Expanded(child: _selected == null
                  ? _buildGrid(genres)
                  : _tracksLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
                      : _tracks.isEmpty
                          ? Center(child: Text('No tracks for "$_selected"', style: const TextStyle(color: Colors.white54)))
                          : _buildTrackList()),
            ]),
    );
  }

  Widget _buildGrid(List<String> genres) => GridView.builder(
    padding: const EdgeInsets.all(16),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.6, crossAxisSpacing: 12, mainAxisSpacing: 12),
    itemCount: genres.length,
    itemBuilder: (ctx, i) => GestureDetector(
      onTap: () => _selectGenre(genres[i]),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_palette[i % _palette.length], _palette[i % _palette.length].withAlpha(150)]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Text(genres[i], style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold))),
      ),
    ),
  );

  Widget _buildTrackList() => ListView.builder(
    padding: const EdgeInsets.only(bottom: 100),
    itemCount: _tracks.length,
    itemBuilder: (ctx, i) {
      final t = _tracks[i];
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: ClipRRect(borderRadius: BorderRadius.circular(6),
          child: (t.thumbnailUrl?.isNotEmpty == true)
              ? CachedNetworkImage(imageUrl: t.thumbnailUrl!, width: 48, height: 48, fit: BoxFit.cover)
              : Container(width: 48, height: 48, color: const Color(0xFF2A2A3E), child: const Icon(Icons.music_note_rounded, color: Color(0xFF6C63FF)))),
        title: Text(t.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(t.displayArtist, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: Text(t.formattedDuration, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        onTap: () {
          AudioPlayerService.to.playTrack(t, trackQueue: _tracks, index: i);
          Get.to(() => MusicPlayerScreen(track: t), transition: Transition.downToUp);
        },
      );
    },
  );
}
