import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../data/movie_api.dart';
import '../data/tv_show_api.dart';
import 'home/home_screen.dart';
import 'home/layouts/mobile_homescreen.dart'; // Import home page

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final MoviesApiService _apiService = MoviesApiService();
  final TvShowsApiService _tvApiService = TvShowsApiService();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  late Future<Map<String, dynamic>> _apiData;

  @override
  void initState() {
    super.initState();
    _apiData = _fetchAllData();
  }

  // Fetch all necessary data
  Future<Map<String, dynamic>> _fetchAllData() async {
    try {
      final popularMovies = await _apiService.fetchPopularMovies();
      final latestMovies = await _apiService.fetchLatestMovies();
      final popularTVShows = await _tvApiService.fetchPopularTVShows();
      final latestTVShows = await _tvApiService.fetchTrendingTVShows();

      return {
        'popularMovies': popularMovies,
        'latestMovies': latestMovies,
        'popularTVShows': popularTVShows,
        'latestTVShows': latestTVShows,
      };
    } catch (e) {
      return {}; // Return empty data in case of an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _apiData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator
            return Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 180,
                height: 180,
              ),
            );
          } else if (snapshot.hasError || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Failed to load data. Please try again.',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            // Navigate to HomePage once data is loaded
            Timer(const Duration(seconds: 3), () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                    //title: 'Free Flix',
                    apiData: snapshot.data!, // Pass fetched API data
                  ),
                ),
              );
            });

            return Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 180,
                height: 180,
              ),
            );
          }
        },
      ),
    );
  }
}
