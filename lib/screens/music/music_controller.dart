import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/network/core_api.dart';
import 'package:streamit_laravel/utils/common_base.dart';
import 'package:streamit_laravel/utils/colors.dart';

import 'models/music_model.dart';
import 'models/playlist_model.dart';

class MusicController extends GetxController {
  RxList<Music> music = <Music>[].obs;
  RxList<Playlist> playlists = <Playlist>[].obs;
  RxList<Music> featuredMusic = <Music>[].obs;
  RxBool isLoading = false.obs;
  RxInt currentPage = 1.obs;
  RxBool hasMore = true.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getMusic();
    getPlaylists();
    getFeaturedMusic();
  }

  Future<void> getMusic({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      music.clear();
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await CoreServiceApis.getMusic(
        page: currentPage.value,
        limit: 20,
      );

      if (response.status) {
        final rawData = response.data is Map ? (response.data['data'] ?? []) : (response.data ?? []);
        final List items = rawData is List ? rawData : [];
        if (refresh) {
          music.assignAll(items.map((item) => Music.fromJson(item)).toList());
          playlists.clear();
        } else {
          music.addAll(items.map((item) => Music.fromJson(item)).toList());
        }
        
        hasMore.value = items.length >= 20;
        if (hasMore.value) {
          currentPage.value++;
        }
      } else {
        errorMessage.value = response.message ?? 'Failed to load music';
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong. Please try again.';
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getPlaylists() async {
    try {
      final response = await CoreServiceApis.getPlaylists();

      if (response.status) {
        final rawData = response.data is Map ? (response.data['data'] ?? []) : (response.data ?? []);
        final List items = rawData is List ? rawData : [];
        playlists.assignAll(items.map((item) => Playlist.fromJson(item)).toList());
      } else {
        errorMessage.value = response.message ?? 'Failed to load playlists';
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong. Please try again.';
      log(e.toString());
    }
  }

  Future<void> getFeaturedMusic() async {
    try {
      final response = await CoreServiceApis.getFeaturedMusic();

      if (response.status) {
        final rawData = response.data is List ? response.data : (response.data is Map ? (response.data['data'] ?? []) : []);
        featuredMusic.assignAll((rawData as List).map((item) => Music.fromJson(item)).toList());
      } else {
        errorMessage.value = response.message ?? 'Failed to load featured music';
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong. Please try again.';
      log(e.toString());
    }
  }

  Future<void> getTrendingMusic() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await CoreServiceApis.getTrendingMusic();

      if (response.status) {
        final rawData = response.data is Map ? (response.data['data'] ?? []) : (response.data ?? []);
        music.assignAll((rawData as List).map((item) => Music.fromJson(item)).toList());
      } else {
        errorMessage.value = response.message ?? 'Failed to load trending music';
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong. Please try again.';
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchMusic(String query) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await CoreServiceApis.searchMusic(
        query,
        page: 1,
        limit: 20,
      );

      if (response.status) {
        final rawData = response.data is Map ? (response.data['tracks'] ?? response.data['data'] ?? []) : (response.data ?? []);
        music.assignAll((rawData as List).map((item) => Music.fromJson(item)).toList());
      } else {
        errorMessage.value = response.message ?? 'Failed to search music';
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong. Please try again.';
      log(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> likeMusic(int musicId) async {
    try {
      final response = await CoreServiceApis.likeMusic(musicId);
      
      if (response.status) {
        final index = music.indexWhere((Music track) => track.id == musicId);
        if (index != -1) {
          music[index] = music[index].copyWith(
            likeCount: response.data['like_count'],
            isLiked: response.data['liked'],
          );
        }
        
        // Also update in featured if present
        final featuredIndex = featuredMusic.indexWhere((Music track) => track.id == musicId);
        if (featuredIndex != -1) {
          featuredMusic[featuredIndex] = featuredMusic[featuredIndex].copyWith(
            likeCount: response.data['like_count'],
            isLiked: response.data['liked'],
          );
        }
        
        toast(response.data['liked'] ? 'Music liked!' : 'Music unliked!');
      }
    } catch (e) {
      toast('Failed to like music');
      log(e.toString());
    }
  }

  Future<void> playMusic(int musicId) async {
    try {
      final response = await CoreServiceApis.playMusic(musicId);
      
      if (response.status) {
        final index = music.indexWhere((Music track) => track.id == musicId);
        if (index != -1) {
          music[index] = music[index].copyWith(
            playCount: response.data['play_count'],
          );
        }
        
        // TODO: Navigate to player screen
        log('Playing music: ${music[index].title}');
      }
    } catch (e) {
      toast('Failed to play music');
      log(e.toString());
    }
  }

  Future<void> refreshMusic() async {
    await getMusic(refresh: true);
  }

  void loadMoreMusic() {
    if (hasMore.value && !isLoading.value) {
      getMusic();
    }
  }
}
