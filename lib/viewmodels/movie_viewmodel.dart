import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/movie_model.dart';
import '../providers/movie_provider.dart';

/// Enum to represent different movie categories
enum MovieCategory {
  popular,
  nowPlaying,
  trending,
  continueWatching,
  blockbusterAction
}

/// Provider that exposes the MovieViewModel
final movieViewModelProvider = Provider<MovieViewModel>((ref) {
  return MovieViewModel(ref);
});

/// Providers for different movie categories with pagination support
final popularMoviesStateProvider =
    StateNotifierProvider<MovieStateNotifier, AsyncValue<List<MovieDetail>>>(
        (ref) {
  return MovieStateNotifier(ref, MovieCategory.popular);
});

final nowPlayingMoviesStateProvider =
    StateNotifierProvider<MovieStateNotifier, AsyncValue<List<MovieDetail>>>(
        (ref) {
  return MovieStateNotifier(ref, MovieCategory.nowPlaying);
});

final trendingMoviesStateProvider =
    StateNotifierProvider<MovieStateNotifier, AsyncValue<List<MovieDetail>>>(
        (ref) {
  return MovieStateNotifier(ref, MovieCategory.trending);
});

final continueWatchingMoviesStateProvider =
    StateNotifierProvider<MovieStateNotifier, AsyncValue<List<MovieDetail>>>(
        (ref) {
  return MovieStateNotifier(ref, MovieCategory.continueWatching);
});

final blockbusterActionMoviesStateProvider =
    StateNotifierProvider<MovieStateNotifier, AsyncValue<List<MovieDetail>>>(
        (ref) {
  return MovieStateNotifier(ref, MovieCategory.blockbusterAction);
});

/// StateNotifier to manage the state of movie lists
class MovieStateNotifier extends StateNotifier<AsyncValue<List<MovieDetail>>> {
  final Ref _ref;
  final MovieCategory _category;
  int _currentPage = 1;
  bool _hasMorePages = true;
  List<MovieDetail> _movies = [];

  MovieStateNotifier(this._ref, this._category)
      : super(const AsyncValue.loading()) {
    fetchInitialMovies();
  }

