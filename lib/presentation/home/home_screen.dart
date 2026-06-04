import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/innertube/providers/home_providers.dart';
import '../../data/innertube/providers/player_providers.dart';
import '../../domain/models/song.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _NocturneAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const _FeaturedSection(),
                const SizedBox(height: 28),
                const _SectionHeader(title: 'Recién escuchado'),
                const SizedBox(height: 12),
                const _RecentlyPlayedRow(),
                const SizedBox(height: 28),
                const _SectionHeader(title: 'Recomendado para ti'),
                const SizedBox(height: 12),
                const _RecommendedGrid(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NocturneAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 80,
      floating: true,
      snap: true,
      backgroundColor: AppColors.background,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bienvenido',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    )),
                Text('Nocturne',
                    style: TextStyle(
                      fontSize: 22,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    )),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AppBarIcon(icon: Icons.notifications_outlined),
                const SizedBox(width: 8),
                _AppBarIcon(icon: Icons.settings_outlined),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AppBarIcon extends StatelessWidget {
  final IconData icon;
  const _AppBarIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.textPrimary, size: 18),
    );
  }
}

class _FeaturedSection extends StatelessWidget {
  const _FeaturedSection();

  final List<Map<String, dynamic>> featured = const [
    {'title': 'Mix del día', 'subtitle': 'Basado en tu historial', 'color': 0xFFB71C1C},
    {'title': 'Éxitos 2024', 'subtitle': 'Lo más escuchado', 'color': 0xFF7F0000},
    {'title': 'Chill Night', 'subtitle': 'Para relajarte', 'color': 0xFF4A0000},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        padEnds: false,
        controller: PageController(viewportFraction: 0.88),
        itemCount: featured.length,
        itemBuilder: (context, index) {
          final item = featured[index];
          return _FeaturedCard(
            title: item['title'],
            subtitle: item['subtitle'],
            color: Color(item['color']),
          );
        },
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;

  const _FeaturedCard({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/player'),
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.4)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('PLAYLIST',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        )),
                  ),
                  const SizedBox(height: 8),
                  Text(title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      )),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
                      )),
                ],
              ),
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: AppColors.primary, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTextStyles.titleMedium),
          const Text('Ver todo',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.accent,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }
}

class _RecentlyPlayedRow extends ConsumerWidget {
  const _RecentlyPlayedRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(recentlyPlayedProvider);

    if (songs.isEmpty) {
      return SizedBox(
        height: 160,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 4,
          itemBuilder: (context, index) => _SongCardPlaceholder(),
        ),
      );
    }

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return _SongCard(
            song: song,
            onTap: () {
              ref.read(playerProvider.notifier).playSong(song);
              context.push('/player');
            },
          );
        },
      ),
    );
  }
}

class _SongCard extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const _SongCard({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 130,
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: song.thumbnailUrl != null
                    ? CachedNetworkImage(
                        imageUrl: song.thumbnailUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const Center(
                          child: Icon(Icons.music_note_rounded,
                              color: Colors.white24, size: 48),
                        ),
                        errorWidget: (_, __, ___) => const Center(
                          child: Icon(Icons.music_note_rounded,
                              color: Colors.white24, size: 48),
                        ),
                      )
                    : const Icon(Icons.music_note_rounded,
                        color: Colors.white24, size: 48),
              ),
            ),
            const SizedBox(height: 8),
            Text(song.title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(song.artist,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _SongCardPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 130,
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(Icons.music_note_rounded,
                  color: Colors.white12, size: 48),
            ),
          ),
          const SizedBox(height: 8),
          Container(
              height: 12,
              width: 90,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
              )),
          const SizedBox(height: 4),
          Container(
              height: 10,
              width: 60,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
              )),
        ],
      ),
    );
  }
}

class _RecommendedGrid extends ConsumerWidget {
  const _RecommendedGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendations = ref.watch(recommendationsProvider);

    return recommendations.when(
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: List.generate(4, (_) => _RecommendedTilePlaceholder()),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (songs) {
        if (songs.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: songs
                .map((song) => _RecommendedTile(
                      song: song,
                      onTap: () {
                        ref.read(playerProvider.notifier).playSong(song);
                        context.push('/player');
                      },
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}

class _RecommendedTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const _RecommendedTile({required this.song, required this.onTap});

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
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: song.thumbnailUrl != null
                    ? CachedNetworkImage(
                        imageUrl: song.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const Icon(
                            Icons.music_note_rounded,
                            color: AppColors.textDisabled,
                            size: 24),
                      )
                    : const Icon(Icons.music_note_rounded,
                        color: AppColors.textDisabled, size: 24),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(song.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(song.artist,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      )),
                ],
              ),
            ),
            const Icon(Icons.more_vert_rounded,
                color: AppColors.textDisabled, size: 20),
          ],
        ),
      ),
    );
  }
}

class _RecommendedTilePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  height: 14,
                  width: 140,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                  )),
              const SizedBox(height: 6),
              Container(
                  height: 11,
                  width: 90,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}