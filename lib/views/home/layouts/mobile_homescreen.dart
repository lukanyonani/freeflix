import 'package:flutter/material.dart';
import 'package:freeflix/views/shared/components/display_page.dart';
import 'package:freeflix/views/search/search_page.dart';
import '../../../data/movie_api.dart';
import '../../../data/tv_show_api.dart';
import '../../shared/widgets/carousel_widget.dart';
import '../../shared/widgets/list_widget.dart';
import '../../shared/widgets/movie_widgets.dart';

class MobileHomePage extends StatefulWidget {
  final String title;
  final Map<String, dynamic> apiData;

  const MobileHomePage({super.key, required this.title, required this.apiData});

  @override
  State<MobileHomePage> createState() => _MobileHomePageState();
}

class _MobileHomePageState extends State<MobileHomePage> {
  late Future<Map<String, dynamic>> _apiDataFuture;

  @override
  void initState() {
    super.initState();
    _apiDataFuture = _fetchData();
  }

  final MoviesApiService _moviesApiService = MoviesApiService();
  final TvShowsApiService _tvApiService = TvShowsApiService();

  Future<Map<String, dynamic>> _fetchData() async {
    try {
      return {
        'latestTVShows': await _tvApiService.fetchTrendingTVShows(),
        'popularMovies': await _moviesApiService.fetchPopularMovies(),
        'latestMovies': await _moviesApiService.fetchLatestMovies(),
      };
    } catch (e) {
      //print('Error fetching data: $e');
      return {};
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _apiDataFuture = _fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final sidebarWidth = screenWidth * 0.18;
    return SafeArea(
      child: Scaffold(
        drawer: DrawerWidget(sidebarWidth: sidebarWidth),
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          centerTitle: true,
          title: Image.asset(
            'assets/images/logo.png',
            height: 25,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(true),
                  ),
                );
              },
            ),
          ],
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _apiDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Colors.red));
            } else if (snapshot.hasError || snapshot.data == null) {
              return const Center(
                  child: Text('Failed to load data',
                      style: TextStyle(color: Colors.white)));
            }

            return RefreshIndicator(
              onRefresh: _refreshData,
              color: Colors.red,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: HomeContent(apiData: snapshot.data!),
              ),
            );
          },
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  final Map<String, dynamic> apiData; // Receive API data

  const HomeContent({super.key, required this.apiData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 66),
          CarouselWidget(), // Keep existing carousel
          const SizedBox(height: 36),

          // Latest TV Shows
          TitleRow(
            title: 'Latest TV Shows',
            onViewAllPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LatestMoviesPage(
                    fetchData: TvShowsApiService().fetchTrendingTVShowsList,
                    title: 'Top Rated Shows',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          HorizontalScrollClips(
            fetchData: () async => apiData['latestTVShows'] ?? [],
            height: 150,
          ),

          // Popular Movies
          TitleRow(
            title: 'Popular Movies',
            onViewAllPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LatestMoviesPage(
                    fetchData: MoviesApiService().fetchPopularMoviesList,
                    title: 'Popular Movies',
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          HorizontalScrollClips(
            fetchData: () async => apiData['popularMovies'] ?? [],
            height: 150,
          ),

          // Latest Movies
          TitleRow(
            title: 'Latest Movies',
            onViewAllPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LatestMoviesPage(
                    fetchData: MoviesApiService().fetchLatestMoviesList,
                    title: 'Top Rated Movies',
                  ),
                ),
              );
            },
          ),
          HorizontalScrollClips(
            fetchData: () async => apiData['latestMovies'] ?? [],
            height: 150,
          ),

          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

class TitleRow extends StatelessWidget {
  final String title; // Title text
  final VoidCallback onViewAllPressed; // Action for the "view all" button
  final Color titleColor; // Optional parameter to customize title color

  const TitleRow({
    super.key,
    required this.title,
    required this.onViewAllPressed,
    this.titleColor = Colors.white, // Default title color is white
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onViewAllPressed,
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all<Color>(Colors.red),
            ),
            child: const Text(
              'View All',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
