class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String? thumbnailUrl;
  final int duration;
  final bool isLocal;

  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    this.thumbnailUrl,
    required this.duration,
    this.isLocal = false,
  });

  String get formattedDuration {
    final m = duration ~/ 60;
    final s = duration % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}