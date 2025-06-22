import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/search_models.dart';

class AnimeApiService {
  final String tmdbApiKey = '4d4b181b17cf73be77a0fae24ce17cb4';
  final String baseUrl = 'https://api.themoviedb.org/3';

  // 🎌 Animation genre ID for filtering anime content
  static const int animationGenreId = 16;

  // 🎬 Fetch popular anime movies
  Future<List<dynamic>> fetchPopularMovies() async {
    print('📡 Fetching popular anime movies...');
    final url = Uri.parse(
        '$baseUrl/movie/popular?api_key=$tmdbApiKey&language=en-US&page=1&with_genres=$animationGenreId');
    return _fetchData(url);
  }

  // 🎬 Fetch popular anime movies with pagination
  Future<List<dynamic>> fetchPopularMoviesList({int page = 1}) async {
    print('📡 Fetching popular anime movies list, Page $page...');
    final url = Uri.parse(
        '$baseUrl/movie/popular?api_key=$tmdbApiKey&language=en-US&page=$page&with_genres=$animationGenreId');
    return _fetchData(url);
  }

  // 🆕 Fetch trending anime movies (latest)
  Future<List<dynamic>> fetchLatestMovies() async {
    print('⚡ Fetching trending (latest) anime movies...');
    final url = Uri.parse(
        '$baseUrl/trending/movie/day?api_key=$tmdbApiKey&language=en-US&page=1');
    final data = await _fetchData(url);
    // Filter for animation genre since trending doesn't support genre filtering
    return _filterByGenre(data, animationGenreId);
  }

  // 🆕 Fetch top-rated anime movies with pagination
  Future<List<dynamic>> fetchLatestMoviesList({int page = 1}) async {
    print('🎞️ Fetching top-rated anime movies, Page $page...');
    final url = Uri.parse(
        '$baseUrl/movie/top_rated?api_key=$tmdbApiKey&language=en-US&page=$page&with_genres=$animationGenreId');
    return _fetchData(url);
  }

  // 📺 Fetch popular anime TV shows
  Future<List<dynamic>> fetchPopularTVShows() async {
    print('📺 Fetching popular anime TV shows...');
    final url = Uri.parse(
        '$baseUrl/tv/popular?api_key=$tmdbApiKey&language=en-US&page=1&with_genres=$animationGenreId');
    return _fetchData(url);
  }

  // 📈 Fetch trending anime TV shows of the week
  Future<List<dynamic>> fetchTrendingTVShows() async {
    print('📈 Fetching trending anime TV shows (weekly)...');
    final url = Uri.parse(
        '$baseUrl/trending/tv/week?api_key=$tmdbApiKey&language=en-US&page=1');
    final data = await _fetchData(url);
    // Filter for animation genre since trending doesn't support genre filtering
    return _filterByGenre(data, animationGenreId);
  }

  // 📈 Fetch top-rated anime TV shows
  Future<List<dynamic>> fetchTrendingTVShowsList({int page = 1}) async {
    print('🎯 Fetching top-rated anime TV shows, Page $page...');
    final url = Uri.parse(
        '$baseUrl/tv/top_rated?api_key=$tmdbApiKey&language=en-US&page=$page&with_genres=$animationGenreId');
    return _fetchData(url);
  }

  // ℹ️ Fetch details for a specific Anime Movie or TV Show
  Future<Map<String, dynamic>> fetchShowDetails(int id, bool isMovie) async {
    final type = isMovie ? 'movie' : 'tv';
    print('🔍 Fetching details for anime $type with ID: $id');
    final url =
        Uri.parse('$baseUrl/$type/$id?api_key=$tmdbApiKey&language=en-US');
    return _fetchSingleData(url);
  }

  // 📚 Fetch episodes for a specific anime TV show season
  Future<List<dynamic>> fetchEpisodes(int showId, int seasonNumber) async {
    print(
        '📂 Fetching episodes for anime show ID: $showId, Season: $seasonNumber');
    final url = Uri.parse(
        '$baseUrl/tv/$showId/season/$seasonNumber?api_key=$tmdbApiKey&language=en-US');
    final data = await _fetchSingleData(url);
    return data['episodes'] ?? [];
  }

  // 🔎 Search for Anime Movies/TV Shows/People
  Future<List<dynamic>> search(String query) async {
    print('🔎 Searching TMDb for anime: "$query"...');
    final url = Uri.parse(
        '$baseUrl/search/multi?api_key=$tmdbApiKey&language=en-US&query=$query&page=1');
    final data = await _fetchData(url);
    // Filter results to only include animation content
    return data.where((item) {
      final genreIds = item['genre_ids'] as List<dynamic>?;
      return genreIds?.contains(animationGenreId) ?? false;
    }).toList();
  }

