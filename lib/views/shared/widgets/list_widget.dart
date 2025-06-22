import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../components/display_screen.dart';

class HorizontalScrollClips extends StatefulWidget {
  final Future<List<dynamic>> Function() fetchData;
  final double height;

  const HorizontalScrollClips({
    super.key,
    required this.fetchData,
    required this.height,
  });

  @override
  // ignore: library_private_types_in_public_api
  _HorizontalScrollClipsState createState() => _HorizontalScrollClipsState();
}

class _HorizontalScrollClipsState extends State<HorizontalScrollClips> {
  List<dynamic> mediaList = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchMedia();
  }

  Future<void> fetchMedia() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final media = await widget.fetchData();
      setState(() {
        mediaList = media;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.red,
          ),
        ),
      );
    }

    if (hasError) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Failed to load content',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: fetchMedia,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (mediaList.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: Text(
            'No media available.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    const imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

    return SizedBox(
      height: widget.height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: mediaList.length,
        itemBuilder: (context, index) {
          final media = mediaList[index];
          final imageUrl = '$imageBaseUrl${media['poster_path'] ?? ''}';

          return GestureDetector(
            onTap: () {
              final int showId = media['id'] ?? 0;
              final bool isMovie = media.containsKey('title');

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: 100,
                  placeholder: (context, url) => Container(
                    width: 100,
                    color: Colors.grey[800], // Placeholder background color
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: Colors.red), // Loading indicator
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 100,
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
