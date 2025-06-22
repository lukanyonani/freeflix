import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'display_screen.dart';

class LatestMoviesPage extends StatefulWidget {
  final Future<List<dynamic>> Function({int page}) fetchData;
  final String title;

  const LatestMoviesPage(
      {super.key, required this.fetchData, required this.title});

  @override
  // ignore: library_private_types_in_public_api
  _LatestMoviesPageState createState() => _LatestMoviesPageState();
}

class _LatestMoviesPageState extends State<LatestMoviesPage> {
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> movies = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    fetchMovies();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchMovies() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    try {
      final newMovies = await widget.fetchData(page: currentPage);

      setState(() {
        if (newMovies.isNotEmpty) {
          movies.addAll(newMovies);
          currentPage++;
        } else {
          hasMore = false;
        }
      });
    } catch (e) {
      //print('Error fetching movies: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      fetchMovies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 2 / 3,
              ),
              itemCount: movies.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == movies.length) {
                  return Center(
                      child: CircularProgressIndicator(color: Colors.red));
                }

                final movie = movies[index];
                final imageUrl =
                    'https://image.tmdb.org/t/p/w500${movie['poster_path']}';

                return GestureDetector(
                  onTap: () {
                    final int showId = movie['id'] ?? 0;
                    final bool isMovie = movie.containsKey('title');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ShowScreen(
                          showId: showId,
                          isMovie: isMovie,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.red),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Text(
                          'Image not available',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
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
