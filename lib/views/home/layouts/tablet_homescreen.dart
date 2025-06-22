import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../../models/movie_model.dart';
import '../../../viewmodels/movie_viewmodel.dart';
import '../../shared/widgets/movie_widgets.dart';

class TabletHomescreen extends ConsumerWidget {
  const TabletHomescreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch providers
    final popularMovies = ref.watch(popularMoviesStateProvider);
    final nowPlayingMovies = ref.watch(nowPlayingMoviesStateProvider);
    final trendingMovies = ref.watch(trendingMoviesStateProvider);
    final continueWatchingMovies =
        ref.watch(continueWatchingMoviesStateProvider);
    final blockbusterActionMovies =
        ref.watch(blockbusterActionMoviesStateProvider);

    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final sidebarWidth = screenWidth * 0.18;

    return Scaffold(
      drawer: DrawerWidget(
          sidebarWidth:
              sidebarWidth), // just so the hamburger icon knows where to open
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Image.asset(
          'assets/images/logo.png',
          height: 32, // adjust as needed
          fit: BoxFit.contain,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // you could navigate to a search page, or expand a search field…
              print('Search icon pressed');
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async =>
                  ref.read(movieViewModelProvider).refreshAllMovies(),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // const SizedBox(height: 12),
                    // SearchBarWidget(
                    //     onChanged: (q) => print('Searching for: $q')),
                    const SizedBox(height: 22),

                    // Popular
                    popularMovies.when(
                      data: (movies) => _buildResponsiveSection(
                        context,
                        title: "Popular on Freeflix",
                        movies: movies,
                        onLoadMore: () => ref
                            .read(popularMoviesStateProvider.notifier)
                            .loadMoreMovies(),
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                      ),
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

                    // Now Playing
                    nowPlayingMovies.when(
                      data: (movies) => _buildResponsiveSection(
                        context,
                        title: "Now Playing",
                        movies: movies,
                        onLoadMore: () => ref
                            .read(nowPlayingMoviesStateProvider.notifier)
                            .loadMoreMovies(),
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                      ),
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

                    // Trending
                    trendingMovies.when(
                      data: (movies) => _buildResponsiveSection(
                        context,
                        title: "Trending Now",
                        movies: movies,
                        onLoadMore: () => ref
                            .read(trendingMoviesStateProvider.notifier)
                            .loadMoreMovies(),
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                      ),
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

                    // Continue Watching
                    continueWatchingMovies.when(
                      data: (movies) => _buildResponsiveSection(
                        context,
                        title: "Continue Watching",
                        movies: movies,
                        onLoadMore: () => ref
                            .read(continueWatchingMoviesStateProvider.notifier)
                            .loadMoreMovies(),
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                        showPlayButton: true,
                      ),
                      loading: () => const MovieSectionSkeleton(
                          title: "Continue Watching"),
                      error: (e, _) => ErrorSection(
                        title: "Continue Watching",
                        error: e.toString(),
                        onRetry: () => ref
                            .read(continueWatchingMoviesStateProvider.notifier)
                            .refresh(),
                      ),
                    ),

                    // Blockbuster Action
                    blockbusterActionMovies.when(
                      data: (movies) => _buildResponsiveSection(
                        context,
                        title: "Blockbuster Action",
                        movies: movies,
                        onLoadMore: () => ref
                            .read(blockbusterActionMoviesStateProvider.notifier)
                            .loadMoreMovies(),
                        screenWidth: screenWidth,
                        screenHeight: screenHeight,
                      ),
                      loading: () => const MovieSectionSkeleton(
                          title: "Blockbuster Action"),
                      error: (e, _) => ErrorSection(
                        title: "Blockbuster Action",
                        error: e.toString(),
                        onRetry: () => ref
                            .read(blockbusterActionMoviesStateProvider.notifier)
                            .refresh(),
                      ),
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

  Widget _buildResponsiveSection(
    BuildContext context, {
    required String title,
    required List<MovieDetail> movies,
    required VoidCallback onLoadMore,
    required double screenWidth,
    required double screenHeight,
    bool showPlayButton = false,
  }) {
    final cardHeight = screenHeight * 0.35;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: cardHeight,
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
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
                itemBuilder: (context, index) => SizedBox(
                  width: Get.width * 0.2,
                  child: MovieCard(
                    movie: movies[index],
                    showPlayButton: showPlayButton,
                    isTablet: true,
                    isMovie: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
