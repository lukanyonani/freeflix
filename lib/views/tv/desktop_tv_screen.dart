import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../models/tv_show_model.dart';
import '../../providers/tv_show_provider.dart';
import '../home/layouts/desktop_homescreen.dart';
import '../shared/widgets/drawer.dart';
import '../shared/widgets/search_bar_widget.dart';
import 'desktop_tv_show_detail.dart';

class DesktopTVHomescreen extends ConsumerWidget {
  const DesktopTVHomescreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access different TV show categories from providers
    final popularTVShows = ref.watch(popularTVShowsProvider);
    final trendingTVShows = ref.watch(trendingTVShowsProvider);

    // Get the screen width for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth * 0.18; // 18% of screen width for sidebar

    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Permanent sidebar
          DrawerWidget(sidebarWidth: sidebarWidth),

          // Vertical divider between sidebar and content
          Container(
            width: 0.5,
            color: Colors.grey.shade800,
          ),

          // Main content area
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // Refresh all TV show categories
                ref.read(topRatedTvShowsListProvider.notifier).refreshShows();
                ref
                    .read(airingTodayTvShowsListProvider.notifier)
                    .refreshShows();
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: () {
                        // Navigate back to movies or search
                        Get.back();
                      },
                      child: SearchBarWidget(
                        onChanged: (query) {
                          print('Searching TV shows for: $query');
                        },
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Popular TV Shows Section
                    popularTVShows.when(
                      data: (shows) => buildTVShowSection(
                        "Popular TV Shows",
                        shows,
                        () {}, // No pagination for this provider
                      ),
                      loading: () => const TVShowSectionSkeleton(
                          title: "Popular TV Shows"),
                      error: (e, _) => ErrorSection(
                        title: "Popular TV Shows",
                        error: e.toString(),
                        onRetry: () => ref.refresh(popularTVShowsProvider),
                      ),
                    ),

                    // Trending TV Shows Section
                    trendingTVShows.when(
                      data: (shows) => buildTVShowSection(
                        "Trending TV Shows",
                        shows,
                        () {}, // No pagination for this provider
                      ),
                      loading: () => const TVShowSectionSkeleton(
                          title: "Trending TV Shows"),
                      error: (e, _) => ErrorSection(
                        title: "Trending TV Shows",
                        error: e.toString(),
                        onRetry: () => ref.refresh(trendingTVShowsProvider),
                      ),
                    ),

                    // Top Rated TV Shows Section
                    Consumer(
                      builder: (context, ref, child) {
                        final topRatedState =
                            ref.watch(topRatedTvShowsListProvider);

                        // Initialize if empty
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (topRatedState.shows.isEmpty &&
                              !topRatedState.isLoading &&
                              topRatedState.error == null) {
                            ref
                                .read(topRatedTvShowsListProvider.notifier)
                                .loadShows();
                          }
                        });

                        if (topRatedState.shows.isEmpty &&
                            topRatedState.isLoading) {
                          return const TVShowSectionSkeleton(
                              title: "Top Rated TV Shows");
                        }

                        if (topRatedState.shows.isEmpty &&
                            topRatedState.error != null) {
                          return ErrorSection(
                            title: "Top Rated TV Shows",
                            error: topRatedState.error!,
                            onRetry: () => ref
                                .read(topRatedTvShowsListProvider.notifier)
                                .refreshShows(),
                          );
                        }

                        return buildTVShowSection(
                          "Top Rated TV Shows",
                          topRatedState.shows,
                          () => ref
                              .read(topRatedTvShowsListProvider.notifier)
                              .loadMoreShows(),
                          isLoading: topRatedState.isLoading &&
                              topRatedState.shows.isNotEmpty,
                        );
                      },
                    ),

                    // Airing Today TV Shows Section
                    Consumer(
                      builder: (context, ref, child) {
                        final airingTodayState =
                            ref.watch(airingTodayTvShowsListProvider);

                        // Initialize if empty
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (airingTodayState.shows.isEmpty &&
                              !airingTodayState.isLoading &&
                              airingTodayState.error == null) {
                            ref
                                .read(airingTodayTvShowsListProvider.notifier)
                                .loadShows();
                          }
                        });

                        if (airingTodayState.shows.isEmpty &&
                            airingTodayState.isLoading) {
                          return const TVShowSectionSkeleton(
                              title: "Airing Today");
                        }

                        if (airingTodayState.shows.isEmpty &&
                            airingTodayState.error != null) {
                          return ErrorSection(
                            title: "Airing Today",
                            error: airingTodayState.error!,
                            onRetry: () => ref
                                .read(airingTodayTvShowsListProvider.notifier)
                                .refreshShows(),
                          );
                        }

                        return buildTVShowSection(
                          "Airing Today",
                          airingTodayState.shows,
                          () => ref
                              .read(airingTodayTvShowsListProvider.notifier)
                              .loadMoreShows(),
                          isLoading: airingTodayState.isLoading &&
                              airingTodayState.shows.isNotEmpty,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTVShowSection(
    String title,
    List<TVShow> shows,
    VoidCallback onLoadMore, {
    bool showPlayButton = false,
    bool isLoading = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: Get.height * 0.3,
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                // Load more TV shows when reaching the end of the list
                if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
                  onLoadMore();
                  return true;
                }
                return false;
              },
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: shows.length + (isLoading ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  if (index == shows.length && isLoading) {
                    // Show loading indicator at the end
                    return Container(
                      width: Get.width * 0.1,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        color: Color(0xFFE50914),
                      ),
                    );
                  }

                  final tvShow = shows[index];
                  return TvShowCard(
                    tvShow: tvShow,
                    showPlayButton: showPlayButton,
                    isTablet: false,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

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

    return Stack(
      children: [
        Container(
          width: isTablet ? Get.width * 0.2 : Get.width * 0.1,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(8),
            image: posterUrl != null
                ? DecorationImage(
                    image: NetworkImage(posterUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: posterUrl == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.tv,
                        color: Colors.grey,
                        size: 48,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tvShow.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
              mainAxisSize: MainAxisSize.min,
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
    return Container(
      width: sidebarWidth,
      color: const Color(0xFF1E1E1E),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          const SizedBox(height: 40),
          Container(
            height: 60,
            width: 60,
            alignment: Alignment.center,
            child: Image.asset('assets/images/logo.png'),
          ),
          const SizedBox(height: 40),
          buildDrawerItem(Icons.home, 'Home', false,
              onTap: () => Get.to(() => const DesktopHomescreen())),
          buildDrawerItem(Icons.tv, 'TV Shows', true,
              onTap: () => Get.to(() => const DesktopTVHomescreen())),
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
    );
  }
}

class TVShowSectionSkeleton extends StatelessWidget {
  final String title;

  const TVShowSectionSkeleton({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: Get.height * 0.3,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return Container(
                  width: Get.width * 0.1,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFE50914),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorSection extends StatelessWidget {
  final String title;
  final String error;
  final VoidCallback onRetry;

  const ErrorSection({
    super.key,
    required this.title,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: Get.height * 0.3,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFE50914),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load $title',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE50914),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
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
