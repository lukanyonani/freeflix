import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../data/tv_show_api.dart';
import '../models/search_models.dart';
import '../providers/movie_provider.dart';

// 🎥 Provider for accessing the MovieService (movies API)
final movieServiceProvider = Provider<MovieService>((ref) {
  print('🎬 Initializing MovieService provider...');
  return MovieService();
});

// 📺 Provider for accessing the TvShowsApiService (TV shows API)
final tvShowsApiProvider = Provider<TvShowsApiService>((ref) {
  print('📡 Initializing TvShowsApiService provider...');
  return TvShowsApiService();
});

// 🔮 SearchViewModel to orchestrate the search party!
class SearchViewModel extends StateNotifier<SearchState> {
  SearchViewModel(this._movieService, this._tvApiService)
      : super(SearchState()) {
    print('🚀 SearchViewModel ready to roll!');
  }

  final MovieService _movieService;
  final TvShowsApiService _tvApiService;
  Timer? _debounceTimer;

  // 📝 Update search query with a debounced twist
  void updateQuery(String query) {
    print('📜 New query incoming: "$query"');
    state = state.copyWith(currentQuery: query);

    // 🚨 Empty query? Time to reset the stage!
    if (query.trim().isEmpty) {
      print('🧹 Query is empty — sweeping away results!');
      _clearResults();
      return;
    }

    // ⏲️ Debounce to keep the API from getting dizzy
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      print('⏰ Debounce timer fired for query: "$query"');
      _performSearch(query.trim());
    });
  }

  // 🎭 Switch search category (movie, tv, or multi)
  void updateCategory(String category) {
    print('🎬 Switching category to: "$category"');
    state = state.copyWith(selectedCategory: category);

    // 🔍 If there's a query, let's search in the new category!
    if (state.currentQuery.isNotEmpty) {
      print('🔎 Triggering search for category: "$category"');
      _performSearch(state.currentQuery);
    }
  }

  // 🔍 Perform the search magic based on category
  Future<void> _performSearch(String query) async {
    print(
        '🌟 Kicking off search for "$query" in "${state.selectedCategory}"...');
    state = state.copyWith(isLoading: true, error: null);

    try {
      switch (state.selectedCategory) {
        case 'movie':
          final movieDetails = await _movieService.searchMovies(query);
          final results = movieDetails
              .map((movie) => SearchResult(
                    id: movie.id,
                    title: movie.title,
                    posterPath: movie.posterPath,
                    backdropPath: movie.backdropPath,
                    overview: movie.overview,
                    voteAverage: movie.voteAverage,
                    voteCount: movie.voteCount,
                    mediaType: 'movie',
                    releaseDate: movie.releaseDate,
                    popularity: movie.popularity,
                  ))
              .toList();
          print('🎥 Fetched ${results.length} movie results!');
          state = state.copyWith(
            movieResults: results,
            isLoading: false,
          );
          break;

        case 'tv':
          final results = await _tvApiService.searchTVShows(query);
          print('📺 Fetched ${results.length} TV show results!');
          state = state.copyWith(
            tvResults: results,
            isLoading: false,
          );
          break;

        case 'multi':
          // TMDb multi-search endpoint for movies and TV shows
          final movieResults = await _movieService.searchMovies(query);
          final tvResults = await _tvApiService.searchTVShows(query);
          final multiResults = [
            ...movieResults.map((movie) => SearchResult(
                  id: movie.id,
                  title: movie.title,
                  posterPath: movie.posterPath,
                  backdropPath: movie.backdropPath,
                  overview: movie.overview,
                  voteAverage: movie.voteAverage,
                  voteCount: movie.voteCount,
                  mediaType: 'movie',
                  releaseDate: movie.releaseDate,
                  popularity: movie.popularity,
                )),
            ...tvResults,
          ];
          print('🌐 Fetched ${multiResults.length} multi-search results!');
          state = state.copyWith(
            multiResults: multiResults,
            isLoading: false,
          );
          break;

        default:
          print('🤔 Unknown category "${state.selectedCategory}" — skipping!');
          state = state.copyWith(isLoading: false);
          break;
      }
    } catch (e) {
      print('💥 Search crashed: ${e.toString()}');
      state = state.copyWith(
        isLoading: false,
        error: 'Oops, search failed: ${e.toString()}',
      );
    }
  }

  // 🧹 Clear the search results and errors
  void _clearResults() {
    print('🧼 Wiping the search slate clean...');
    state = state.copyWith(
      multiResults: [],
      movieResults: [],
      tvResults: [],
      isLoading: false,
      error: null,
    );
  }

  // 🧨 Clean up when the ViewModel is done
  @override
  void dispose() {
    print('🧹 SearchViewModel shutting down, canceling timers...');
    _debounceTimer?.cancel();
    super.dispose();
  }
}

// 🌍 Provider for the SearchViewModel
final searchViewModelProvider =
    StateNotifierProvider<SearchViewModel, SearchState>((ref) {
  final movieService = ref.watch(movieServiceProvider);
  final tvApiService = ref.watch(tvShowsApiProvider);
  print('🏗️ Building SearchViewModel with providers...');
  return SearchViewModel(movieService, tvApiService);
});
