import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/movie_model.dart';
import '../models/search_models.dart';
import '../providers/movie_provider.dart';

class MoviesApiService {
  final String tmdbApiKey = '4d4b181b17cf73be77a0fae24ce17cb4';
  final String baseUrl = 'https://api.themoviedb.org/3';

  // 🎬 Fetch popular movies
  Future<List<dynamic>> fetchPopularMovies() async {
    print('📡 Fetching popular movies...');
    final url = Uri.parse(
        '$baseUrl/movie/popular?api_key=$tmdbApiKey&language=en-US&page=1');
    return _fetchData(url);
  }

  // 🎬 Fetch popular movies with pagination
  Future<List<dynamic>> fetchPopularMoviesList({int page = 1}) async {
    print('📡 Fetching popular movies list, Page $page...');
    final url = Uri.parse(
        '$baseUrl/movie/popular?api_key=$tmdbApiKey&language=en-US&page=$page');
    return _fetchData(url);
  }

  // 🆕 Fetch trending movies (latest)
  Future<List<dynamic>> fetchLatestMovies() async {
    print('⚡ Fetching trending (latest) movies...');
    final url = Uri.parse(
        '$baseUrl/trending/movie/day?api_key=$tmdbApiKey&language=en-US&page=1');
    return _fetchData(url);
  }

  // 🆕 Fetch top-rated movies with pagination
  Future<List<dynamic>> fetchLatestMoviesList({int page = 1}) async {
    print('🎞️ Fetching top-rated movies, Page $page...');
    final url = Uri.parse(
        '$baseUrl/movie/top_rated?api_key=$tmdbApiKey&language=en-US&page=$page');
    return _fetchData(url);
  }

