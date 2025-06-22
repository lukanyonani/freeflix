import 'package:flutter/material.dart';
import 'package:freeflix/views/shared/widgets/drawer.dart';
import 'package:get/get.dart';

import '../../../models/movie_model.dart';
import '../../movie/movie_detail.dart';

class MovieCard extends StatelessWidget {
  final MovieDetail movie;
  final bool showPlayButton;
  final bool isTablet;
  final bool isMovie;

  const MovieCard({
    super.key,
    required this.movie,
    this.showPlayButton = false,
    required this.isTablet,
    required this.isMovie,
  });

  @override
  Widget build(BuildContext context) {
    final posterUrl = movie.posterPath != null
        ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}'
        : null;

    return GestureDetector(
      onTap: () {
        Get.to(() => MovieDetailPage(movieId: movie.id));
        // Navigate to movie details
        // showDialog(
        //   context: context,
        //   builder: (context) => AlertDialog(
        //     backgroundColor: const Color(0xFF1E1E1E),
        //     title:
        //         Text(movie.title, style: const TextStyle(color: Colors.white)),
        //     content: SizedBox(
        //       width: 500,
        //       height: 300,
        //       child: SingleChildScrollView(
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             if (posterUrl != null)
        //               Container(
        //                 height: 200,
        //                 decoration: BoxDecoration(
        //                   image: DecorationImage(
        //                     image: NetworkImage(posterUrl),
        //                     fit: BoxFit.cover,
        //                   ),
        //                 ),
        //               ),
        //             const SizedBox(height: 16),
        //             Text(
        //               movie.overview,
        //               style: const TextStyle(color: Colors.white),
        //             ),
        //             const SizedBox(height: 8),
        //             Text(
        //               'Rating: ${movie.voteAverage.toStringAsFixed(1)}/10',
        //               style: const TextStyle(color: Colors.white70),
        //             ),
        //             Text(
        //               'Release Date: ${movie.releaseDate}',
        //               style: const TextStyle(color: Colors.white70),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //     actions: [
        //       TextButton(
        //         onPressed: () => Navigator.pop(context),
        //         child: const Text('Close'),
        //       ),
        //       TextButton(
        //         onPressed: () {
        //           // Play movie action
        //           Navigator.pop(context);
        //         },
        //         child: const Text('Watch Now'),
        //       ),
        //     ],
        //   ),
        // );
      },
      child: Stack(
        children: [
          Container(
            width: isTablet ? Get.width * 0.2 : Get.width * 0.1,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(8),
              image: posterUrl != null
                  ? DecorationImage(
                      image: NetworkImage(posterUrl), fit: BoxFit.cover)
                  : null,
            ),
            child: posterUrl == null
                ? Center(
                    child: Text(
                      movie.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                : null,
          ),
          if (showPlayButton)
            Positioned.fill(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 14),
                  const SizedBox(width: 2),
                  Text(
                    movie.voteAverage.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading skeleton for movie sections
class MovieSectionSkeleton extends StatelessWidget {
  final String title;

  const MovieSectionSkeleton({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 5, // Show 5 skeleton items
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return Container(
                width: 130,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.red,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

/// Error section with retry button
class ErrorSection extends StatelessWidget {
  final String title;
  final String error;
  final VoidCallback onRetry;

  const ErrorSection({
    Key? key,
    required this.title,
    required this.error,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 32),
              const SizedBox(height: 8),
              Text(
                'Failed to load movies',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                error,
                style: TextStyle(color: Colors.red.shade300, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({
    super.key,
    required this.sidebarWidth,
  });

  final double sidebarWidth;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        width: sidebarWidth,
        color: const Color(0xFF1E1E1E),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            SizedBox(
              height: 40,
            ),
            Container(
                height: 60,
                width: 60,
                alignment: Alignment.center,
                child: Image.asset('assets/images/logo.png')),
            SizedBox(
              height: 40,
            ),
            buildDrawerItem(
              Icons.home,
              'Home',
              true,
            ),
            buildDrawerItem(Icons.tv, 'TV Shows', false),
            buildDrawerItem(Icons.movie, 'Anime', false),
            buildDrawerItem(Icons.new_releases, 'Recently Added', false),
            buildDrawerItem(Icons.bookmark, 'My Favorites', false),
            const Divider(
              color: Colors.grey,
              thickness: 0.1,
            ),
            buildDrawerItem(Icons.help, 'FAQ', false),
            buildDrawerItem(Icons.support, 'Help Center', false),
            buildDrawerItem(Icons.description, 'Terms of Use', false),
            buildDrawerItem(Icons.privacy_tip, 'Privacy', false),
          ],
        ),
      ),
    );
  }
}
