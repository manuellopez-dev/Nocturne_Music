import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../innertube_repository.dart';
import '../../../domain/models/search_result.dart';
import '../../auth/auth_service.dart';
import '../../../services/audio_handler.dart';

final innerTubeRepositoryProvider = Provider<InnerTubeRepository>((ref) {
  final repo = InnerTubeRepository();
  final authService = AuthService();
  authService.getAccessToken().then((token) {
    if (token != null) {
      repo.setAccessToken(token);
      nocturnePlayer.setAuthToken(token);
      print('[Provider] Token inyectado al repositorio y player');
    } else {
      print('[Provider] Token NULL — no se inyectó');
    }
  });
  return repo;
});

class SearchState {
  final String query;
  final AsyncValue<MusicSearchResult> result;

  const SearchState({
    this.query = '',
    this.result = const AsyncValue.data(
      MusicSearchResult(songs: [], artists: [], albums: []),
    ),
  });

  SearchState copyWith({
    String? query,
    AsyncValue<MusicSearchResult>? result,
  }) {
    return SearchState(
      query: query ?? this.query,
      result: result ?? this.result,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final InnerTubeRepository _repository;

  SearchNotifier(this._repository) : super(const SearchState());

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(
      query: query,
      result: const AsyncValue.loading(),
    );

    try {
      final result = await _repository.search(query);
      state = state.copyWith(result: AsyncValue.data(result));
    } catch (e, st) {
      print('[Search] Error: $e');
      print('[Search] StackTrace: $st');
      state = state.copyWith(result: AsyncValue.error(e, st));
    }
  }

  void clear() {
    state = const SearchState();
  }
}

final searchProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final repo = ref.watch(innerTubeRepositoryProvider);
  return SearchNotifier(repo);
});