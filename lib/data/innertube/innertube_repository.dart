import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../../domain/models/song.dart';
import '../../domain/models/search_result.dart';

class InnerTubeRepository {
  final YoutubeExplode _yt = YoutubeExplode();

  void setAccessToken(String token) {
    // ya no se usa, se mantiene por compatibilidad con el provider
  }

  Future<MusicSearchResult> search(String query) async {
    try {
      print('[Repository] Buscando: $query');
      final results = await _yt.search.search(query);
      
      final songs = results.map((video) => Song(
        id: video.id.value,
        title: video.title,
        artist: video.author,
        album: '',
        thumbnailUrl: video.thumbnails.highResUrl,
        duration: video.duration?.inSeconds ?? 0,
      )).toList();

      print('[Repository] Resultados: ${songs.length}');
      return MusicSearchResult(songs: songs, artists: [], albums: []);
    } catch (e) {
      print('[Repository] Error en búsqueda: $e');
      rethrow;
    }
  }

  Future<String?> getStreamUrl(String videoId) async {
  try {
    print('[Repository] Obteniendo stream para: $videoId');
    final manifest = await _yt.videos.streamsClient.getManifest(videoId);
    
    // Filtra solo audio y ordena por bitrate de mayor a menor
    final audioStreams = manifest.audioOnly
        .where((s) => s.codec.mimeType.contains('mp4'))
        .toList()
      ..sort((a, b) => b.bitrate.compareTo(a.bitrate));

    if (audioStreams.isEmpty) {
      // fallback a cualquier audio
      final fallback = manifest.audioOnly.sortByBitrate();
      if (fallback.isEmpty) return null;
      return fallback.last.url.toString();
    }

    final best = audioStreams.first;
    print('[Repository] Stream OK: ${best.bitrate} | ${best.codec.mimeType}');
    return best.url.toString();
  } catch (e) {
    print('[Repository] Error stream: $e');
    return null;
  }
}

  Future<List<Song>> getRelatedSongs(String videoId) async => [];

  void dispose() => _yt.close();
}