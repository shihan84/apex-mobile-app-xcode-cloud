import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/components/app_scaffold.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'music_controller.dart';
import 'components/music_player.dart';
import 'components/music_feed.dart';
import 'components/playlist_card.dart';

class MusicScreen extends StatefulWidget {
  MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  MusicController get musicController => Get.find<MusicController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    musicController.getMusic();
    musicController.getPlaylists();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        children: [
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
                    ? Center(child: CircularProgressIndicator())
                    : musicController.music.isEmpty
                        ? Center(
                            child: Text(
                              'No music available',
                              style: primaryTextStyle(size: 16),
                            ),
                          )
                        : MusicFeed(
                            music: musicController.music,
                            onTrackTap: (track) {
                              musicController.playMusic(track.id);
                              Get.to(() => MusicPlayer(
                                track: track,
                                playlist: musicController.music.toList(),
                                initialIndex: musicController.music.indexOf(track),
                              ));
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
                            onTap: () {
                              if (playlist.tracks != null && playlist.tracks!.isNotEmpty) {
                                musicController.playMusic(playlist.tracks!.first.id);
                                Get.to(() => MusicPlayer(
                                  track: playlist.tracks!.first,
                                  playlist: playlist.tracks!,
                                  initialIndex: 0,
                                ));
                              } else {
                                toast('No tracks in this playlist');
                              }
                            },
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
                          musicController.playMusic(track.id);
                          Get.to(() => MusicPlayer(
                            track: track,
                            playlist: musicController.featuredMusic.toList(),
                            initialIndex: musicController.featuredMusic.indexOf(track),
                          ));
                        },
                        onLike: (track) {
                          musicController.likeMusic(track.id);
                        },
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
