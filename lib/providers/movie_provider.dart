import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/movie_model.dart';

// 🎬 A Riverpod provider that gives us access to a shared MovieService instance
// across the app. Think of it as our backstage pass to the movie API!
final movieServiceProvider = Provider<MovieService>((ref) {
  print("🎥 movieServiceProvider initialized");
  return MovieService();
});

// 🎞️ Provider for fetching movie details by ID
final movieDetailProvider =
    FutureProvider.family<MovieDetail, int>((ref, movieId) {
  final movieService = ref.watch(movieServiceProvider);
  return movieService.fetchMovieDetail(movieId);
});

// 🍿 Provider for fetching popular movies with pagination support
final popularMoviesProvider =
    FutureProvider.family<List<MovieDetail>, int>((ref, page) {
  final movieService = ref.watch(movieServiceProvider);
  return movieService.fetchPopularMovies(page: page);
});

// 🎭 Provider for fetching movies currently in theaters
final nowPlayingMoviesProvider =
    FutureProvider.family<List<MovieDetail>, int>((ref, page) {
  final movieService = ref.watch(movieServiceProvider);
  return movieService.fetchNowPlayingMovies(page: page);
});

// ⭐ Provider for fetching top-rated movies
final topRatedMoviesProvider =
    FutureProvider.family<List<MovieDetail>, int>((ref, page) {
  final movieService = ref.watch(movieServiceProvider);
  return movieService.fetchTopRatedMovies(page: page);
});

// ⏳ Provider for fetching upcoming movies
final upcomingMoviesProvider =
    FutureProvider.family<List<MovieDetail>, int>((ref, page) {
  final movieService = ref.watch(movieServiceProvider);
  return movieService.fetchUpcomingMovies(page: page);
});

// 🔄 Provider for fetching similar movies by ID
final similarMoviesProvider =
    FutureProvider.family<List<MovieDetail>, int>((ref, movieId) {
  final movieService = ref.watch(movieServiceProvider);
  return movieService.fetchSimilarMovies(movieId);
});

// 👍 Provider for fetching recommendations by ID
final recommendedMoviesProvider =
    FutureProvider.family<List<MovieDetail>, int>((ref, movieId) {
  final movieService = ref.watch(movieServiceProvider);
  return movieService.fetchRecommendations(movieId);
});

/// 🍿 **MovieService** is where all the TMDb magic happens!
/// It fetches details, lists, and helps your app talk to the movie database like a pro!
class MovieService {
  // 🔐 TMDb API key — don't expose this in public repositories!
  final String _apiKey = '4d4b181b17cf73be77a0fae24ce17cb4';
  // 🌐 Base URL for all movie-related requests
  final String _baseUrl = 'https://api.themoviedb.org/3';
  // 🎟️ Authentication token for API requests
  final String _authToken =
      'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0ZDRiMTgxYjE3Y2Y3M2JlNzdhMGZhZTI0Y2UxN2NiNCIsIm5iZiI6MTczNzE0NTk0MS4yOTksInN1YiI6IjY3OGFiZTU1OTcyOTc0OWEyZmUxNGUyNyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.p_7CY229Zhi6Khvpi0PBXuPnU62oWtvK-6rvntbthKc';

