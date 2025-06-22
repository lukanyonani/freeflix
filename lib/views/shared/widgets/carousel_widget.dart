import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../data/movie_api.dart';
import '../components/display_screen.dart';

class CarouselWidget extends StatefulWidget {
  const CarouselWidget({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CarouselWidgetState createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  final MoviesApiService apiService = MoviesApiService();
  List<dynamic> popularTVShows = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPopularShows();
  }

  Future<void> fetchPopularShows() async {
    try {
      final shows = await apiService.fetchPopularMovies();
      setState(() {
        popularTVShows = shows;
        isLoading = false;
      });
    } catch (e) {
      // Handle error (e.g., show a snackbar or placeholder image)
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 150,
        width: 150,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.red,
          ),
        ),
      );
    }

    if (popularTVShows.isEmpty) {
      return const Center(child: Text('No TV shows available.'));
    }

    return SizedBox(
      width: double.infinity,
      child: StatefulBuilder(builder: (context, setState) {
        return CarouselSlider.builder(
          itemCount: popularTVShows.length,
          options: CarouselOptions(
            height: 320,
            autoPlay: true,
            viewportFraction: 0.50,
            enlargeCenterPage: true,
            pageSnapping: true,
            autoPlayCurve: Curves.fastEaseInToSlowEaseOut,
            autoPlayAnimationDuration: const Duration(seconds: 2),
          ),
          itemBuilder: (context, itemIndex, pageViewIndex) {
            final show = popularTVShows[itemIndex];
            final imageUrl =
                'https://image.tmdb.org/t/p/w500${show['poster_path']}';
            //final title = show['name'] ?? 'No Title';

            return InkWell(
              onTap: () {
                final int showId = show['id'] ?? 0;
                final bool isMovie = show.containsKey('title');

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
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorWidget: (context, url, error) => const Center(
                        child: Text(
                          'Image not available',
                          style: TextStyle(
                              color:
                                  Colors.white), // Optional: Adjust text color
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
