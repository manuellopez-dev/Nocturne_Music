import '../../domain/models/song.dart';
import '../../domain/models/search_result.dart';

class InnerTubeParser {
  static MusicSearchResult parseSearch(Map<String, dynamic> json) {
    final songs = <Song>[];
    final artists = <MusicArtistResult>[];
    final albums = <MusicAlbumResult>[];

    try {
      final tabs = json['contents']
          ?['tabbedSearchResultsRenderer']
          ?['tabs'] as List?;

      if (tabs == null || tabs.isEmpty) return _emptyResult();

      final sections = tabs[0]['tabRenderer']
          ?['content']
          ?['sectionListRenderer']
          ?['contents'] as List?;

      if (sections == null) return _emptyResult();

      for (final section in sections) {
        final shelf = section['musicShelfRenderer'];
        if (shelf == null) continue;

        final items = shelf['contents'] as List?;
        if (items == null) continue;

        for (final item in items) {
          final renderer = item['musicResponsiveListItemRenderer'];
          if (renderer == null) continue;

          final song = _parseSongFromRenderer(renderer);
          if (song != null) songs.add(song);
        }
      }
    } catch (e) {
      print('[Parser] Error: $e');
    }

    return MusicSearchResult(
      songs: songs,
      artists: artists,
      albums: albums,
    );
  }

  static String? parseStreamUrl(Map<String, dynamic> json) {
    try {
      final adaptiveFormats = json['streamingData']
          ?['adaptiveFormats'] as List?;

      if (adaptiveFormats != null && adaptiveFormats.isNotEmpty) {
        final audioFormats = adaptiveFormats
            .where((f) =>
                (f['mimeType'] as String?)?.contains('audio/mp4') == true ||
                (f['mimeType'] as String?)?.contains('audio/webm') == true)
            .toList();

        if (audioFormats.isNotEmpty) {
          audioFormats.sort((a, b) =>
              (b['bitrate'] as int? ?? 0)
                  .compareTo(a['bitrate'] as int? ?? 0));
          final url = audioFormats.first['url'] as String?;
          if (url != null) return url;
        }
      }

      final formats = json['streamingData']?['formats'] as List?;
      if (formats != null && formats.isNotEmpty) {
        return formats.first['url'] as String?;
      }

      return null;
    } catch (e) {
      print('[Parser] Error parseando stream URL: $e');
      return null;
    }
  }

  static Song? _parseSongFromRenderer(Map<String, dynamic> renderer) {
    try {
      final videoId = renderer['overlay']
          ?['musicItemThumbnailOverlayRenderer']
          ?['content']
          ?['musicPlayButtonRenderer']
          ?['playNavigationEndpoint']
          ?['watchEndpoint']
          ?['videoId'] as String?;

      if (videoId == null) return null;

      final columns = renderer['flexColumns'] as List?;
      if (columns == null || columns.isEmpty) return null;

      final title = columns[0]
              ['musicResponsiveListItemFlexColumnRenderer']
          ?['text']
          ?['runs']
          ?[0]
          ?['text'] as String? ?? 'Sin título';

      String artist = 'Artista desconocido';
      if (columns.length > 1) {
        final runs = columns[1]
            ['musicResponsiveListItemFlexColumnRenderer']
            ?['text']
            ?['runs'] as List?;
        if (runs != null && runs.isNotEmpty) {
          artist = runs[0]['text'] as String? ?? artist;
        }
      }

      final thumbnails = renderer['thumbnail']
          ?['musicThumbnailRenderer']
          ?['thumbnail']
          ?['thumbnails'] as List?;

      String? thumbnailUrl;
      if (thumbnails != null && thumbnails.isNotEmpty) {
        thumbnailUrl = thumbnails.last['url'] as String?;
      }

      final fixedColumns = renderer['fixedColumns'] as List?;
      int duration = 0;
      if (fixedColumns != null && fixedColumns.isNotEmpty) {
        final durationText = fixedColumns[0]
            ['musicResponsiveListItemFixedColumnRenderer']
            ?['text']
            ?['runs']
            ?[0]
            ?['text'] as String?;
        if (durationText != null) {
          duration = _parseDuration(durationText);
        }
      }

      return Song(
        id: videoId,
        title: title,
        artist: artist,
        album: '',
        thumbnailUrl: thumbnailUrl,
        duration: duration,
      );
    } catch (e) {
      print('[Parser] Error parseando song: $e');
      return null;
    }
  }

  static int _parseDuration(String text) {
    final parts = text.split(':');
    if (parts.length == 2) {
      return (int.tryParse(parts[0]) ?? 0) * 60 +
          (int.tryParse(parts[1]) ?? 0);
    }
    if (parts.length == 3) {
      return (int.tryParse(parts[0]) ?? 0) * 3600 +
          (int.tryParse(parts[1]) ?? 0) * 60 +
          (int.tryParse(parts[2]) ?? 0);
    }
    return 0;
  }

  static MusicSearchResult _emptyResult() =>
      const MusicSearchResult(songs: [], artists: [], albums: []);
}