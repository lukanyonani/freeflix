import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// A single media item returned by the "latest" list endpoints.
class MediaItem {
  final String imdbId;
  final int tmdbId;
  final String title;
  final String embedUrl;
  final String embedUrlTmdb;
  final String quality;

  MediaItem({
    required this.imdbId,
    required this.tmdbId,
    required this.title,
    required this.embedUrl,
    required this.embedUrlTmdb,
    required this.quality,
  });

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      imdbId: json['imdb_id'] as String,
      tmdbId: int.tryParse(json['tmdb_id'].toString()) ?? 0,
      title: json['title'] as String,
      embedUrl: json['embed_url'] as String,
      embedUrlTmdb: json['embed_url_tmdb'] as String,
      quality: json['quality'] as String,
    );
  }
}

/// Holds a paginated list plus total pages.
class PagedResponse<T> {
  final List<T> items;
  final int pages;

  PagedResponse({required this.items, required this.pages});
}

/// Client for the VidSrc API (embed & JSON list endpoints).
class VidsrcApiClient {
  final String embedDomain;
  final String apiDomain;
  final http.Client httpClient;

  VidsrcApiClient({
    http.Client? httpClient,
    String? embedDomain,
    String? apiDomain,
  })  : httpClient = httpClient ?? http.Client(),
        embedDomain = embedDomain ?? 'https://vidsrc.xyz',
        apiDomain = apiDomain ?? 'https://vidsrc.xyz';

  //――――――――――――――――――――――――――――――――――――――――――――
  // Embed URL constructors (no network call)
  //――――――――――――――――――――――――――――――――――――――――――――

  /// Build a movie-embed URI by IMDb ID:
  Uri movieEmbedByImdb(String imdb,
    {String? subUrl, String? dsLang}) {
    final params = <String,String>{ 'imdb': imdb };
    if (dsLang  != null) params['ds_lang'] = dsLang;
    if (subUrl != null) params['sub_url']  = Uri.encodeComponent(subUrl);
    return Uri.parse('$embedDomain/embed/movie').replace(queryParameters: params);
  }

  /// Build a movie-embed URI by TMDb ID:
  Uri movieEmbedByTmdb(int tmdb,
    {String? subUrl, String? dsLang}) {
    final params = <String,String>{ 'tmdb': tmdb.toString() };
    if (dsLang  != null) params['ds_lang'] = dsLang;
    if (subUrl != null) params['sub_url']  = Uri.encodeComponent(subUrl);
    return Uri.parse('$embedDomain/embed/movie').replace(queryParameters: params);
  }

  /// Build a TV-show embed URI by IMDb ID:
  Uri tvEmbedByImdb(String imdb, {String? dsLang}) {
    final params = <String,String>{ 'imdb': imdb };
    if (dsLang != null) params['ds_lang'] = dsLang;
    return Uri.parse('$embedDomain/embed/tv').replace(queryParameters: params);
  }

  /// Build a TV-show embed URI by TMDb ID:
  Uri tvEmbedByTmdb(int tmdb, {String? dsLang}) {
    final params = <String,String>{ 'tmdb': tmdb.toString() };
    if (dsLang != null) params['ds_lang'] = dsLang;
    return Uri.parse('$embedDomain/embed/tv').replace(queryParameters: params);
  }

  /// Build an episode-embed URI by IMDb ID:
  Uri episodeEmbedByImdb(
    String imdb, int season, int episode,
    {String? subUrl, String? dsLang}
  ) {
    final params = <String,String>{
      'imdb': imdb,
      'season': season.toString(),
      'episode': episode.toString(),
    };
    if (dsLang  != null) params['ds_lang'] = dsLang;
    if (subUrl != null) params['sub_url']  = Uri.encodeComponent(subUrl);
    return Uri.parse('$embedDomain/embed/tv').replace(queryParameters: params);
  }

  /// Build an episode-embed URI by TMDb ID:
  Uri episodeEmbedByTmdb(
    int tmdb, int season, int episode,
    {String? subUrl, String? dsLang}
  ) {
    final params = <String,String>{
      'tmdb': tmdb.toString(),
      'season': season.toString(),
      'episode': episode.toString(),
    };
    if (dsLang  != null) params['ds_lang'] = dsLang;
    if (subUrl != null) params['sub_url']  = Uri.encodeComponent(subUrl);
    return Uri.parse('$embedDomain/embed/tv').replace(queryParameters: params);
  }

  //――――――――――――――――――――――――――――――――――――――――――――
  // Fetch embed HTML (makes HTTP requests)
  //――――――――――――――――――――――――――――――――――――――――――――

  Future<String> fetchMovieEmbedHtmlByImdb(String imdb,
          {String? subUrl, String? dsLang}) =>
      _fetchHtml(movieEmbedByImdb(imdb, subUrl: subUrl, dsLang: dsLang));

  Future<String> fetchMovieEmbedHtmlByTmdb(int tmdb,
          {String? subUrl, String? dsLang}) =>
      _fetchHtml(movieEmbedByTmdb(tmdb, subUrl: subUrl, dsLang: dsLang));

  Future<String> fetchTvEmbedHtmlByImdb(String imdb,
          {String? dsLang}) =>
      _fetchHtml(tvEmbedByImdb(imdb, dsLang: dsLang));

  Future<String> fetchTvEmbedHtmlByTmdb(int tmdb,
          {String? dsLang}) =>
      _fetchHtml(tvEmbedByTmdb(tmdb, dsLang: dsLang));

  Future<String> fetchEpisodeEmbedHtmlByImdb(
          String imdb, int season, int episode,
          {String? subUrl, String? dsLang}) =>
      _fetchHtml(episodeEmbedByImdb(imdb, season, episode, subUrl: subUrl, dsLang: dsLang));

  Future<String> fetchEpisodeEmbedHtmlByTmdb(
          int tmdb, int season, int episode,
          {String? subUrl, String? dsLang}) =>
      _fetchHtml(episodeEmbedByTmdb(tmdb, season, episode, subUrl: subUrl, dsLang: dsLang));

  Future<String> _fetchHtml(Uri uri) async {
    final res = await httpClient.get(uri);
    if (res.statusCode != 200) {
      throw HttpException(
          'Failed to load embed (${res.statusCode})', uri: uri);
    }
    return res.body;
  }

  //――――――――――――――――――――――――――――――――――――――――――――
  // “Latest” list endpoints (paginated JSON)
  //――――――――――――――――――――――――――――――――――――――――――――

  Future<PagedResponse<MediaItem>> listLatestMovies(int page) async {
    return _fetchList('$apiDomain/movies/latest/page-$page.json');
  }

  Future<PagedResponse<MediaItem>> listLatestTvShows(int page) async {
    return _fetchList('$apiDomain/tvshows/latest/page-$page.json');
  }

  Future<PagedResponse<MediaItem>> listLatestEpisodes(int page) async {
    return _fetchList('$apiDomain/episodes/latest/page-$page.json');
  }

  Future<PagedResponse<MediaItem>> _fetchList(String url) async {
    final res = await httpClient.get(Uri.parse(url));
    if (res.statusCode != 200) {
      throw HttpException('Failed to load list (${res.statusCode})',
          uri: Uri.parse(url));
    }
    final jsonMap = json.decode(res.body) as Map<String, dynamic>;
    final items = (jsonMap['result'] as List)
        .map((e) => MediaItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final pages = jsonMap['pages'] as int;
    return PagedResponse(items: items, pages: pages);
  }

  /// Clean up the HTTP client when done.
  void close() => httpClient.close();
}
