import 'dart:math';
import 'package:audio_session/audio_session.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/network/core_api.dart';
import '../models/music_model.dart';

enum AudioRepeatMode { none, one, all }

class AudioPlayerService extends GetxService {
  static AudioPlayerService get to => Get.find<AudioPlayerService>();

  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;

  final Rx<Music?> currentTrack = Rx<Music?>(null);
  final RxList<Music> queue = <Music>[].obs;
  final RxInt currentIndex = 0.obs;
  final RxBool isPlaying = false.obs;
  final RxBool isLoading = false.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  final RxBool isShuffle = false.obs;
  final Rx<AudioRepeatMode> repeatMode = AudioRepeatMode.none.obs;
  List<Music> _originalQueue = [];

  @override
  Future<void> onInit() async {
    super.onInit();
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    session.interruptionEventStream.listen((event) {
      if (event.begin) _player.pause();
    });
    _player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      isLoading.value = state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;
      if (state.processingState == ProcessingState.completed) _onCompleted();
    });
    _player.positionStream.listen((p) => position.value = p);
    _player.durationStream.listen((d) => duration.value = d ?? Duration.zero);
  }

  void _onCompleted() {
    if (repeatMode.value == AudioRepeatMode.one) {
      _player.seek(Duration.zero); _player.play();
    } else if (repeatMode.value == AudioRepeatMode.all || currentIndex.value < queue.length - 1) {
      playNext();
    }
  }

  Future<void> playTrack(Music track, {List<Music>? trackQueue, int? index}) async {
    if (trackQueue != null) {
      _originalQueue = List.from(trackQueue);
      if (isShuffle.value) {
        final shuffled = List<Music>.from(trackQueue);
        shuffled.shuffle(Random());
        queue.assignAll(shuffled);
        currentIndex.value = shuffled.indexWhere((t) => t.id == track.id);
        if (currentIndex.value < 0) currentIndex.value = 0;
      } else {
        queue.assignAll(trackQueue);
        currentIndex.value = index ?? 0;
      }
    } else if (!queue.any((t) => t.id == track.id)) {
      _originalQueue.add(track);
      queue.add(track);
      currentIndex.value = queue.length - 1;
    } else {
      currentIndex.value = queue.indexWhere((t) => t.id == track.id);
    }
    currentTrack.value = track;
    isLoading.value = true;
    try {
      await _player.setUrl(track.audioUrl);
      await _player.play();
      CoreServiceApis.playMusic(track.id);
    } catch (e) {
      toast('Cannot play: ${track.title}');
      log('AudioPlayerService: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> playNext() async {
    if (queue.isEmpty) return;
    final next = (currentIndex.value + 1) % queue.length;
    currentIndex.value = next;
    await playTrack(queue[next]);
  }

  Future<void> playPrevious() async {
    if (queue.isEmpty) return;
    if (position.value.inSeconds > 3) { await _player.seek(Duration.zero); return; }
    final prev = (currentIndex.value - 1 + queue.length) % queue.length;
    currentIndex.value = prev;
    await playTrack(queue[prev]);
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      if (_player.processingState == ProcessingState.completed) await _player.seek(Duration.zero);
      await _player.play();
    }
  }

  Future<void> seekTo(Duration pos) => _player.seek(pos);
  void toggleShuffle() {
    isShuffle.value = !isShuffle.value;
    if (queue.isEmpty) return;
    final current = currentTrack.value;
    if (isShuffle.value) {
      final shuffled = List<Music>.from(_originalQueue.isNotEmpty ? _originalQueue : queue);
      shuffled.shuffle(Random());
      queue.assignAll(shuffled);
    } else {
      queue.assignAll(_originalQueue.isNotEmpty ? _originalQueue : queue);
    }
    if (current != null) {
      currentIndex.value = queue.indexWhere((t) => t.id == current.id);
      if (currentIndex.value < 0) currentIndex.value = 0;
    }
  }
  void toggleRepeat() {
    repeatMode.value = AudioRepeatMode.values[(repeatMode.value.index + 1) % AudioRepeatMode.values.length];
  }
  void addToQueue(Music track) {
    if (!queue.any((t) => t.id == track.id)) { queue.add(track); toast('Added to queue'); }
  }

  double get progressPercent => duration.value.inMilliseconds == 0
      ? 0 : position.value.inMilliseconds / duration.value.inMilliseconds;

  String _fmt(Duration d) =>
      '${d.inMinutes.remainder(60).toString().padLeft(2,'0')}:${d.inSeconds.remainder(60).toString().padLeft(2,'0')}';
  String get positionText => _fmt(position.value);
  String get durationText => _fmt(duration.value);

  Future<void> stop() async {
    await _player.stop();
    currentTrack.value = null;
    queue.clear();
    _originalQueue.clear();
    position.value = Duration.zero;
    duration.value = Duration.zero;
  }

  @override
  void onClose() { _player.dispose(); super.onClose(); }
}
