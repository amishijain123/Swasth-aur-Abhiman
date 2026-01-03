import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final String videoUrl;
  final String title;
  final String? description;
  final String? thumbnailUrl;

  const VideoPlayerScreen({
    Key? key,
    required this.videoUrl,
    required this.title,
    this.description,
    this.thumbnailUrl,
  }) : super(key: key);

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  Duration? _duration;
  Duration? _position;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    // Initialize video player with the provided URL
    // Supports both regular MP4/WebM and HLS (.m3u8) streams
    _controller = VideoPlayerController.network(
      widget.videoUrl,
      httpHeaders: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
      },
    )..initialize().then((_) {
      setState(() {
        _isInitialized = true;
      });
    }).catchError((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading video: $error')),
        );
      }
    });

    // Listen for video position changes
    _controller.addListener(_onVideoPositionChanged);
  }

  void _onVideoPositionChanged() {
    if (_controller.value.isInitialized) {
      setState(() {
        _position = _controller.value.position;
        _duration = _controller.value.duration;
      });

      // Hide controls after 5 seconds of inactivity
      if (_showControls) {
        Future.delayed(const Duration(seconds: 5), () {
          if (_controller.value.isPlaying && mounted) {
            setState(() {
              _showControls = false;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _controller.pause();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video Player
              Container(
                color: Colors.black,
                child: _isInitialized
                    ? GestureDetector(
                        onTap: () {
                          setState(() {
                            _showControls = !_showControls;
                          });
                        },
                        child: AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: Stack(
                            children: [
                              VideoPlayer(_controller),
                              if (_showControls)
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black26,
                                    child: Stack(
                                      children: [
                                        // Play/Pause Button (Center)
                                        Center(
                                          child: CircleAvatar(
                                            radius: 40,
                                            backgroundColor: Colors.white24,
                                            child: Icon(
                                              _controller.value.isPlaying
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                          ),
                                        ),
                                        // Bottom Control Bar
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            color: Colors.black54,
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Progress Slider
                                                Slider(
                                                  value: _position?.inSeconds.toDouble() ?? 0,
                                                  max: _duration?.inSeconds.toDouble() ?? 100,
                                                  onChanged: (value) {
                                                    _controller.seekTo(
                                                      Duration(seconds: value.toInt()),
                                                    );
                                                  },
                                                  activeColor: Colors.red,
                                                  inactiveColor: Colors.white30,
                                                ),
                                                // Time Display and Controls
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        _formatDuration(_position),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        _formatDuration(_duration),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        alignment: Alignment.center,
                        color: Colors.black,
                        height: 200,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Loading video...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 16),

              // Video Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (widget.description != null)
                      Text(
                        widget.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    const SizedBox(height: 16),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.favorite_border),
                            label: const Text('Like'),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Video liked!')),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Share functionality'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '0:00';
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

// Provider for video playback state
class VideoPlaybackState {
  final bool isPlaying;
  final Duration currentPosition;
  final Duration totalDuration;
  final bool isBuffering;
  final String? error;

  VideoPlaybackState({
    this.isPlaying = false,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.isBuffering = false,
    this.error,
  });

  VideoPlaybackState copyWith({
    bool? isPlaying,
    Duration? currentPosition,
    Duration? totalDuration,
    bool? isBuffering,
    String? error,
  }) {
    return VideoPlaybackState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      isBuffering: isBuffering ?? this.isBuffering,
      error: error ?? this.error,
    );
  }
}

final videoPlaybackProvider =
    StateNotifierProvider<VideoPlaybackNotifier, VideoPlaybackState>(
  (ref) => VideoPlaybackNotifier(),
);

class VideoPlaybackNotifier extends StateNotifier<VideoPlaybackState> {
  VideoPlaybackNotifier() : super(VideoPlaybackState());

  void updatePlaybackState({
    bool? isPlaying,
    Duration? currentPosition,
    Duration? totalDuration,
    bool? isBuffering,
    String? error,
  }) {
    state = state.copyWith(
      isPlaying: isPlaying,
      currentPosition: currentPosition,
      totalDuration: totalDuration,
      isBuffering: isBuffering,
      error: error,
    );
  }

  void reset() {
    state = VideoPlaybackState();
  }
}

// HLS Stream Support Documentation
// 
// To use HLS streams, ensure the video_player package supports HLS:
// 
// Android Setup:
// - HLS is supported natively on Android 4.0+
// - No additional configuration needed
//
// iOS Setup:
// - Add to ios/Podfile:
//   target 'Runner' do
//     pod 'video_player', :path => '.symlinks/plugins/video_player/ios'
//   end
//
// Web Setup:
// - Use video_player_web package
// - Note: HLS support may vary by browser (use hls.js for better compatibility)
//
// Example HLS Stream URL:
// https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8
//
// To stream from your own server:
// 1. Encode video to multiple bitrates using ffmpeg:
//    ffmpeg -i input.mp4 -c:v libx264 -c:a aac -hls_time 10 -hls_list_size 0 output.m3u8
//
// 2. Configure web server to serve .m3u8 and .ts files:
//    AddType application/vnd.apple.mpegurl .m3u8
//    AddType video/mp2t .ts
//
// 3. Access via URL: https://yourdomain.com/videos/output.m3u8
