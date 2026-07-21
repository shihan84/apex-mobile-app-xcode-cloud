import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:apexprime_tv/utils/colors.dart';
import 'package:apexprime_tv/screens/dashboard/dashboard_controller.dart';
import 'music_controller.dart';
import 'components/music_feed.dart';
import 'components/playlist_card.dart';
import 'services/audio_player_service.dart';
import 'music_player_screen.dart';
import 'music_search_screen.dart';
import 'playlist_detail_screen.dart';
import 'artist_tracks_screen.dart';
import 'genre_browse_screen.dart';
import 'models/music_model.dart';

class MusicScreen extends StatefulWidget {
  MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  MusicController get musicController => Get.find<MusicController>();
  late final ScrollController _musicScrollCtrl;

  static const _recentKey = 'music_recently_played';
  List<Music> _recentlyPlayed = [];

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    musicController.getFeaturedMusic();
    musicController.getMusic();
    musicController.getPlaylists();
    _loadRecentlyPlayed();
    final dash = Get.find<DashboardController>();
    _musicScrollCtrl = dash.scrollFor('music');
  }

  Future<void> _loadRecentlyPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_recentKey) ?? [];
    final tracks = raw.map((s) {
      try { return Music.fromJson(jsonDecode(s) as Map<String, dynamic>); }
      catch (_) { return null; }
    }).whereType<Music>().toList();
    if (mounted) setState(() => _recentlyPlayed = tracks);
  }

  Future<void> _addToRecentlyPlayed(Music track) async {
    final updated = [track, ..._recentlyPlayed.where((t) => t.id != track.id)].take(10).toList();
    setState(() => _recentlyPlayed = updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentKey, updated.map((t) => jsonEncode(t.toJson())).toList());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appScreenBackgroundDark,
      body: SafeArea(child: Column(
        children: [
          // Header: greeting + actions
          Container(
            color: appScreenBackgroundDark,
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'What do you want to listen to?',
                        style: TextStyle(color: Color(0x80FFFFFF), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.category_rounded, color: Colors.white),
                  onPressed: () => Get.to(() => const GenreBrowseScreen()),
                ),
                IconButton(
                  icon: const Icon(Icons.search_rounded, color: Colors.white),
                  onPressed: () => Get.to(() => const MusicSearchScreen()),
                ),
              ],
            ),
          ),
          // Recently played row
          if (_recentlyPlayed.isNotEmpty) _buildRecentlyPlayedRow(),
          // Artists row
          Obx(() {
            if (musicController.music.isEmpty) return const SizedBox.shrink();
            final seen = <String>{};
            final artists = <Map<String, String>>[];
            for (final t in musicController.music) {
              final a = t.artistName ?? '';
              if (a.isNotEmpty && seen.add(a)) {
                artists.add({'name': a, 'img': t.thumbnailUrl ?? ''});
              }
            }
            if (artists.isEmpty) return const SizedBox.shrink();
            return _buildArtistRow(artists);
          }),
          // Tab bar
          Container(
            color: appScreenBackgroundDark,
            child: TabBar(
              controller: _tabController,
              indicatorColor: appColorPrimary,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'All Music'),
                Tab(text: 'Playlists'),
                Tab(text: 'Featured'),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // All Music Tab
                Obx(() => musicController.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : musicController.music.isEmpty
                        ? Center(
                            child: Text(
                              'No music available',
                              style: primaryTextStyle(size: 16),
                            ),
                          )
                        : MusicFeed(
                            music: musicController.music,
                            scrollController: _musicScrollCtrl,
                            onTrackTap: (track) {
                              _addToRecentlyPlayed(track);
                              musicController.playMusic(track.id);
                              AudioPlayerService.to.playTrack(track,
                                trackQueue: musicController.music.toList(),
                                index: musicController.music.indexOf(track));
                            },
                            onLike: (track) {
                              musicController.likeMusic(track.id);
                            },
                          )),
                
                // Playlists Tab
                Obx(() => musicController.playlists.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.playlist_play, color: Colors.grey, size: 64),
                            const SizedBox(height: 16),
                            Text(
                              'No playlists yet',
                              style: primaryTextStyle(size: 16),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                // TODO: Create playlist
                                toast('Create playlist feature coming soon!');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: appColorPrimary,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Create Playlist'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: musicController.playlists.length,
                        itemBuilder: (context, index) {
                          final playlist = musicController.playlists[index];
                          return PlaylistCard(
                            playlist: playlist,
                            onTap: () => Get.to(() => PlaylistDetailScreen(
                              playlistId: playlist.id,
                              playlistName: playlist.name,
                              coverUrl: playlist.thumbnailUrl,
                            )),
                          );
                        },
                      )),
                
                // Featured Tab
                Obx(() => musicController.featuredMusic.isEmpty
                    ? Center(
                        child: Text(
                          'No featured music',
                          style: primaryTextStyle(size: 16),
                        ),
                      )
                    : MusicFeed(
                        music: musicController.featuredMusic,
                        onTrackTap: (track) {
                          _addToRecentlyPlayed(track);
                          musicController.playMusic(track.id);
                          AudioPlayerService.to.playTrack(track,
                            trackQueue: musicController.featuredMusic.toList(),
                            index: musicController.featuredMusic.indexOf(track));
                        },
                        onLike: (track) {
                          musicController.likeMusic(track.id);
                        },
                      )),
              ],
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildRecentlyPlayedRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Recently Played',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onLongPress: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove(_recentKey);
                  setState(() => _recentlyPlayed = []);
                },
                child: const Text('Clear', style: TextStyle(color: Color(0x806C63FF), fontSize: 12)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 96,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: _recentlyPlayed.length,
            itemBuilder: (context, i) {
              final track = _recentlyPlayed[i];
              return GestureDetector(
                onTap: () {
                  AudioPlayerService.to.playTrack(track);
                  Get.to(() => MusicPlayerScreen(track: track), transition: Transition.downToUp);
                },
                child: Container(
                  width: 72,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: (track.thumbnailUrl?.isNotEmpty == true)
                            ? CachedNetworkImage(
                                imageUrl: track.thumbnailUrl!,
                                width: 60, height: 60, fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => _recentArtPlaceholder(),
                              )
                            : _recentArtPlaceholder(),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        track.title,
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _recentArtPlaceholder() => Container(
    width: 60, height: 60,
    decoration: BoxDecoration(
      color: const Color(0x4D6C63FF),
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Icon(Icons.music_note_rounded, color: Color(0xFF6C63FF), size: 28),
  );

  Widget _buildArtistRow(List<Map<String, String>> artists) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            'Artists',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: artists.length,
            itemBuilder: (context, i) {
              final artist = artists[i];
              final name = artist['name']!;
              final img = artist['img']!;
              return GestureDetector(
                onTap: () => Get.to(
                  () => ArtistTracksScreen(artistName: name),
                  transition: Transition.rightToLeft,
                ),
                child: Container(
                  width: 72,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    children: [
                      Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0x556C63FF), width: 2),
                        ),
                        child: ClipOval(
                          child: img.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: img,
                                  width: 64, height: 64, fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => _artistPlaceholder(),
                                )
                              : _artistPlaceholder(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        name,
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _artistPlaceholder() => Container(
    width: 64, height: 64,
    color: const Color(0x4D6C63FF),
    child: const Icon(Icons.person_rounded, color: Color(0xFF6C63FF), size: 32),
  );
}
