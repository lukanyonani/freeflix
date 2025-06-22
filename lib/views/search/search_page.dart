import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freeflix/views/home/layouts/desktop_homescreen.dart';
import 'package:get/get.dart';
import '../../models/search_models.dart';
import '../../providers/movie_provider.dart';
import '../../providers/tv_show_provider.dart';
import '../../viewmodels/search_viewmodel.dart';
import '../movie/movie_detail.dart';
import '../shared/components/display_screen.dart';
import '../tv/desktop_tv_screen.dart';
import '../tv/desktop_tv_show_detail.dart';

/// 🌟 The SearchPage - Your gateway to cinematic treasures! 🌟
/// Now with a sleek Freeflix desktop vibe and Riverpod magic! 🎬
class SearchPage extends ConsumerStatefulWidget {
  const SearchPage(this.isMobile, {super.key});
  final bool isMobile;

  @override
  ConsumerState<SearchPage> createState() {
    print("🎭 SearchPage: Creating state - Ready for the spotlight!");
    return _SearchPageState();
  }
}

class _SearchPageState extends ConsumerState<SearchPage> {
  // 🎯 Search controller - the maestro of our search symphony!
  final TextEditingController _searchController = TextEditingController();

  // 🏷️ The fabulous three categories - choose your adventure!
  final List<String> _categories = [
    'multi', // 🎪 The variety show
    'movie', // 🎬 Hollywood blockbusters
    'tv', // 📺 Binge-worthy series
  ];

  @override
  void initState() {
    super.initState();
    print("🚀 SearchPage: Initializing - Lights, camera, action!");
  }

