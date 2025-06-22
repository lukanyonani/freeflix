import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/anime_api.dart';
import '../models/search_models.dart';
import '../models/tv_show_model.dart';

// 🏗️ API Service Provider
final animeApiProvider = Provider<AnimeApiService>((ref) {
  return AnimeApiService();
});

// 📺 Popular Anime TV Shows Provider
final popularAnimeTVShowsProvider = FutureProvider<List<TVShow>>((ref) async {
  final apiService = ref.read(animeApiProvider);
  print('🔄 Loading popular anime TV shows...');

  try {
    final data = await apiService.fetchPopularTVShows();
    final shows = data.map((json) => TVShow.fromJson(json)).toList();
    print('✅ Successfully loaded ${shows.length} popular anime TV shows');
    return shows;
  } catch (e) {
    print('❌ Error loading popular anime TV shows: $e');
    rethrow;
  }
});

// 📈 Trending Anime TV Shows Provider
final trendingAnimeTVShowsProvider = FutureProvider<List<TVShow>>((ref) async {
  final apiService = ref.read(animeApiProvider);
  print('🔄 Loading trending anime TV shows...');

  try {
    final data = await apiService.fetchTrendingTVShows();
    final shows = data.map((json) => TVShow.fromJson(json)).toList();
    print('✅ Successfully loaded ${shows.length} trending TV shows');
    return shows;
  } catch (e) {
    print('❌ Error loading trending TV shows: $e');
    rethrow;
  }
});

// 🎯 Top-Rated Anime TV Shows Provider with Pagination
final topRatedAnimeTVShowsProvider =
    FutureProvider.family<List<TVShow>, int>((ref, page) async {
  final apiService = ref.read(animeApiProvider);
  print('🔄 Loading top-rated anime TV shows (page $page)...');

  try {
    final data = await apiService.fetchTrendingTVShowsList(page: page);
    final shows = data.map((json) => TVShow.fromJson(json)).toList();
    print(
        '✅ Successfully loaded ${shows.length} top-rated anime TV shows (page $page)');
    return shows;
  } catch (e) {
    print('❌ Error loading top-rated anime TV shows (page $page): $e');
    rethrow;
  }
});

// 📅 TV Shows Airing Today Provider
final airingTodayAnimeTVProvider =
    FutureProvider.family<List<TVShow>, int>((ref, page) async {
  final apiService = ref.read(animeApiProvider);
  print('🔄 Loading anime TV shows airing today (page $page)...');

  try {
    final data = await apiService.fetchAiringTodayTV(page: page);
    final shows = data.map((json) => TVShow.fromJson(json)).toList();
    print(
        '✅ Successfully loaded ${shows.length} anime TV shows airing today (page $page)');
    return shows;
  } catch (e) {
    print('❌ Error loading anime TV shows airing today (page $page): $e');
    rethrow;
  }
});

// 🔍 TV Show Details Provider
final tvShowDetailsProvider =
    FutureProvider.family<TvShowDetail, int>((ref, tvId) async {
  final apiService = ref.read(animeApiProvider);
  print('🔄 Loading anime TV show details for ID: $tvId...');

  try {
    final data = await apiService.fetchTvDetails(tvId);
    final showDetail = TvShowDetail.fromJson(data);
    print('✅ Successfully loaded details for "${showDetail.name}"');
    return showDetail;
  } catch (e) {
    print('❌ Error loading anime TV show details for ID $tvId: $e');
    rethrow;
  }
});

// 📚 Episodes Provider for a specific season
final episodesProvider =
    FutureProvider.family<List<Episode>, EpisodeParams>((ref, params) async {
  final apiService = ref.read(animeApiProvider);
  print(
      '🔄 Loading episodes for show ${params.showId}, season ${params.seasonNumber}...');

  try {
    final data =
        await apiService.fetchEpisodes(params.showId, params.seasonNumber);
    final episodes = data.map((json) => Episode.fromJson(json)).toList();
    print(
        '✅ Successfully loaded ${episodes.length} episodes for season ${params.seasonNumber}');
    return episodes;
  } catch (e) {
    print(
        '❌ Error loading episodes for show ${params.showId}, season ${params.seasonNumber}: $e');
    rethrow;
  }
});

// 🎬 Episode Details Provider
final episodeDetailsProvider =
    FutureProvider.family<Episode, EpisodeDetailsParams>((ref, params) async {
  final apiService = ref.read(animeApiProvider);
  print(
      '🔄 Loading episode details for show ${params.showId}, S${params.season}E${params.episode}...');

  try {
    final data = await apiService.fetchEpisodeDetails(
        params.showId, params.season, params.episode);
    final episode = Episode.fromJson(data);
    print('✅ Successfully loaded episode details: "${episode.name}"');
    return episode;
  } catch (e) {
    print(
        '❌ Error loading episode details for S${params.season}E${params.episode}: $e');
    rethrow;
  }
});

