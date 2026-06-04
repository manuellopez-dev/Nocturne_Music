import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

final nocturnePlayer = NocturnePlayer();

class NocturnePlayer {
  final AudioPlayer _player = AudioPlayer();
  final YoutubeExplode _yt = YoutubeExplode();

  void setAuthToken(String accessToken) {}

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<ProcessingState> get processingStateStream =>
      _player.processingStateStream;

  bool get playing => _player.playing;
  Duration get position => _player.position;
  Duration? get duration => _player.duration;

  Future<void> playFromUrl(String url) async {
    await playVideoId(url);
  }

  Future<void> playVideoId(String videoId) async {
    try {
      print('[Player] Preparando: $videoId');
      await _player.stop();

      final manifest = await _yt.videos.streamsClient.getManifest(videoId);

      // Usa el stream de MENOR calidad — carga más rápido
      final audioStreams = manifest.audioOnly
          .where((s) => s.codec.mimeType.contains('mp4'))
          .toList()
        ..sort((a, b) => a.bitrate.compareTo(b.bitrate)); // menor primero

      final streamInfo = audioStreams.isNotEmpty
          ? audioStreams.first
          : manifest.audioOnly.sortByBitrate().first;

      final streamUrl = streamInfo.url.toString();
      print('[Player] URL: ${streamUrl.substring(0, 80)}...');
      print('[Player] Bitrate: ${streamInfo.bitrate} | Size: ${streamInfo.size.totalBytes}');

      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(streamUrl),
          headers: {
            'User-Agent': 'com.google.android.youtube/19.09.37 (Linux; U; Android 11) gzip',
            'Origin': 'https://www.youtube.com',
            'Referer': 'https://www.youtube.com/',
          },
        ),
      );
      await _player.play();
      print('[Player] Reproducción iniciada');
    } catch (e) {
      print('[Player] Error: $e');
      rethrow;
    }
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> stop() => _player.stop();
  Future<void> seek(Duration position) => _player.seek(position);

  void dispose() {
    _player.dispose();
    _yt.close();
  }
}