  // 🛠️ Helper to filter results by genre
  List<dynamic> _filterByGenre(List<dynamic> data, int genreId) {
    return data.where((item) {
      final genreIds = item['genre_ids'] as List<dynamic>?;
      return genreIds?.contains(genreId) ?? false;
    }).toList();
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

  // 🌍 Search across all anime categories
  Future<List<SearchResult>> searchMulti(String query, {int page = 1}) async {
    print('🔍 Searching MULTI for anime: "$query" on page $page');
    final url = Uri.parse(
        '$baseUrl/search/multi?api_key=$tmdbApiKey&language=en-US&query=$query&page=$page');
    final data = await _fetchData(url);
    final filteredData = _filterByGenre(data, animationGenreId);
    return filteredData
        .map<SearchResult>((json) => SearchResult.fromJson(json))
        .toList();
  }

  // 🎬 Search for Anime Movies only
  Future<List<SearchResult>> searchMovies(String query, {int page = 1}) async {
    print('🎥 Searching ANIME MOVIES for: "$query" on page $page');
    final url = Uri.parse(
        '$baseUrl/search/movie?api_key=$tmdbApiKey&language=en-US&query=$query&page=$page');
    final data = await _fetchData(url);
    final filteredData = _filterByGenre(data, animationGenreId);
    return filteredData
        .map<SearchResult>((json) => SearchResult.fromJson(json))
        .toList();
  }

  // 📺 Search for Anime TV Shows only
  Future<List<SearchResult>> searchTVShows(String query, {int page = 1}) async {
    print('📺 Searching ANIME TV SHOWS for: "$query" on page $page');
    final url = Uri.parse(
        '$baseUrl/search/tv?api_key=$tmdbApiKey&language=en-US&query=$query&page=$page');
    final data = await _fetchData(url);
    final filteredData = _filterByGenre(data, animationGenreId);
    return filteredData
        .map<SearchResult>((json) => SearchResult.fromJson(json))
        .toList();
  }

  // 🧑‍🤝‍🧑 Search for People (anime-related)
  Future<List<Person>> searchPeople(String query, {int page = 1}) async {
    print('🧑 Searching PEOPLE for: "$query" on page $page');
    final url = Uri.parse(
        '$baseUrl/search/person?api_key=$tmdbApiKey&language=en-US&query=$query&page=$page');
    final data = await _fetchData(url);
    return data.map<Person>((json) => Person.fromJson(json)).toList();
  }

  // 🏢 Search for Companies (anime studios)
  Future<List<Company>> searchCompanies(String query, {int page = 1}) async {
    print('🏢 Searching ANIME STUDIOS for: "$query" on page $page');
    final url = Uri.parse(
        '$baseUrl/search/company?api_key=$tmdbApiKey&query=$query&page=$page');
    final data = await _fetchData(url);
    return data.map<Company>((json) => Company.fromJson(json)).toList();
  }

  // 📦 Search for Collections (anime collections)
  Future<List<Collection>> searchCollections(String query,
      {int page = 1}) async {
    print('📦 Searching ANIME COLLECTIONS for: "$query" on page $page');
    final url = Uri.parse(
        '$baseUrl/search/collection?api_key=$tmdbApiKey&language=en-US&query=$query&page=$page');
    final data = await _fetchData(url);
    return data.map<Collection>((json) => Collection.fromJson(json)).toList();
  }

  // 🔑 Search for Keywords
  Future<List<Keyword>> searchKeywords(String query, {int page = 1}) async {
    print('🔑 Searching KEYWORDS for: "$query" on page $page');
    final url = Uri.parse(
        '$baseUrl/search/keyword?api_key=$tmdbApiKey&query=$query&page=$page');
    final data = await _fetchData(url);
    return data.map<Keyword>((json) => Keyword.fromJson(json)).toList();
  }

  // 📂 Appendable data types (videos, images, credits, etc.)
  static const String _appendExtras =
      'videos,images,credits,recommendations,similar,reviews';

  /// 🎥 Fetch detailed anime movie info with extras
  Future<Map<String, dynamic>> fetchMovieDetails(int movieId) async {
    final url = Uri.parse(
        '$baseUrl/movie/$movieId?api_key=$tmdbApiKey&language=en-US&append_to_response=$_appendExtras');
    return _fetchSingleData(url);
  }

  /// 📺 Fetch detailed anime TV show info with extras
  Future<Map<String, dynamic>> fetchTvDetails(int tvId) async {
    final url = Uri.parse(
        '$baseUrl/tv/$tvId?api_key=$tmdbApiKey&language=en-US&append_to_response=$_appendExtras');
    return _fetchSingleData(url);
  }

  /// 🎭 Fetch full details of a person
  Future<Map<String, dynamic>> fetchPersonDetails(int personId) async {
    final url = Uri.parse(
        '$baseUrl/person/$personId?api_key=$tmdbApiKey&language=en-US');
    return _fetchSingleData(url);
  }

  /// 🎞️ Fetch combined movie + TV credits for a person
  Future<List<dynamic>> fetchPersonCombinedCredits(int personId) async {
    final url = Uri.parse(
        '$baseUrl/person/$personId/combined_credits?api_key=$tmdbApiKey&language=en-US');
    final data = await _fetchSingleData(url);
    return data['cast'] ?? [];
  }

  /// 🎬 Now Playing Anime Movies
  Future<List<dynamic>> fetchNowPlayingMovies({int page = 1}) async {
    final url = Uri.parse(
        '$baseUrl/movie/now_playing?api_key=$tmdbApiKey&language=en-US&page=$page&with_genres=$animationGenreId');
    return _fetchData(url);
  }

  /// 🆕 Upcoming Anime Movies
  Future<List<dynamic>> fetchUpcomingMovies({int page = 1}) async {
    final url = Uri.parse(
        '$baseUrl/movie/upcoming?api_key=$tmdbApiKey&language=en-US&page=$page&with_genres=$animationGenreId');
    return _fetchData(url);
  }

  /// 📅 Anime TV Shows Airing Today
  Future<List<dynamic>> fetchAiringTodayTV({int page = 1}) async {
    final url = Uri.parse(
        '$baseUrl/tv/airing_today?api_key=$tmdbApiKey&language=en-US&page=$page&with_genres=$animationGenreId');
    return _fetchData(url);
  }

  /// 🗂 Genres for Movies (filter to show animation)
  Future<List<dynamic>> fetchMovieGenres() async {
    final url = Uri.parse(
        '$baseUrl/genre/movie/list?api_key=$tmdbApiKey&language=en-US');
    final data = await _fetchSingleData(url);
    final genres = data['genres'] ?? [];
    // Return only animation genre or all genres depending on your needs
    return genres.where((genre) => genre['id'] == animationGenreId).toList();
  }

  /// 🗂 Genres for TV Shows (filter to show animation)
  Future<List<dynamic>> fetchTvGenres() async {
    final url =
        Uri.parse('$baseUrl/genre/tv/list?api_key=$tmdbApiKey&language=en-US');
    final data = await _fetchSingleData(url);
    final genres = data['genres'] ?? [];
    // Return only animation genre or all genres depending on your needs
    return genres.where((genre) => genre['id'] == animationGenreId).toList();
  }

  /// ⚙️ Get TMDb configuration (for image URLs, sizes, etc.)
  Future<Map<String, dynamic>> fetchConfiguration() async {
    final url = Uri.parse('$baseUrl/configuration?api_key=$tmdbApiKey');
    return _fetchSingleData(url);
  }

  /// 📺 Fetch a specific anime episode's details
  Future<Map<String, dynamic>> fetchEpisodeDetails(
      int showId, int season, int episode) async {
    final url = Uri.parse(
        '$baseUrl/tv/$showId/season/$season/episode/$episode?api_key=$tmdbApiKey&language=en-US');
    return _fetchSingleData(url);
  }

  /// 📈 Trending All Anime (day/week)
  Future<List<dynamic>> fetchTrendingAll({String timeWindow = 'day'}) async {
    final url = Uri.parse(
        '$baseUrl/trending/all/$timeWindow?api_key=$tmdbApiKey&language=en-US');
    final data = await _fetchData(url);
    return _filterByGenre(data, animationGenreId);
  }

  /// 🔍 Search by external ID (IMDB, Facebook, Twitter)
  Future<List<dynamic>> findByExternalId(String externalId) async {
    final url = Uri.parse(
        '$baseUrl/find/$externalId?api_key=$tmdbApiKey&external_source=imdb_id');
    final data = await _fetchSingleData(url);
    final movies = data['movie_results'] ?? [];
    return _filterByGenre(movies, animationGenreId);
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
