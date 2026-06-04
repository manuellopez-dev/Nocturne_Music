import 'song.dart';

class MusicSearchResult {
  final List<Song> songs;
  final List<MusicArtistResult> artists;
  final List<MusicAlbumResult> albums;

  const MusicSearchResult({
    required this.songs,
    required this.artists,
    required this.albums,
  });
}

class MusicArtistResult {
  final String id;
  final String name;
  final String? thumbnailUrl;

  const MusicArtistResult({
    required this.id,
    required this.name,
    this.thumbnailUrl,
  });
}

class MusicAlbumResult {
  final String id;
  final String title;
  final String artist;
  final String? thumbnailUrl;

  const MusicAlbumResult({
    required this.id,
    required this.title,
    required this.artist,
    this.thumbnailUrl,
  });
}