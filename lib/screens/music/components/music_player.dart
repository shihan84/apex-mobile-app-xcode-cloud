import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/utils/common_base.dart';

import '../models/music_model.dart';

class MusicPlayer extends StatefulWidget {
  final Music track;
  final List<Music>? playlist;
  final int? initialIndex;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onClose;

  const MusicPlayer({
    super.key,
    required this.track,
    this.playlist,
    this.initialIndex,
    this.onPrevious,
    this.onNext,
    this.onClose,
  });

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      _audioPlayer = AudioPlayer();
      
      _audioPlayer.playerStateStream.listen((state) {
        if (state.playing) {
          setState(() => _isPlaying = true);
        } else {
          setState(() => _isPlaying = false);
        }
      });

      _audioPlayer.positionStream.listen((position) {
        setState(() => _position = position);
      });

      _audioPlayer.durationStream.listen((duration) {
        setState(() => _duration = duration ?? Duration.zero);
      });

      await _audioPlayer.setUrl(widget.track.audioUrl);
    } catch (e) {
      log('Error initializing audio player: $e');
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } catch (e) {
      log('Error toggling play/pause: $e');
    }
  }

  Future<void> _seekToPosition(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      log('Error seeking: $e');
    }
  }

  Future<void> _setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
      setState(() => _volume = volume);
    } catch (e) {
      log('Error setting volume: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: appScreenBackgroundDark,
      child: SafeArea(
        child: Column(
          children: [
            // Top bar with close button
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: widget.onClose ?? () => Get.back(),
                    child: Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  ),
                  const Spacer(),
                  Text(
                    'Now Playing',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            
            // Album art and track info
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Album art
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: widget.track.thumbnailUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.track.thumbnailUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[400],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(Icons.album, color: Colors.white, size: 64),
                                  );
                                },
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.album, color: Colors.white, size: 64),
                            ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Track title and artist
                    Text(
                      widget.track.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.track.displayArtist,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.track.albumName != null)
                      Text(
                        widget.track.displayAlbum,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
            
            // Progress bar and controls
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Progress bar
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      thumbColor: appColorPrimary,
                      activeTrackColor: appColorPrimary,
                      inactiveTrackColor: Colors.grey[600],
                    ),
                    child: Slider(
                      min: 0.0,
                      max: _duration.inSeconds.toDouble(),
                      value: _position.inSeconds.toDouble(),
                      onChanged: (value) {
                        _seekToPosition(Duration(seconds: value.toInt()));
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Time display
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Control buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Previous button
                      GestureDetector(
                        onTap: widget.onPrevious ?? () {},
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.skip_previous, color: Colors.white, size: 24),
                        ),
                      ),
                      
                      // Play/Pause button
                      GestureDetector(
                        onTap: _togglePlayPause,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: appColorPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      
                      // Next button
                      GestureDetector(
                        onTap: widget.onNext ?? () {},
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.skip_next, color: Colors.white, size: 24),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
