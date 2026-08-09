import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:apexprime_tv/ads/custom_ads/ad_player.dart';
import 'package:apexprime_tv/components/cached_image_widget.dart';
import 'package:apexprime_tv/main.dart';
import 'package:apexprime_tv/screens/auth/model/app_configuration_res.dart';
import 'package:apexprime_tv/utils/colors.dart';
import 'package:apexprime_tv/utils/common_functions.dart';

/// Full-screen app-open custom ad shown before the home/walkthrough screen.
/// Supports image or video ads with optional skip-after timer.
class AppOpenAdScreen extends StatefulWidget {
  final AppOpenAd ad;
  final Future<void> Function() onCompleted;

  const AppOpenAdScreen({
    super.key,
    required this.ad,
    required this.onCompleted,
  });

  @override
  State<AppOpenAdScreen> createState() => _AppOpenAdScreenState();
}

class _AppOpenAdScreenState extends State<AppOpenAdScreen> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _canSkip = false;
  bool _isVideoStarted = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.ad.duration > 0 ? widget.ad.duration : 5;
    _canSkip = widget.ad.skipEnabled == false;

    if (widget.ad.skipEnabled && widget.ad.skipAfter > 0) {
      _startSkipTimer();
    }
    _startCompletionTimer();
  }

  void _startSkipTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _canSkip = timer.tick >= widget.ad.skipAfter;
        });
        if (_canSkip) timer.cancel();
      }
    });
  }

  void _startCompletionTimer() {
    if (widget.ad.type == 'video' || widget.ad.url.isVideo) {
      // For video ads, wait until the video finishes or reaches its duration.
      // A safety fallback timer is started once the video begins.
      return;
    }

    _timer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _remainingSeconds--);
        if (_remainingSeconds <= 0) {
          timer.cancel();
          _finish();
        }
      }
    });
  }

  void _finish() async {
    _timer?.cancel();
    await widget.onCompleted();
  }

  void _onTap() {
    if (widget.ad.redirectUrl.isNotEmpty) {
      launchUrlCustomURL(widget.ad.redirectUrl);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onTap: _onTap,
            child: _buildAdContent(),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: _buildSkipButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdContent() {
    if (widget.ad.type == 'image' || widget.ad.url.isImage) {
      return CachedImageWidget(
        url: widget.ad.url,
        width: Get.width,
        height: Get.height,
        fit: BoxFit.contain,
      );
    }

    return AdPlayer(
      videoUrl: widget.ad.url,
      adType: widget.ad.type,
      redirectUrl: widget.ad.redirectUrl,
      height: Get.height,
      width: Get.width,
      isFromPlayerAd: true,
      onVideoStarted: () {
        if (mounted) setState(() => _isVideoStarted = true);
      },
      onVideoCompleted: _finish,
      onVideoError: _finish,
      startSkipTimer: (value) {
        if (value.value && mounted) {
          setState(() => _isVideoStarted = true);
        }
      },
    );
  }

  Widget _buildSkipButton() {
    if (_canSkip) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black54,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: _finish,
        child: Text(locale.value.skip ?? 'Skip', style: boldTextStyle(color: white)),
      );
    }

    if (widget.ad.skipEnabled && widget.ad.skipAfter > 0) {
      final remaining = widget.ad.skipAfter - (_timer?.tick ?? 0).clamp(0, widget.ad.skipAfter);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: boxDecorationWithRoundedCorners(
          backgroundColor: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${locale.value.skipAd ?? 'Skip ad'} ${remaining}s',
          style: boldTextStyle(color: white),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
