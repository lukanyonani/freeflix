import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/search_models.dart';

class TvShowsApiService {
  final String tmdbApiKey = '4d4b181b17cf73be77a0fae24ce17cb4';
  final String baseUrl = 'https://api.themoviedb.org/3';

  // 📺 Fetch popular TV shows
  Future<List<dynamic>> fetchPopularTVShows() async {
    print('📺 Fetching popular TV shows...');
    final url = Uri.parse(
        '$baseUrl/tv/popular?api_key=$tmdbApiKey&language=en-US&page=1');
    return _fetchData(url);
  }

  // 📈 Fetch trending TV shows of the week
  Future<List<dynamic>> fetchTrendingTVShows() async {
    print('📈 Fetching trending TV shows (weekly)...');
    final url = Uri.parse(
        '$baseUrl/trending/tv/week?api_key=$tmdbApiKey&language=en-US&page=1');
    return _fetchData(url);
  }

  // 📈 Fetch top-rated TV shows
  Future<List<dynamic>> fetchTrendingTVShowsList({int page = 1}) async {
    print('🎯 Fetching top-rated TV shows, Page $page...');
    final url = Uri.parse(
        '$baseUrl/tv/top_rated?api_key=$tmdbApiKey&language=en-US&page=$page');
    return _fetchData(url);
  }

  // 📚 Fetch episodes for a specific TV show season
  Future<List<dynamic>> fetchEpisodes(int showId, int seasonNumber) async {
    print('📂 Fetching episodes for show ID: $showId, Season: $seasonNumber');
    final url = Uri.parse(
        '$baseUrl/tv/$showId/season/$seasonNumber?api_key=$tmdbApiKey&language=en-US');
    final data = await _fetchSingleData(url);
    return data['episodes'] ?? [];
  }

  // 📺 Search for TV Shows only
  Future<List<SearchResult>> searchTVShows(String query, {int page = 1}) async {
    print('📺 Searching TV SHOWS for: "$query" on page $page');
    final url = Uri.parse(
        '$baseUrl/search/tv?api_key=$tmdbApiKey&language=en-US&query=$query&page=$page');
    final data = await _fetchData(url);
    return data
        .map<SearchResult>((json) => SearchResult.fromJson(json))
        .toList();
  }

  // 📂 Appendable data types (videos, images, credits, etc.)
  static const String _appendExtras =
      'videos,images,credits,recommendations,similar,reviews';

  /// 📺 Fetch detailed TV show info with extras
  Future<Map<String, dynamic>> fetchTvDetails(int tvId) async {
    final url = Uri.parse(
        '$baseUrl/tv/$tvId?api_key=$tmdbApiKey&language=en-US&append_to_response=$_appendExtras');
    return _fetchSingleData(url);
  }

  /// 📅 TV Shows Airing Today
  Future<List<dynamic>> fetchAiringTodayTV({int page = 1}) async {
    final url = Uri.parse(
        '$baseUrl/tv/airing_today?api_key=$tmdbApiKey&language=en-US&page=$page');
    return _fetchData(url);
  }

  /// 🗂 Genres for TV Shows
  Future<List<dynamic>> fetchTvGenres() async {
    final url =
        Uri.parse('$baseUrl/genre/tv/list?api_key=$tmdbApiKey&language=en-US');
    final data = await _fetchSingleData(url);
    return data['genres'] ?? [];
  }

  /// 📺 Fetch a specific episode's details
  Future<Map<String, dynamic>> fetchEpisodeDetails(
      int showId, int season, int episode) async {
    final url = Uri.parse(
        '$baseUrl/tv/$showId/season/$season/episode/$episode?api_key=$tmdbApiKey&language=en-US');
    return _fetchSingleData(url);
  }

  // ℹ️ Fetch details for a specific TV Show
  Future<Map<String, dynamic>> fetchShowDetails(int id) async {
    print('🔍 Fetching details for TV show with ID: $id');
    final url = Uri.parse('$baseUrl/tv/$id?api_key=$tmdbApiKey&language=en-US');
    return _fetchSingleData(url);
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
