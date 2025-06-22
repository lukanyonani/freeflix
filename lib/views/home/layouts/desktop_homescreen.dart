import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../../models/movie_model.dart';
import '../../../viewmodels/movie_viewmodel.dart';
import '../../shared/widgets/drawer.dart';
import '../../shared/widgets/movie_widgets.dart' hide ErrorSection;
import '../../shared/widgets/search_bar_widget.dart';
import '../../tv/desktop_tv_screen.dart';

class DesktopHomescreen extends ConsumerWidget {
  const DesktopHomescreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access different movie categories from our ViewModel
    final popularMovies = ref.watch(popularMoviesStateProvider);
    final nowPlayingMovies = ref.watch(nowPlayingMoviesStateProvider);
    final trendingMovies = ref.watch(trendingMoviesStateProvider);
    final continueWatchingMovies =
        ref.watch(continueWatchingMoviesStateProvider);
    final blockbusterActionMovies =
        ref.watch(blockbusterActionMoviesStateProvider);

    // Get the screen width for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth * 0.18; // 18% of screen width for sidebar

    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Permanent sidebar that replaces the drawer
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
                  // Pull-to-refresh functionality
                  ref.read(movieViewModelProvider).refreshAllMovies();
                },
                child: SingleChildScrollView(
                  child: Column(
                    //padding: const EdgeInsets.all(16),
                    children: [
                      SizedBox(
                        height: 18,
                      ),
                      SearchBarWidget(
                        onChanged: (query) {},
                      ),
                      SizedBox(
                        height: 22,
                      ),
                      // Popular Movies Section
                      popularMovies.when(
                        data: (movies) => buildMovieSection(
                            "Popular on Freeflix",
                            movies,
                            () => ref
                                .read(popularMoviesStateProvider.notifier)
                                .loadMoreMovies()),
                        loading: () => const MovieSectionSkeleton(
                            title: "Popular on Freeflix"),
                        error: (e, _) => ErrorSection(
                          title: "Popular on Freeflix",
                          error: e.toString(),
                          onRetry: () => ref
                              .read(popularMoviesStateProvider.notifier)
                              .refresh(),
                        ),
                      ),

                      // Now Playing Movies Section
                      nowPlayingMovies.when(
                        data: (movies) => buildMovieSection(
                            "Now Playing",
                            movies,
                            () => ref
                                .read(nowPlayingMoviesStateProvider.notifier)
                                .loadMoreMovies()),
                        loading: () =>
                            const MovieSectionSkeleton(title: "Now Playing"),
                        error: (e, _) => ErrorSection(
                          title: "Now Playing",
                          error: e.toString(),
                          onRetry: () => ref
                              .read(nowPlayingMoviesStateProvider.notifier)
                              .refresh(),
                        ),
                      ),

                      // Trending Movies Section
                      trendingMovies.when(
                        data: (movies) => buildMovieSection(
                            "Trending Now",
                            movies,
                            () => ref
                                .read(trendingMoviesStateProvider.notifier)
                                .loadMoreMovies()),
                        loading: () =>
                            const MovieSectionSkeleton(title: "Trending Now"),
                        error: (e, _) => ErrorSection(
                          title: "Trending Now",
                          error: e.toString(),
                          onRetry: () => ref
                              .read(trendingMoviesStateProvider.notifier)
                              .refresh(),
                        ),
                      ),

                      // Continue Watching Section
                      continueWatchingMovies.when(
                        data: (movies) => buildMovieSection(
                          "Continue Watching",
                          movies,
                          () => ref
                              .read(
                                  continueWatchingMoviesStateProvider.notifier)
                              .loadMoreMovies(),
                          showPlayButton: true,
                        ),
                        loading: () => const MovieSectionSkeleton(
                            title: "Continue Watching"),
                        error: (e, _) => ErrorSection(
                          title: "Continue Watching",
                          error: e.toString(),
                          onRetry: () => ref
                              .read(
                                  continueWatchingMoviesStateProvider.notifier)
                              .refresh(),
                        ),
                      ),

                      // Blockbuster Action Section
                      blockbusterActionMovies.when(
                        data: (movies) => buildMovieSection(
                            "Blockbuster Action",
                            movies,
                            () => ref
                                .read(blockbusterActionMoviesStateProvider
                                    .notifier)
                                .loadMoreMovies()),
                        loading: () => const MovieSectionSkeleton(
                            title: "Blockbuster Action"),
                        error: (e, _) => ErrorSection(
                          title: "Blockbuster Action",
                          error: e.toString(),
                          onRetry: () => ref
                              .read(
                                  blockbusterActionMoviesStateProvider.notifier)
                              .refresh(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ]),
    );
  }

  Widget buildMovieSection(
      String title, List<MovieDetail> movies, VoidCallback onLoadMore,
      {bool showPlayButton = false}) {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: Get.height * 0.3,
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                // Load more movies when reaching the end of the list
                if (scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
                  onLoadMore();
                  return true;
                }
                return false;
              },
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: movies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return MovieCard(
                    movie: movie,
                    showPlayButton: showPlayButton,
                    isTablet: false,
                    isMovie: true,
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
          buildDrawerItem(Icons.home, 'Home', true,
              onTap: () => Get.to(() => const DesktopHomescreen())),
          buildDrawerItem(Icons.tv, 'TV Shows', false,
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
