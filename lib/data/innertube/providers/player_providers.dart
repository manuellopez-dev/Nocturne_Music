import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nocturnemusic_app/data/innertube/providers/home_providers.dart';
import '../innertube_repository.dart';
import '../../../domain/models/song.dart';
import '../../../services/audio_handler.dart';
import 'innertube_providers.dart';

class PlayerState {
  final Song? currentSong;
  final bool isPlaying;
  final bool isLoading;
  final double progress;
  final int currentSeconds;
  final int totalSeconds;
  final double volume;
  final bool isFavorite;
  final PlayerRepeatMode repeatMode;
  final bool isShuffled;

  const PlayerState({
    this.currentSong,
    this.isPlaying = false,
    this.isLoading = false,
    this.progress = 0.0,
    this.currentSeconds = 0,
    this.totalSeconds = 0,
    this.volume = 0.8,
    this.isFavorite = false,
    this.repeatMode = PlayerRepeatMode.none,
    this.isShuffled = false,
  });

  bool get hasSong => currentSong != null;

  PlayerState copyWith({
    Song? currentSong,
    bool? isPlaying,
    bool? isLoading,
    double? progress,
    int? currentSeconds,
    int? totalSeconds,
    double? volume,
    bool? isFavorite,
    PlayerRepeatMode? repeatMode,
    bool? isShuffled,
  }) {
    return PlayerState(
      currentSong: currentSong ?? this.currentSong,
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      progress: progress ?? this.progress,
      currentSeconds: currentSeconds ?? this.currentSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      volume: volume ?? this.volume,
      isFavorite: isFavorite ?? this.isFavorite,
      repeatMode: repeatMode ?? this.repeatMode,
      isShuffled: isShuffled ?? this.isShuffled,
    );
  }
}

enum PlayerRepeatMode { none, all, one }

class PlayerNotifier extends StateNotifier<PlayerState> {
  final InnerTubeRepository _repository;
  final Ref _ref;

  PlayerNotifier(this._repository, this._ref) : super(const PlayerState()) { // <-- agrega _ref
    _listenToPlayer();
  }

  void _listenToPlayer() {
    nocturnePlayer.positionStream.listen((position) {
      final total = nocturnePlayer.duration?.inSeconds ?? 0;
      final current = position.inSeconds;
      final progress = total > 0 ? current / total : 0.0;
      if (mounted) {
        state = state.copyWith(
          currentSeconds: current,
          totalSeconds: total,
          progress: progress,
        );
      }
    });

    nocturnePlayer.playingStream.listen((playing) {
      if (mounted) {
        state = state.copyWith(isPlaying: playing);
      }
    });
  }

  Future<void> playSong(Song song) async {
  state = state.copyWith(
    currentSong: song,
    isLoading: true,
    isPlaying: false,
    progress: 0.0,
    currentSeconds: 0,
  );

  addToRecentlyPlayed(_ref, song);

  try {
    print('[Player] Reproduciendo: ${song.title} | id: ${song.id}');
    await nocturnePlayer.playVideoId(song.id);
    state = state.copyWith(
      isLoading: false,
      isPlaying: true,
      totalSeconds: song.duration,
    );
  } catch (e) {
    print('[Player] Error: $e');
    state = state.copyWith(isLoading: false);
  }
}

  Future<void> togglePlay() async {
    if (state.isPlaying) {
      await nocturnePlayer.pause();
    } else {
      await nocturnePlayer.play();
    }
  }

  Future<void> seekTo(double progress) async {
    final total = state.totalSeconds;
    if (total > 0) {
      final position = Duration(seconds: (progress * total).toInt());
      await nocturnePlayer.seek(position);
      state = state.copyWith(progress: progress);
    }
  }

  void toggleFavorite() =>
      state = state.copyWith(isFavorite: !state.isFavorite);

  void toggleShuffle() =>
      state = state.copyWith(isShuffled: !state.isShuffled);

  void toggleRepeat() {
    final next = switch (state.repeatMode) {
      PlayerRepeatMode.none => PlayerRepeatMode.all,
      PlayerRepeatMode.all  => PlayerRepeatMode.one,
      PlayerRepeatMode.one  => PlayerRepeatMode.none,
    };
    state = state.copyWith(repeatMode: next);
  }

  void setVolume(double volume) =>
      state = state.copyWith(volume: volume);
}

final playerProvider =
    StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  final repo = ref.watch(innerTubeRepositoryProvider);
  return PlayerNotifier(repo, ref); // <-- agrega ref
});