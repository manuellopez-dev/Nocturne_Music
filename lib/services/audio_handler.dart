import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

final nocturnePlayer = NocturnePlayer();

class _AuthHttpClient extends YoutubeHttpClient {
  String? _accessToken;

  void setToken(String token) {
    _accessToken = token;
  }

  @override
  Map<String, String> get headers => {
        ...YoutubeHttpClient.defaultHeaders,
        if (_accessToken != null) ...{
          'Authorization': 'Bearer $_accessToken',
          'X-Goog-AuthUser': '0',
        },
        'cookie': 'CONSENT=YES+cb',
      };
}

class NocturnePlayer {
  final AudioPlayer _player = AudioPlayer();
  final _authClient = _AuthHttpClient();
  late final YoutubeExplode _yt;

  final Map<String, StreamInfo> _manifestCache = {};

  NocturnePlayer() {
    _yt = YoutubeExplode(_authClient);
  }

  void setAuthToken(String accessToken) {
    _authClient.setToken(accessToken);
    print('[Player] Token configurado');
  }

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

      StreamInfo streamInfo;

      if (_manifestCache.containsKey(videoId)) {
        streamInfo = _manifestCache[videoId]!;
        print('[Player] Usando manifest cacheado');
      } else {
        final manifest = await _yt.videos.streamsClient.getManifest(videoId);
        final audioStreams = manifest.audioOnly
            .where((s) => s.codec.mimeType.contains('mp4'))
            .toList()
          ..sort((a, b) => a.bitrate.compareTo(b.bitrate));

        streamInfo = audioStreams.isNotEmpty
            ? audioStreams.first
            : manifest.audioOnly.sortByBitrate().first;

        _manifestCache[videoId] = streamInfo;
        print('[Player] Manifest cacheado para: $videoId');
      }

      print('[Player] Bitrate: ${streamInfo.bitrate} | Size: ${streamInfo.size.totalBytes}');

      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(streamInfo.url.toString()),
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