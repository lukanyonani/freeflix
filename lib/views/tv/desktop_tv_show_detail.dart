import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:freeflix/views/shared/components/play_screen.dart';
import 'package:get/get.dart';

import '../../providers/tv_show_provider.dart';
import '../../models/tv_show_model.dart';

/// TV Show Detail Page that displays show info and episodes organized by seasons
class TvShowDetailPage extends ConsumerStatefulWidget {
  final int showId;
  const TvShowDetailPage({super.key, required this.showId});

  @override
  ConsumerState<TvShowDetailPage> createState() => _TvShowDetailPageState();
}

class _TvShowDetailPageState extends ConsumerState<TvShowDetailPage> {
  int selectedSeasonIndex = 0;

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(tvShowDetailsProvider(widget.showId));

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('TV Show Details'),
        elevation: 0,
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Oops! Something went wrong: $err',
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        data: (tvShow) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1024),
            child: _buildDetailView(context, tvShow),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailView(BuildContext context, TvShowDetail tvShow) {
    print('🎬 Building TV Show Detail View for: ${tvShow.name}');
    print(
        '📺 Total Seasons: ${tvShow.numberOfSeasons}, Episodes: ${tvShow.numberOfEpisodes}');

    return CustomScrollView(
      slivers: [
        // Show Header with Poster and Info
        SliverToBoxAdapter(
          child: _buildShowHeader(tvShow),
        ),

        // Season Selector
        SliverToBoxAdapter(
          child: _buildSeasonSelector(tvShow),
        ),

        // Episodes List
        _buildEpisodesSliver(tvShow),

        // Bottom Spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildShowHeader(TvShowDetail tvShow) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster Image
          _buildPoster(tvShow.posterPath, tvShow.id),
          const SizedBox(width: 16),

          // Show Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tvShow.name ?? tvShow.originalName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),

                if (tvShow.tagline.isNotEmpty) ...[
                  Text(
                    '"${tvShow.tagline}"',
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                Text(
                  tvShow.overview,
                  style: const TextStyle(color: Colors.white70),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Show Stats
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _infoChip('Seasons', tvShow.numberOfSeasons.toString()),
                    _infoChip('Episodes', tvShow.numberOfEpisodes.toString()),
                    _infoChip('Rating', tvShow.voteAverage.toStringAsFixed(1)),
                    _infoChip('Status', tvShow.status),
                    if (tvShow.genres.isNotEmpty)
                      _infoChip('Genres',
                          tvShow.genres.map((g) => g.name).join(', ')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoster(String? posterPath, int showId) {
    const baseUrl = 'https://image.tmdb.org/t/p/w300';

    if (posterPath == null || posterPath.isEmpty) {
      return Container(
        width: 120,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.tv,
          size: 48,
          color: Colors.white38,
        ),
      );
    }

    final imageUrl =
        posterPath.startsWith('http') ? posterPath : '$baseUrl$posterPath';

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 120,
        height: 180,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 120,
          height: 180,
          color: Colors.grey[850],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          width: 120,
          height: 180,
          color: Colors.grey[800],
          child:
              const Icon(Icons.broken_image, size: 32, color: Colors.white38),
        ),
      ),
    );
  }

  Widget _buildSeasonSelector(TvShowDetail tvShow) {
    print('🗂️ Building season selector with ${tvShow.seasons.length} seasons');

    if (tvShow.seasons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tvShow.seasons.length,
        itemBuilder: (context, index) {
          final season = tvShow.seasons[index];
          final isSelected = index == selectedSeasonIndex;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                season.name.isNotEmpty
                    ? season.name
                    : 'Season ${season.seasonNumber}',
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              backgroundColor: const Color(0xFF1E1E1E),
              selectedColor: Colors.amber,
              checkmarkColor: Colors.black,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    selectedSeasonIndex = index;
                  });
                  print(
                      '📋 Selected season: ${season.name} (${season.episodeCount} episodes)');
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEpisodesSliver(TvShowDetail tvShow) {
    if (tvShow.seasons.isEmpty ||
        selectedSeasonIndex >= tvShow.seasons.length) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Text(
            'No episodes available',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final selectedSeason = tvShow.seasons[selectedSeasonIndex];
    print('📺 Displaying episodes for ${selectedSeason.name}');

    // Fetch actual episodes for the selected season
    final episodeParams = EpisodeParams(
      showId: tvShow.id,
      seasonNumber: selectedSeason.seasonNumber,
    );

    final episodesAsync = ref.watch(episodesProvider(episodeParams));

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              // Season header
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  '${selectedSeason.name} • ${selectedSeason.episodeCount} Episodes',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              );
            }

            return episodesAsync.when(
              loading: () => const Card(
                color: Color(0xFF1E1E1E),
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              error: (error, stack) => Card(
                color: Color(0xFF1E1E1E),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error loading episodes: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
              data: (episodes) {
                if (index - 1 >= episodes.length)
                  return const SizedBox.shrink();
                final episode = episodes[index - 1];
                return _buildEpisodeCard(
                    episode, tvShow.id, selectedSeason.seasonNumber);
              },
            );
          },
          childCount: episodesAsync.maybeWhen(
            data: (episodes) => episodes.length + 1, // +1 for header
            orElse: () => 2, // header + loading/error card
          ),
        ),
      ),
    );
  }

  Widget _buildEpisodeCard(Episode episode, int showId, int seasonNumber) {
    const baseUrl = 'https://image.tmdb.org/t/p/w300';

    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          print('▶️ Playing Episode ${episode.episodeNumber}: ${episode.name}');
          Get.to(() => PlayScreen(
                id: showId.toString(),
                isMovie: false,
                season: seasonNumber,
                episode: episode.episodeNumber,
              ));
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Episode Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child:
                    episode.stillPath != null && episode.stillPath!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: episode.stillPath!.startsWith('http')
                                ? episode.stillPath!
                                : '$baseUrl${episode.stillPath}',
                            width: 120,
                            height: 68,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 120,
                              height: 68,
                              color: Colors.grey[800],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 120,
                              height: 68,
                              color: Colors.grey[800],
                              child: Stack(
                                children: [
                                  const Center(
                                    child: Icon(
                                      Icons.play_circle_outline,
                                      color: Colors.white54,
                                      size: 32,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      child: Text(
                                        '${episode.episodeNumber}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(
                            width: 120,
                            height: 68,
                            color: Colors.grey[800],
                            child: Stack(
                              children: [
                                const Center(
                                  child: Icon(
                                    Icons.play_circle_outline,
                                    color: Colors.white54,
                                    size: 32,
                                  ),
                                ),
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Text(
                                      '${episode.episodeNumber}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
              ),
              const SizedBox(width: 16),

              // Episode Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Episode ${episode.episodeNumber}: ${episode.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (episode.overview.isNotEmpty) ...[
                      Text(
                        episode.overview,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        if (episode.runtime > 0) ...[
                          const Icon(Icons.schedule,
                              size: 14, color: Colors.white54),
                          const SizedBox(width: 4),
                          Text(
                            '${episode.runtime} min',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        if (episode.voteAverage > 0) ...[
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            episode.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (episode.airDate.isNotEmpty) ...[
                          const SizedBox(width: 16),
                          const Icon(Icons.calendar_today,
                              size: 14, color: Colors.white54),
                          const SizedBox(width: 4),
                          Text(
                            episode.airDate,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Play Button
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.red,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Chip(
      backgroundColor: const Color(0xFF2A2A2A),
      label: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.amber,
                fontSize: 12,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