  /// 📦 **_fetchMovieList**
  /// A generic helper to query any movie list endpoint.
  /// - [path]: Endpoint path (e.g., '/movie/popular').
  /// - [params]: Query parameters to tailor your request.
  /// Prints every request detail and response snippet for debugging.
  Future<List<MovieDetail>> _fetchMovieList(
      String path, Map<String, dynamic> params) async {
    final query = {'api_key': _apiKey, ...params};
    final uri = Uri.parse('$_baseUrl$path')
        .replace(queryParameters: query.map((k, v) => MapEntry(k, '$v')));

    print('--- TMDb Request Start ---');
    print('Endpoint: $path');
    print('URI: $uri');
    print('Headers: $_authToken');
    print('Params: $query');

    final response = await http.get(uri, headers: {
      'accept': 'application/json',
      'Authorization': _authToken,
    });

    print('--- TMDb Response ---');
    print('Status: ${response.statusCode}');
    final preview = response.body.length > 200
        ? response.body.substring(0, 200) + '...'
        : response.body;
    print('Body Preview: $preview');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      print('Success: Retrieved ${results.length} items');
      print('--- TMDb Request End (Success) ---');
      return results
          .map((m) => MovieDetail.fromJson(m as Map<String, dynamic>))
          .toList();
    } else {
      print('Error: ${response.statusCode} - ${response.reasonPhrase}');
      print('--- TMDb Request End (Error) ---');
      throw Exception('TMDb request failed: ${response.statusCode}');
    }
  }

  /// 📽 **fetchMovieDetail**
  Future<MovieDetail> fetchMovieDetail(int movieId) async {
    final uri = Uri.parse('$_baseUrl/movie/$movieId')
        .replace(queryParameters: {'api_key': _apiKey, 'language': 'en-US'});
    print('--- Detail Request Start --- Movie ID: $movieId');
    print('URI: $uri');

    final response = await http.get(uri);
    print('Status: ${response.statusCode}');
    final preview = response.body.length > 200
        ? response.body.substring(0, 200) + '...'
        : response.body;
    print('Preview: $preview');

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print('Success: ${jsonData['title'] ?? 'Unknown'}');
      return MovieDetail.fromJson(jsonData);
    } else {
      print('Error fetching detail: ${response.statusCode}');
      throw Exception('Detail fetch failed');
    }
  }

  /// 🌟 **fetchPopularMovies**
  Future<List<MovieDetail>> fetchPopularMovies({int page = 1}) async {
    return _fetchMovieList(
        '/movie/popular', {'language': 'en-US', 'page': page});
  }

  /// 🎭 **fetchNowPlayingMovies**
  Future<List<MovieDetail>> fetchNowPlayingMovies({int page = 1}) async {
    return _fetchMovieList(
        '/movie/now_playing', {'language': 'en-US', 'page': page});
  }

  /// ⭐ **fetchTopRatedMovies**
  Future<List<MovieDetail>> fetchTopRatedMovies({int page = 1}) async {
    return _fetchMovieList(
        '/movie/top_rated', {'language': 'en-US', 'page': page});
  }

  /// ⏳ **fetchUpcomingMovies**
  Future<List<MovieDetail>> fetchUpcomingMovies({int page = 1}) async {
    return _fetchMovieList(
        '/movie/upcoming', {'language': 'en-US', 'page': page});
  }

  /// 🔄 **fetchSimilarMovies**
  Future<List<MovieDetail>> fetchSimilarMovies(int movieId,
      {int page = 1}) async {
    return _fetchMovieList(
        '/movie/$movieId/similar', {'language': 'en-US', 'page': page});
  }

  /// 👍 **fetchRecommendations**
  Future<List<MovieDetail>> fetchRecommendations(int movieId,
      {int page = 1}) async {
    return _fetchMovieList(
        '/movie/$movieId/recommendations', {'language': 'en-US', 'page': page});
  }

  /// 🔍 **searchMovies**
  Future<List<MovieDetail>> searchMovies(String queryText,
      {int page = 1, bool includeAdult = false}) async {
    return _fetchMovieList('/search/movie', {
      'query': queryText,
      'page': page,
      'include_adult': includeAdult,
    });
  }

  /// 🌐 **discoverMovies**
  Future<List<MovieDetail>> discoverMovies({
    int page = 1,
    String sortBy = 'popularity.desc',
    bool includeAdult = false,
    bool includeVideo = false,
    String? minDate,
    String? maxDate,
    List<int>? withReleaseTypes,
    List<int>? withGenres,
    String? region,
    int? year,
    double? voteAverageGte,
    int? runtimeLte,
  }) async {
    final params = <String, dynamic>{
      'language': 'en-US',
      'page': page,
      'sort_by': sortBy,
      'include_adult': includeAdult,
      'include_video': includeVideo,
    };
    if (minDate != null) params['release_date.gte'] = minDate;
    if (maxDate != null) params['release_date.lte'] = maxDate;
    if (withReleaseTypes != null)
      params['with_release_type'] = withReleaseTypes.join('|');
    if (withGenres != null) params['with_genres'] = withGenres.join(',');
    if (region != null) params['region'] = region;
    if (year != null) params['year'] = year;
    if (voteAverageGte != null) params['vote_average.gte'] = voteAverageGte;
    if (runtimeLte != null) params['with_runtime.lte'] = runtimeLte;

    return _fetchMovieList('/discover/movie', params);
  }
}