  Future<MovieDetail> fetchMovieDetail(int movieId) async {
    final url =
        Uri.parse('$baseUrl/movie/$movieId?api_key=$tmdbApiKey&language=en-US');

    print("🔍 Fetching details for movie ID: $movieId");

    try {
      final response = await http.get(url);
      print("📡 Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print(
            "✅ Successfully fetched movie detail: ${jsonData['title'] ?? 'Unknown Title'}");
        return MovieDetail.fromJson(jsonData);
      } else {
        print("❌ Failed to fetch movie detail. Status: ${response.statusCode}");
        throw Exception(
            'Failed to load movie details (status ${response.statusCode})');
      }
    } catch (e) {
      print("💥 Exception while fetching movie detail: $e");
      rethrow;
    }
  }

  final movieServiceProvider = Provider<MovieService>((ref) {
    print("🎥 movieServiceProvider initialized");
    return MovieService();
  });

  /// 🌟 Grabs a list of the most popular movies from TMDb.
  /// Returns a list of MovieDetail objects. Supports pagination.
  // Future<List<MovieDetail>> fetchPopularMovies({int page = 1}) async {
  //   final url = Uri.parse(
  //       '$_baseUrl/movie/popular?api_key=$_apiKey&language=en-US&page=$page');

  //   print("🚀 Fetching popular movies (Page: $page)");

  //   try {
  //     final response = await http.get(url);
  //     print("📡 Response status: ${response.statusCode}");

  //     if (response.statusCode == 200) {
  //       final jsonData = json.decode(response.body);
  //       final List results = jsonData['results'];
  //       print("🎉 Fetched ${results.length} popular movies!");
  //       return results
  //           .map((movie) => MovieDetail.fromJson(movie as Map<String, dynamic>))
  //           .toList();
  //     } else {
  //       print(
  //           "❌ Failed to load popular movies. Status: ${response.statusCode}");
  //       throw Exception(
  //           'Failed to load popular movies (status ${response.statusCode})');
  //     }
  //   } catch (e) {
  //     print("💥 Exception while fetching popular movies: $e");
  //     rethrow;
  //   }
  // }

  // 🎬 Search for Movies only
  Future<List<SearchResult>> searchMovies(String query, {int page = 1}) async {
    print('🎥 Searching MOVIES for: "$query" on page $page');
    final url = Uri.parse(
        '$baseUrl/search/movie?api_key=$tmdbApiKey&language=en-US&query=$query&page=$page');
    final data = await _fetchData(url);
    return data
        .map<SearchResult>((json) => SearchResult.fromJson(json))
        .toList();
  }

  // 📂 Appendable data types (videos, images, credits, etc.)
  static const String _appendExtras =
      'videos,images,credits,recommendations,similar,reviews';

  /// 🎥 Fetch detailed movie info with extras
  Future<Map<String, dynamic>> fetchMovieDetails(int movieId) async {
    final url = Uri.parse(
        '$baseUrl/movie/$movieId?api_key=$tmdbApiKey&language=en-US&append_to_response=$_appendExtras');
    return _fetchSingleData(url);
  }

  /// 🎬 Now Playing Movies
  Future<List<dynamic>> fetchNowPlayingMovies({int page = 1}) async {
    final url = Uri.parse(
        '$baseUrl/movie/now_playing?api_key=$tmdbApiKey&language=en-US&page=$page');
    return _fetchData(url);
  }

  /// 🆕 Upcoming Movies
  Future<List<dynamic>> fetchUpcomingMovies({int page = 1}) async {
    final url = Uri.parse(
        '$baseUrl/movie/upcoming?api_key=$tmdbApiKey&language=en-US&page=$page');
    return _fetchData(url);
  }

  /// 🗂 Genres for Movies
  Future<List<dynamic>> fetchMovieGenres() async {
    final url = Uri.parse(
        '$baseUrl/genre/movie/list?api_key=$tmdbApiKey&language=en-US');
    final data = await _fetchSingleData(url);
    return data['genres'] ?? [];
  }

  // ℹ️ Fetch details for a specific Movie
  Future<Map<String, dynamic>> fetchShowDetails(int id) async {
    print('🔍 Fetching details for movie with ID: $id');
    final url =
        Uri.parse('$baseUrl/movie/$id?api_key=$tmdbApiKey&language=en-US');
    return _fetchSingleData(url);
  }

  /// 🔍 Search by external ID (IMDB, Facebook, Twitter)
  Future<List<dynamic>> findByExternalId(String externalId) async {
    final url = Uri.parse(
        '$baseUrl/find/$externalId?api_key=$tmdbApiKey&external_source=imdb_id');
    final data = await _fetchSingleData(url);
    return data['movie_results'] ?? [];
  }

  // 🛠️ Helper to fetch list data from TMDb
  Future<List<dynamic>> _fetchData(Uri url) async {
    print('🌐 Making GET request to: $url');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print('✅ Success! Parsing list data...');
        final data = json.decode(response.body);
        return data['results'].take(20).toList();
      } else {
        print(
            '❌ Failed to load list data. Status code: ${response.statusCode}');
        throw Exception('Failed to load data from TMDb');
      }
    } catch (e) {
      print('🚨 Error occurred: $e');
      rethrow;
    }
  }

  // 🛠️ Helper to fetch single entry (e.g., details)
  Future<Map<String, dynamic>> _fetchSingleData(Uri url) async {
    print('🌐 Making GET request for single entry to: $url');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print('✅ Success! Parsing single entry...');
        return json.decode(response.body);
      } else {
        print(
            '❌ Failed to load single data. Status code: ${response.statusCode}');
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('🚨 Error occurred: $e');
      rethrow;
    }
  }

  /// 🧭 Multi-purpose utility for debugging or dynamic endpoint exploration
  Future<dynamic> rawGet(String path, [Map<String, String>? query]) async {
    final uri = Uri.https('api.themoviedb.org', '/3/$path', {
      'api_key': tmdbApiKey,
      'language': 'en-US',
      ...?query,
    });
    return _fetchSingleData(uri);
  }
}
