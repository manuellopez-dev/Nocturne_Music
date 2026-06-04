import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/innertube/providers/innertube_providers.dart';
import '../../data/innertube/providers/player_providers.dart';
import '../../domain/models/song.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _SearchHeader(
              controller: _controller,
              onChanged: (value) {
                if (value.length >= 3) {
                  ref.read(searchProvider.notifier).search(value);
                } else if (value.isEmpty) {
                  ref.read(searchProvider.notifier).clear();
                }
              },
              onClear: () {
                _controller.clear();
                ref.read(searchProvider.notifier).clear();
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: searchState.query.isEmpty
                  ? _BrowseContent()
                  : _SearchResultsView(state: searchState),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchHeader({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Buscar', style: AppTextStyles.displayMedium),
          const SizedBox(height: 16),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Canciones, artistas, álbumes...',
                hintStyle: const TextStyle(
                  color: AppColors.textDisabled,
                  fontSize: 15,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textDisabled,
                  size: 22,
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? GestureDetector(
                        onTap: onClear,
                        child: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrowseContent extends ConsumerWidget {
  const _BrowseContent({super.key});

  final List<Map<String, dynamic>> categories = const [
    {'label': 'Pop', 'color': 0xFFB71C1C},
    {'label': 'Rock', 'color': 0xFF7F0000},
    {'label': 'Hip-Hop', 'color': 0xFF4A0000},
    {'label': 'Electrónica', 'color': 0xFF8D0000},
    {'label': 'R&B', 'color': 0xFF600000},
    {'label': 'Jazz', 'color': 0xFF3B0000},
    {'label': 'Clásica', 'color': 0xFF9A0007},
    {'label': 'Reggaeton', 'color': 0xFF6D0000},
    {'label': 'Metal', 'color': 0xFF5D0000},
    {'label': 'Indie', 'color': 0xFF780000},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Explorar géneros', style: AppTextStyles.titleMedium),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.8,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return _CategoryCard(
                label: cat['label'],
                color: Color(cat['color']),
                onTap: () {
                  ref.read(searchProvider.notifier).search(cat['label']);
                },
              );
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({required this.label, required this.color, required this.onTap,});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, color.withOpacity(0.5)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: -10,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultsView extends ConsumerWidget {
  final SearchState state;

  const _SearchResultsView({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return state.result.when(
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: AppColors.textDisabled,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text('No se pudo conectar', style: AppTextStyles.titleMedium),
            const SizedBox(height: 6),
            Text('Verifica tu conexión', style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
      data: (result) {
  final songs = result.songs;
  if (songs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.search_off_rounded,
                  color: AppColors.textDisabled,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text('Sin resultados', style: AppTextStyles.titleMedium),
              ],
            ),
          );
        }

        return ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    itemCount: songs.length,
    itemBuilder: (context, index) {
      final song = songs[index];
      return _SongResultTile(
        song: song,
        onTap: () {
          ref.read(playerProvider.notifier).playSong(song);
          context.push('/player');
        },
      );
    },
  );
},
    );
  }
}

class _SongResultTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const _SongResultTile({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                image: song.thumbnailUrl != null
                    ? DecorationImage(
                        image: NetworkImage(song.thumbnailUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: song.thumbnailUrl == null
                  ? const Icon(
                      Icons.music_note_rounded,
                      color: AppColors.textDisabled,
                      size: 24,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    song.artist,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              song.formattedDuration,
              style: const TextStyle(
                color: AppColors.textDisabled,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}