// 🔎 TV Show Search Provider
final tvShowSearchProvider =
    FutureProvider.family<List<SearchResult>, SearchParams>(
        (ref, params) async {
  final apiService = ref.read(animeApiProvider);
  print('🔄 Searching TV shows for "${params.query}" (page ${params.page})...');

  try {
    final results =
        await apiService.searchTVShows(params.query, page: params.page);
    print('✅ Successfully found ${results.length} TV show search results');
    return results;
  } catch (e) {
    print('❌ Error searching TV shows for "${params.query}": $e');
    rethrow;
  }
});

// 🗂️ TV Genres Provider
final tvGenresProvider = FutureProvider<List<Genre>>((ref) async {
  final apiService = ref.read(animeApiProvider);
  print('🔄 Loading TV genres...');

  try {
    final data = await apiService.fetchTvGenres();
    final genres = data.map((json) => Genre.fromJson(json)).toList();
    print('✅ Successfully loaded ${genres.length} TV genres');
    return genres;
  } catch (e) {
    print('❌ Error loading TV genres: $e');
    rethrow;
  }
});

// 🎭 State Management for TV Show Lists
class TvShowListState {
  final List<TVShow> shows;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;

  TvShowListState({
    this.shows = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
  });

  TvShowListState copyWith({
    List<TVShow>? shows,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return TvShowListState(
      shows: shows ?? this.shows,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// 🎮 TV Show List Notifier for Pagination
class TvShowListNotifier extends StateNotifier<TvShowListState> {
  final AnimeApiService apiService;
  final String listType;

  TvShowListNotifier({
    required this.apiService,
    required this.listType,
  }) : super(TvShowListState());

  // 🔄 Load initial shows
  Future<void> loadShows() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    print('🔄 Loading initial $listType shows...');

    try {
      List<dynamic> data;
      switch (listType) {
        case 'topRated':
          data = await apiService.fetchTrendingTVShowsList(page: 1);
          break;
        case 'airingToday':
          data = await apiService.fetchAiringTodayTV(page: 1);
          break;
        default:
          data = await apiService.fetchPopularTVShows();
      }

      final shows = data.map((json) => TVShow.fromJson(json)).toList();
      state = state.copyWith(
        shows: shows,
        isLoading: false,
        currentPage: 1,
        hasMore: shows.length >= 20,
      );
      print('✅ Successfully loaded ${shows.length} $listType shows');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      print('❌ Error loading $listType shows: $e');
    }
  }

  // 📄 Load more shows (pagination)
  Future<void> loadMoreShows() async {
    if (state.isLoading || !state.hasMore) return;

    final nextPage = state.currentPage + 1;
    state = state.copyWith(isLoading: true);
    print('🔄 Loading more $listType shows (page $nextPage)...');

    try {
      List<dynamic> data;
      switch (listType) {
        case 'topRated':
          data = await apiService.fetchTrendingTVShowsList(page: nextPage);
          break;
        case 'airingToday':
          data = await apiService.fetchAiringTodayTV(page: nextPage);
          break;
        default:
          data = await apiService.fetchPopularTVShows();
      }

      final newShows = data.map((json) => TVShow.fromJson(json)).toList();
      state = state.copyWith(
        shows: [...state.shows, ...newShows],
        isLoading: false,
        currentPage: nextPage,
        hasMore: newShows.length >= 20,
      );
      print('✅ Successfully loaded ${newShows.length} more $listType shows');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      print('❌ Error loading more $listType shows: $e');
    }
  }

  // 🔄 Refresh shows
  Future<void> refreshShows() async {
    state = TvShowListState();
    await loadShows();
  }
}

// 🎯 Top-Rated TV Shows List Provider
final topRatedTvShowsListProvider =
    StateNotifierProvider<TvShowListNotifier, TvShowListState>((ref) {
  final apiService = ref.read(animeApiProvider);
  return TvShowListNotifier(apiService: apiService, listType: 'topRated');
});

// 📅 Airing Today TV Shows List Provider
final airingTodayTvShowsListProvider =
    StateNotifierProvider<TvShowListNotifier, TvShowListState>((ref) {
  final apiService = ref.read(animeApiProvider);
  return TvShowListNotifier(apiService: apiService, listType: 'airingToday');
});

// 🛠️ Helper classes for parameters
class EpisodeParams {
  final int showId;
  final int seasonNumber;

  EpisodeParams({required this.showId, required this.seasonNumber});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpisodeParams &&
          runtimeType == other.runtimeType &&
          showId == other.showId &&
          seasonNumber == other.seasonNumber;

  @override
  int get hashCode => showId.hashCode ^ seasonNumber.hashCode;
}

class EpisodeDetailsParams {
  final int showId;
  final int season;
  final int episode;

  EpisodeDetailsParams({
    required this.showId,
    required this.season,
    required this.episode,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EpisodeDetailsParams &&
          runtimeType == other.runtimeType &&
          showId == other.showId &&
          season == other.season &&
          episode == other.episode;

  @override
  int get hashCode => showId.hashCode ^ season.hashCode ^ episode.hashCode;
}

class SearchParams {
  final String query;
  final int page;

  SearchParams({required this.query, this.page = 1});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchParams &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          page == other.page;

  @override
  int get hashCode => query.hashCode ^ page.hashCode;
}
