import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:streamit_laravel/utils/colors.dart';
import 'package:streamit_laravel/utils/common_base.dart';

import '../models/short_model.dart';

class ShortVideoPlayer extends StatefulWidget {
  final Short short;
  final VoidCallback? onVideoEnd;

  const ShortVideoPlayer({
    super.key,
    required this.short,
    this.onVideoEnd,
  });

  @override
  State<ShortVideoPlayer> createState() => _ShortVideoPlayerState();
}

class _ShortVideoPlayerState extends State<ShortVideoPlayer> {
  VideoPlayerController? _videoController;
  bool _isPlaying = false;
  bool _isMuted = true;
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.short.videoUrl));
      await _videoController!.initialize();
      
      _videoController!.addListener(() {
        if (_videoController!.value.position >= _videoController!.value.duration) {
          widget.onVideoEnd?.call();
        }
      });

      setState(() {});
    } catch (e) {
      log('Error initializing video: $e');
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _videoController?.pause();
    } else {
      _videoController?.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _toggleMute() {
    if (_videoController!.value.volume == 0) {
      _videoController!.setVolume(1.0);
    } else {
      _videoController!.setVolume(0.0);
    }
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: _toggleControls,
      onDoubleTap: () {
        // TODO: Implement like functionality
        toast('Double tapped - like feature coming soon!');
      },
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Video player
            Center(
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            ),
            
            // Top overlay with short info
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.short.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.visibility, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        widget.short.formattedViewCount,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.more_vert, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
            
            // Bottom controls overlay
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Play/Pause button
                      GestureDetector(
                        onTap: _togglePlayPause,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      
                      // Mute button
                      GestureDetector(
                        onTap: _toggleMute,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isMuted ? Icons.volume_off : Icons.volume_up,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      
                      // Share button
                      GestureDetector(
                        onTap: () {
                          // TODO: Implement share functionality
                          toast('Share feature coming soon!');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.share,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
