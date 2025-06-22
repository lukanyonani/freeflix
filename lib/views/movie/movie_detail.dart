import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:freeflix/views/shared/components/play_screen.dart';
import 'package:get/get.dart';
import '../../models/movie_model.dart';
import '../../providers/movie_provider.dart';

/// A FutureProvider.family to fetch movie details by ID
final movieDetailProvider =
    FutureProvider.family<MovieDetail, int>((ref, movieId) {
  final service = ref.read(movieServiceProvider);
  return service.fetchMovieDetail(movieId);
});

/// Movie Detail Page accepts a movieId and displays the details fetched from TMDb
class MovieDetailPage extends ConsumerWidget {
  final int movieId;
  const MovieDetailPage({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(movieDetailProvider(movieId));

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Movie Details'),
      ),
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (movie) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1024),
            child: _buildDetailView(context, movie),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailView(BuildContext context, MovieDetail movie) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster with Play Button Overlay
          Center(child: _buildPoster(movie.posterPath, movie.id)),
          const SizedBox(height: 16),
          Text(
            movie.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.overview,
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _infoChip('Genre', movie.genres.join(', ')),
              _infoChip('Release', movie.releaseDate),
              _infoChip('Runtime', '${movie.runtime} min'),
              _infoChip('Rating', movie.voteAverage.toString()),
              _infoChip('Language', movie.originalLanguage.toUpperCase()),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
          ),
        ],
      ),
    );
  }

  /// Builds the poster widget using CachedNetworkImage with TMDb base URL
  /// and overlays a red play button in the center.
  Widget _buildPoster(String? posterPath, int showId) {
    String showIdStr = showId.toString(); // "123"
    const baseUrl = 'https://image.tmdb.org/t/p/w500';
    if (posterPath == null || posterPath.isEmpty) {
      return Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.movie,
          size: 64,
          color: Colors.white38,
        ),
      );
    }
    final imageUrl =
        posterPath.startsWith('http') ? posterPath : '$baseUrl$posterPath';
    return InkWell(
      onTap: () => Get.to(() => PlayScreen(
            id: showIdStr,
            isMovie: true,
          )),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: double.infinity,
              height: 550,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: double.infinity,
                height: 550,
                alignment: Alignment.center,
                color: Colors.grey[850],
                child: const CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => Container(
                width: double.infinity,
                height: 550,
                color: Colors.grey[800],
                child: const Icon(
                  Icons.broken_image,
                  size: 64,
                  color: Colors.white38,
                ),
              ),
            ),
          ),
          // Play Button Overlay
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 48,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    return Chip(
      backgroundColor: const Color(0xFF1E1E1E),
      label: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
