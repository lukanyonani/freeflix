import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/tv_show_model.dart'; // Your TvShow or TvShowDetail

class TvShowCard extends StatelessWidget {
  final TVShow tvShow;
  final bool showPlayButton;
  final bool isTablet;

  const TvShowCard({
    super.key,
    required this.tvShow,
    this.showPlayButton = false,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final posterUrl = tvShow.thumbnail != null
        ? 'https://image.tmdb.org/t/p/w500${tvShow.thumbnail}'
        : null;

    return GestureDetector(
      onTap: () {
        //Get.to(() => TvShowDetailPage(tvShowId: tvShow.id));
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
                      tvShow.name,
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
                    tvShow.voteAverage.toStringAsFixed(1),
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
