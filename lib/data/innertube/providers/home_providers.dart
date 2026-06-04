import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/song.dart';
import 'innertube_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Canciones recién reproducidas — se actualiza cuando tocas una canción
final recentlyPlayedProvider = StateProvider<List<Song>>((ref) => []);

// Agrega una canción al historial
void addToRecentlyPlayed(Ref ref, Song song) {  // Ref en lugar de WidgetRef
  final current = ref.read(recentlyPlayedProvider);
  final updated = [song, ...current.where((s) => s.id != song.id)].take(10).toList();
  ref.read(recentlyPlayedProvider.notifier).state = updated;
}

// Recomendaciones — busca canciones de géneros variados
final recommendationsProvider = FutureProvider<List<Song>>((ref) async {
  final repo = ref.read(innerTubeRepositoryProvider);
  final queries = ['pop hits', 'rock classics', 'hip hop 2024', 'chill vibes'];
  queries.shuffle();
  try {
    final result = await repo.search(queries.first);
    return result.songs.take(6).toList();
  } catch (e) {
    return [];
  }
});