  @override
  void dispose() {
    print("🧹 SearchPage: Cleaning up - Closing the curtains!");
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("🏗️ SearchPage: Building UI - Crafting a cinematic experience!");

    final searchState = ref.watch(searchViewModelProvider);
    final searchViewModel = ref.read(searchViewModelProvider.notifier);

    // 🔍 Log the search state like a movie detective
    print("🔍 Current query: '${searchState.currentQuery}'");
    print("📂 Selected category: ${searchState.selectedCategory}");
    print("⏳ Loading: ${searchState.isLoading ? 'SEARCHING...' : 'READY!'}}");
    if (searchState.error != null) {
      print("🚨 Error detected: ${searchState.error}");
    }

    // 📏 Responsive design for that desktop vibe
    final screenWidth = MediaQuery.of(context).size.width;
    final sidebarWidth = screenWidth * 0.18;

    return Scaffold(
      backgroundColor: Colors.black, // 🌃 Dark theme for that premium feel
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // // 🎭 Sidebar - keeping it consistent with Freeflix style
          widget.isMobile ? Container() : _buildSidebar(sidebarWidth),
          widget.isMobile
              ? Container()
              : Container(
                  width: 0.5,
                  color: Colors.grey.shade800,
                ),

          // 🎬 Main content area - where the search magic happens
          Expanded(
            child: Column(
              children: [
                // 🎯 Header with back button
                _buildHeader(),

                // 🔍 Search bar - the star of the show
                _buildSearchSection(searchViewModel),

                // 🏷️ Category chips - pick your flavor
                _buildCategorySection(searchState, searchViewModel),

                // 🎭 Results or recommended content
                Expanded(
                  child: _buildResultsArea(searchState),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🏠 Sidebar to match the Freeflix aesthetic
  Widget _buildSidebar(double sidebarWidth) {
    print("🏗️ Building sidebar - Keeping it sleek and stylish!");

    return Container(
      width: sidebarWidth,
      color: const Color(0xFF1E1E1E),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          const SizedBox(height: 40),
          // 🎭 Logo section
          Container(
            height: 60,
            width: 60,
            alignment: Alignment.center,
            child: Image.asset('assets/images/logo.png'),
          ),
          const SizedBox(height: 40),

          // 🔍 Highlight search as we're here!
          _buildDrawerItem(Icons.home, 'Home', false, onTap: () {
            print("🏠 Navigating to Home!");
            Get.to(() => DesktopHomescreen());
          }),
          _buildDrawerItem(Icons.tv, 'TV Shows', false, onTap: () {
            print("📺 Navigating to TV Shows!");
            Get.to(() => DesktopTVHomescreen());
          }),
          _buildDrawerItem(Icons.movie, 'Anime', false, onTap: () {
            print("🎬 Navigating to Anime!");
            Navigator.pushNamed(context, '/anime');
          }),
          _buildDrawerItem(Icons.new_releases, 'Recently Added', false,
              onTap: () {
            print("🆕 Navigating to Recently Added!");
            Navigator.pushNamed(context, '/recently_added');
          }),
          _buildDrawerItem(Icons.bookmark, 'My Favorites', false, onTap: () {
            print("❤️ Navigating to My Favorites!");
            Navigator.pushNamed(context, '/favorites');
          }),

          const Divider(color: Colors.grey, thickness: 0.1),

          _buildDrawerItem(Icons.help, 'FAQ', false, onTap: () {
            print("❓ Navigating to FAQ!");
            Navigator.pushNamed(context, '/faq');
          }),
          _buildDrawerItem(Icons.support, 'Help Center', false, onTap: () {
            print("🆘 Navigating to Help Center!");
            Navigator.pushNamed(context, '/help');
          }),
          _buildDrawerItem(Icons.description, 'Terms of Use', false, onTap: () {
            print("📜 Navigating to Terms of Use!");
            Navigator.pushNamed(context, '/terms');
          }),
          _buildDrawerItem(Icons.privacy_tip, 'Privacy', false, onTap: () {
            print("🔒 Navigating to Privacy!");
            Navigator.pushNamed(context, '/privacy');
          }),
        ],
      ),
    );
  }

  /// 🎨 Drawer item builder for sidebar navigation
  Widget _buildDrawerItem(IconData icon, String title, bool isSelected,
      {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.grey,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.grey.withOpacity(0.1),
      onTap: onTap,
    );
  }

  /// 🎯 Header with back button and title
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(28.0),
      child: Row(
        children: [
          // 🔙 Back button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              print("🔙 User going back - Exiting stage left!");
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 16),
          // 🎬 Search title
          const Text(
            'Search',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔍 Search bar section
  Widget _buildSearchSection(SearchViewModel searchViewModel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search movies, TV shows...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    print("🧽 User cleared search - Fresh start!");
                    _searchController.clear();
                    searchViewModel.updateQuery('');
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white, width: 1),
          ),
        ),
        onChanged: (query) {
          print("🎯 Query updated: '$query' - Let’s hunt for treasures!");
          searchViewModel.updateQuery(query);
        },
      ),
    );
  }

  /// 🏷️ Category selection section
  Widget _buildCategorySection(
      SearchState searchState, SearchViewModel searchViewModel) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = searchState.selectedCategory == category;

          print("🎪 Building category chip: $category (Selected: $isSelected)");

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(
                category.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  print("🎯 Category selected: $category - Switching focus!");
                  searchViewModel.updateCategory(category);
                }
              },
              backgroundColor: const Color(0xFF2A2A2A),
              selectedColor: Colors.white,
              checkmarkColor: Colors.black,
              side: BorderSide(
                color: isSelected ? Colors.white : Colors.grey[600]!,
              ),
            ),
          );
        },
      ),
    );
  }

  /// 🎭 Results or recommended content area
  Widget _buildResultsArea(SearchState searchState) {
    if (searchState.isLoading) {
      print("⏳ Showing loading spinner - The search is on!");
      return const Center(
        child: CircularProgressIndicator(color: Colors.red),
      );
    }

    if (searchState.error != null) {
      print("🚨 Showing error: ${searchState.error}");
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              searchState.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (searchState.currentQuery.isEmpty) {
      print("💭 No query - Showing recommended content!");
      return _buildRecommendedContent();
    }

    return _buildSearchResults(searchState);
  }

  /// 🔍 Search results based on category
  Widget _buildSearchResults(SearchState searchState) {
    print("🎬 Building results for category: ${searchState.selectedCategory}");

    List<SearchResult> results;
    switch (searchState.selectedCategory) {
      case 'multi':
        results = searchState.multiResults;
        print("🎪 Showing ${results.length} multi results!");
        break;
      case 'movie':
        results = searchState.movieResults;
        print("🎬 Showing ${results.length} movie results!");
        break;
      case 'tv':
        results = searchState.tvResults;
        print("📺 Showing ${results.length} TV results!");
        break;
      default:
        results = [];
        print("❓ Unknown category - Empty results!");
    }

    if (results.isEmpty) {
      print("😢 No results found - The search continues!");
      return Center(
        child: Text(
          'No results found',
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(28.0),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        print(
            "🎬 Displaying result #${index + 1}: ${result.title} (${result.mediaType})");

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: result.posterPath != null
                  ? CachedNetworkImage(
                      imageUrl:
                          'https://image.tmdb.org/t/p/w92${result.posterPath}',
                      width: 60,
                      height: 190,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 60,
                        height: 190,
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.red),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 60,
                        height: 90,
                        color: Colors.grey[800],
                        child: const Icon(Icons.movie, color: Colors.grey),
                      ),
                    )
                  : Container(
                      width: 60,
                      height: 90,
                      color: Colors.grey[800],
                      child: const Icon(Icons.movie, color: Colors.grey),
                    ),
            ),
            title: Text(
              result.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Type: ${result.mediaType.toUpperCase()}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                if (result.releaseDate != null &&
                    result.releaseDate!.isNotEmpty)
                  Text(
                    'Release: ${result.releaseDate}',
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                const SizedBox(height: 4),
                Text(
                  result.overview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[300], fontSize: 14),
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.black, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    result.voteAverage.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            onTap: () {
              print("👆 Tapped on ${result.title} - Navigating to details!");
              widget.isMobile
                  ? Get.to(() => ShowScreen(
                        showId: result.id,
                        isMovie: result.mediaType == 'movie',
                      ))
                  : result.mediaType == 'movie'
                      ? Get.to(
                          () => MovieDetailPage(movieId: result.id),
                        )
                      : Get.to(
                          () => TvShowDetailPage(showId: result.id),
                        );
            },
          ),
        );
      },
    );
  }

  /// 🌟 Recommended content when no query is entered
  Widget _buildRecommendedContent() {
    print("🌟 Building recommended content - The best of movies and TV!");

    return Consumer(
      builder: (context, ref, child) {
        final moviesAsync = ref.watch(popularMoviesProvider(1));
        final tvShowsAsync = ref.watch(popularTVShowsProvider);

        if (moviesAsync.isLoading || tvShowsAsync.isLoading) {
          print("⏳ Loading recommended content...");
          return const Center(
              child: CircularProgressIndicator(color: Colors.red));
        }

        if (moviesAsync.hasError || tvShowsAsync.hasError) {
          print("🚨 Error loading recommended content!");
          return const Center(
            child: Text(
              'Failed to load recommended content',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final movies = moviesAsync.value ?? [];
        final tvShows = tvShowsAsync.value ?? [];
        final recommended = [
          ...movies.map((movie) => SearchResult(
                id: movie.id,
                title: movie.title,
                posterPath: movie.posterPath,
                backdropPath: movie.backdropPath,
                overview: movie.overview,
                voteAverage: movie.voteAverage,
                voteCount: movie.voteCount,
                mediaType: 'movie',
                releaseDate: movie.releaseDate,
                popularity: movie.popularity,
              )),
          ...tvShows.map((show) => SearchResult(
                id: show.id,
                title: show.name,
                posterPath: show.thumbnail,
                backdropPath: show.backdropPath,
                overview: show.overview,
                voteAverage: show.voteAverage,
                voteCount: show.voteCount,
                mediaType: 'tv',
                releaseDate: show.firstAirDate,
                popularity: show.popularity,
              )),
        ];

        if (recommended.isEmpty) {
          print("😢 No recommended content available!");
          return const Center(
            child: Text(
              'No recommended content available',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        print("🌟 Showing ${recommended.length} recommended items!");

        return ListView.builder(
          padding: const EdgeInsets.all(28.0),
          itemCount: recommended.length,
          itemBuilder: (context, index) {
            final result = recommended[index];
            print(
                "🌟 Displaying recommended #${index + 1}: ${result.title} (${result.mediaType})");

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: result.posterPath != null
                      ? CachedNetworkImage(
                          imageUrl:
                              'https://image.tmdb.org/t/p/w92${result.posterPath}',
                          width: 60,
                          height: 90,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 60,
                            height: 90,
                            color: Colors.grey[300],
                            child: const Center(
                              child:
                                  CircularProgressIndicator(color: Colors.red),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 60,
                            height: 90,
                            color: Colors.grey[800],
                            child: const Icon(Icons.movie, color: Colors.grey),
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 90,
                          color: Colors.grey[800],
                          child: const Icon(Icons.movie, color: Colors.grey),
                        ),
                ),
                title: Text(
                  result.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'Type: ${result.mediaType.toUpperCase()}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    if (result.releaseDate != null &&
                        result.releaseDate!.isNotEmpty)
                      Text(
                        'Release: ${result.releaseDate}',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      result.overview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[300], fontSize: 14),
                    ),
                  ],
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.black, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        result.voteAverage.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  print(
                      "👆 Tapped on recommended ${result.title} - To details!");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShowScreen(
                        showId: result.id,
                        isMovie: result.mediaType == 'movie',
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
