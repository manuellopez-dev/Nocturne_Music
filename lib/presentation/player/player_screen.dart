import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../data/innertube/providers/player_providers.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  const PlayerScreen({super.key});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  Color _dominantColor = AppColors.primary;
  Color _secondaryColor = AppColors.primaryDark;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _syncRotation(bool isPlaying) {
    if (isPlaying) {
      _rotationController.repeat();
    } else {
      _rotationController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    final player = ref.watch(playerProvider);
    _syncRotation(player.isPlaying);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _DynamicBackground(
            dominantColor: _dominantColor,
            secondaryColor: _secondaryColor,
          ),
          SafeArea(
            child: player.isLoading
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Cargando canción...',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      _PlayerTopBar(),
                      const SizedBox(height: 24),
                      _ArtworkSection(
                        thumbnailUrl: player.currentSong?.thumbnailUrl,
                        rotationController: _rotationController,
                        isPlaying: player.isPlaying,
                        dominantColor: _dominantColor,
                      ),
                      const SizedBox(height: 32),
                      _SongInfo(
                        title: player.currentSong?.title ?? 'Nocturne Music',
                        artist: player.currentSong?.artist ??
                            'Selecciona una canción',
                        isFavorite: player.isFavorite,
                        onFavorite: () => ref
                            .read(playerProvider.notifier)
                            .toggleFavorite(),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                      const SizedBox(height: 28),
                      _ProgressBar(
                        progress: player.progress,
                        currentSeconds: player.currentSeconds,
                        totalSeconds: player.totalSeconds,
                        onChanged: (v) =>
                            ref.read(playerProvider.notifier).seekTo(v),
                      ),
                      const SizedBox(height: 24),
                      _PlayerControls(
                        isPlaying: player.isPlaying,
                        isShuffled: player.isShuffled,
                        repeatMode: player.repeatMode,
                        dominantColor: _dominantColor,
                        onPlay: () =>
                            ref.read(playerProvider.notifier).togglePlay(),
                        onShuffle: () =>
                            ref.read(playerProvider.notifier).toggleShuffle(),
                        onRepeat: () =>
                            ref.read(playerProvider.notifier).toggleRepeat(),
                        onPrevious: () {},
                        onNext: () {},
                      ),
                      const SizedBox(height: 24),
                      _VolumeBar(
                        volume: player.volume,
                        onChanged: (v) =>
                            ref.read(playerProvider.notifier).setVolume(v),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _DynamicBackground extends StatelessWidget {
  final Color dominantColor;
  final Color secondaryColor;

  const _DynamicBackground({
    required this.dominantColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            dominantColor.withOpacity(0.6),
            secondaryColor.withOpacity(0.3),
            AppColors.background,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
    );
  }
}

class _PlayerTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          Column(
            children: [
              Text(
                'Reproduciendo ahora',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'YouTube Music',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.more_horiz_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtworkSection extends StatelessWidget {
  final String? thumbnailUrl;
  final AnimationController rotationController;
  final bool isPlaying;
  final Color dominantColor;

  const _ArtworkSection({
    required this.thumbnailUrl,
    required this.rotationController,
    required this.isPlaying,
    required this.dominantColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: isPlaying ? 280 : 250,
            height: isPlaying ? 280 : 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: dominantColor.withOpacity(isPlaying ? 0.5 : 0.2),
                  blurRadius: isPlaying ? 60 : 20,
                  spreadRadius: isPlaying ? 20 : 5,
                ),
              ],
            ),
          ),
          RotationTransition(
            turns: rotationController,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: isPlaying ? 260 : 240,
              height: isPlaying ? 260 : 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dominantColor,
                gradient: thumbnailUrl == null
                    ? RadialGradient(
                        colors: [
                          dominantColor.withOpacity(0.8),
                          dominantColor,
                          Colors.black,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      )
                    : null,
              ),
              child: ClipOval(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (thumbnailUrl != null)
                      CachedNetworkImage(
                        imageUrl: thumbnailUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        placeholder: (_, __) =>
                            Container(color: dominantColor),
                        errorWidget: (_, __, ___) => Container(
                          color: dominantColor,
                          child: const Icon(
                            Icons.music_note_rounded,
                            color: Colors.white24,
                            size: 64,
                          ),
                        ),
                      ),
                    if (thumbnailUrl != null)
                      Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.4),
                            ],
                            stops: const [0.5, 1.0],
                          ),
                        ),
                      ),
                    ...List.generate(3, (i) {
                      final size = 200.0 - (i * 40);
                      return Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                            width: 1,
                          ),
                        ),
                      );
                    }),
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.background.withOpacity(0.9),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.music_note_rounded,
                        color: dominantColor,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SongInfo extends StatelessWidget {
  final String title;
  final String artist;
  final bool isFavorite;
  final VoidCallback onFavorite;

  const _SongInfo({
    required this.title,
    required this.artist,
    required this.isFavorite,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  artist,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onFavorite,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey(isFavorite),
                color: isFavorite ? AppColors.accent : Colors.white54,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final int currentSeconds;
  final int totalSeconds;
  final ValueChanged<double> onChanged;

  const _ProgressBar({
    required this.progress,
    required this.currentSeconds,
    required this.totalSeconds,
    required this.onChanged,
  });

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.2),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withOpacity(0.15),
              trackHeight: 3,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: onChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(currentSeconds),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
                Text(
                  _formatTime(totalSeconds),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerControls extends StatelessWidget {
  final bool isPlaying;
  final bool isShuffled;
  final PlayerRepeatMode repeatMode;
  final Color dominantColor;
  final VoidCallback onPlay;
  final VoidCallback onShuffle;
  final VoidCallback onRepeat;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _PlayerControls({
    required this.isPlaying,
    required this.isShuffled,
    required this.repeatMode,
    required this.dominantColor,
    required this.onPlay,
    required this.onShuffle,
    required this.onRepeat,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _ControlIcon(
            icon: Icons.shuffle_rounded,
            active: isShuffled,
            onTap: onShuffle,
          ),
          GestureDetector(
            onTap: onPrevious,
            child: const Icon(
              Icons.skip_previous_rounded,
              color: Colors.white,
              size: 42,
            ),
          ),
          GestureDetector(
            onTap: onPlay,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  key: ValueKey(isPlaying),
                  color: dominantColor,
                  size: 40,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onNext,
            child: const Icon(
              Icons.skip_next_rounded,
              color: Colors.white,
              size: 42,
            ),
          ),
          _ControlIcon(
            icon: repeatMode == PlayerRepeatMode.one
                ? Icons.repeat_one_rounded
                : Icons.repeat_rounded,
            active: repeatMode != PlayerRepeatMode.none,
            onTap: onRepeat,
          ),
        ],
      ),
    );
  }
}

class _ControlIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _ControlIcon({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Icon(
            icon,
            color: active ? Colors.white : Colors.white38,
            size: 24,
          ),
          if (active)
            Positioned(
              bottom: -6,
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _VolumeBar extends StatelessWidget {
  final double volume;
  final ValueChanged<double> onChanged;

  const _VolumeBar({
    required this.volume,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Row(
        children: [
          const Icon(
            Icons.volume_down_rounded,
            color: Colors.white38,
            size: 20,
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: Colors.white60,
                inactiveTrackColor: Colors.white12,
                thumbColor: Colors.white,
                overlayColor: Colors.white12,
                trackHeight: 2,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 5),
              ),
              child: Slider(
                value: volume,
                onChanged: onChanged,
              ),
            ),
          ),
          const Icon(
            Icons.volume_up_rounded,
            color: Colors.white38,
            size: 20,
          ),
        ],
      ),
    );
  }
}