  Future<void> fetchInitialMovies() async {
    _currentPage = 1;
    _movies = [];
    _hasMorePages = true;

    try {
      state = const AsyncValue.loading();
      final movieService = _ref.read(movieServiceProvider);

      switch (_category) {
        case MovieCategory.popular:
          _movies = await movieService.fetchPopularMovies(page: _currentPage);
          break;
        case MovieCategory.nowPlaying:
          _movies =
              await movieService.fetchNowPlayingMovies(page: _currentPage);
          break;
        case MovieCategory.trending:
          // For trending, we use the discover API with a specific sort
          _movies = await movieService.discoverMovies(
              page: _currentPage, sortBy: 'popularity.desc');
          break;
        case MovieCategory.continueWatching:
          // This would typically come from local storage in a real app
          // For demo purposes, we'll use popular movies from page 2
          _movies = await movieService.fetchPopularMovies(page: 2);
          break;
        case MovieCategory.blockbusterAction:
          // For action movies, we could add genre filtering in a real app
          // For now, using the discover API for movies with high vote counts
          _movies = await movieService.discoverMovies(
              page: _currentPage, sortBy: 'vote_count.desc');
          break;
      }

      state = AsyncValue.data(_movies);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> loadMoreMovies() async {
    if (!_hasMorePages) return;

    try {
      _currentPage++;
      final movieService = _ref.read(movieServiceProvider);
      List<MovieDetail> newMovies = [];

      switch (_category) {
        case MovieCategory.popular:
          newMovies = await movieService.fetchPopularMovies(page: _currentPage);
          break;
        case MovieCategory.nowPlaying:
          newMovies =
              await movieService.fetchNowPlayingMovies(page: _currentPage);
          break;
        case MovieCategory.trending:
          newMovies = await movieService.discoverMovies(
              page: _currentPage, sortBy: 'popularity.desc');
          break;
        case MovieCategory.continueWatching:
          newMovies =
              await movieService.fetchPopularMovies(page: _currentPage + 1);
          break;
        case MovieCategory.blockbusterAction:
          newMovies = await movieService.discoverMovies(
              page: _currentPage, sortBy: 'vote_count.desc');
          break;
      }

      if (newMovies.isEmpty) {
        _hasMorePages = false;
      } else {
        _movies.addAll(newMovies);
        state = AsyncValue.data(_movies);
      }
    } catch (e, stackTrace) {
      // We don't want to replace the entire state with an error
      // Just log the error or notify the user in some other way
      print("Error loading more movies: $e");
    }
  }

  void refresh() {
    fetchInitialMovies();
  }
}

/// Main ViewModel class to coordinate movie data across the app
class MovieViewModel {
  final Ref _ref;

  MovieViewModel(this._ref) {
    // Initialize all movie categories when the ViewModel is created
    _initializeMovieCategories();
  }

  void _initializeMovieCategories() {
    // This will trigger the StateNotifiers to fetch their respective movies
    _ref.read(popularMoviesStateProvider.notifier);
    _ref.read(nowPlayingMoviesStateProvider.notifier);
    _ref.read(trendingMoviesStateProvider.notifier);
    _ref.read(continueWatchingMoviesStateProvider.notifier);
    _ref.read(blockbusterActionMoviesStateProvider.notifier);
  }

  // Methods to expose the movie data from the ViewModel
  AsyncValue<List<MovieDetail>> get popularMovies =>
      _ref.watch(popularMoviesStateProvider);

  AsyncValue<List<MovieDetail>> get nowPlayingMovies =>
      _ref.watch(nowPlayingMoviesStateProvider);

  AsyncValue<List<MovieDetail>> get trendingMovies =>
      _ref.watch(trendingMoviesStateProvider);

  AsyncValue<List<MovieDetail>> get continueWatchingMovies =>
      _ref.watch(continueWatchingMoviesStateProvider);

  AsyncValue<List<MovieDetail>> get blockbusterActionMovies =>
      _ref.watch(blockbusterActionMoviesStateProvider);

  // Methods to load more movies for each category
  void loadMorePopularMovies() {
    _ref.read(popularMoviesStateProvider.notifier).loadMoreMovies();
  }

  void loadMoreNowPlayingMovies() {
    _ref.read(nowPlayingMoviesStateProvider.notifier).loadMoreMovies();
  }

  void loadMoreTrendingMovies() {
    _ref.read(trendingMoviesStateProvider.notifier).loadMoreMovies();
  }

  void loadMoreContinueWatchingMovies() {
    _ref.read(continueWatchingMoviesStateProvider.notifier).loadMoreMovies();
  }

  void loadMoreBlockbusterActionMovies() {
    _ref.read(blockbusterActionMoviesStateProvider.notifier).loadMoreMovies();
  }

  // Methods to refresh data for each category
  void refreshPopularMovies() {
    _ref.read(popularMoviesStateProvider.notifier).refresh();
  }

  void refreshNowPlayingMovies() {
    _ref.read(nowPlayingMoviesStateProvider.notifier).refresh();
  }

  void refreshTrendingMovies() {
    _ref.read(trendingMoviesStateProvider.notifier).refresh();
  }

  void refreshContinueWatchingMovies() {
    _ref.read(continueWatchingMoviesStateProvider.notifier).refresh();
  }

  void refreshBlockbusterActionMovies() {
    _ref.read(blockbusterActionMoviesStateProvider.notifier).refresh();
  }

  // Refresh all categories at once
  void refreshAllMovies() {
    refreshPopularMovies();
    refreshNowPlayingMovies();
    refreshTrendingMovies();
    refreshContinueWatchingMovies();
    refreshBlockbusterActionMovies();
  }
}
