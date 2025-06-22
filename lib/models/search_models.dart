// search_models.dart
class SearchResult {
  final int id;
  final String title;
  final String? posterPath;
  final String? backdropPath;
  final String overview;
  final double voteAverage;
  final int voteCount;
  final String mediaType;
  final String? releaseDate;
  final double popularity;

  SearchResult({
    required this.id,
    required this.title,
    this.posterPath,
    this.backdropPath,
    required this.overview,
    required this.voteAverage,
    required this.voteCount,
    required this.mediaType,
    this.releaseDate,
    required this.popularity,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      overview: json['overview'] ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
      mediaType: json['media_type'] ?? '',
      releaseDate: json['release_date'] ?? json['first_air_date'],
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Person {
  final int id;
  final String name;
  final String? profilePath;
  final double popularity;
  final List<dynamic> knownFor;
  final String knownForDepartment;

  Person({
    required this.id,
    required this.name,
    this.profilePath,
    required this.popularity,
    required this.knownFor,
    required this.knownForDepartment,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      profilePath: json['profile_path'],
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      knownFor: json['known_for'] ?? [],
      knownForDepartment: json['known_for_department'] ?? '',
    );
  }
}

class Company {
  final int id;
  final String name;
  final String? logoPath;
  final String originCountry;

  Company({
    required this.id,
    required this.name,
    this.logoPath,
    required this.originCountry,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      logoPath: json['logo_path'],
      originCountry: json['origin_country'] ?? '',
    );
  }
}

class Collection {
  final int id;
  final String name;
  final String? posterPath;
  final String? backdropPath;

  Collection({
    required this.id,
    required this.name,
    this.posterPath,
    this.backdropPath,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
    );
  }
}

class Keyword {
  final int id;
  final String name;

  Keyword({
    required this.id,
    required this.name,
  });

  factory Keyword.fromJson(Map<String, dynamic> json) {
    return Keyword(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

// search_state.dart
class SearchState {
  final List<SearchResult> multiResults;
  final List<SearchResult> movieResults;
  final List<SearchResult> tvResults;
  final List<Person> personResults;
  final List<Company> companyResults;
  final List<Collection> collectionResults;
  final List<Keyword> keywordResults;
  final bool isLoading;
  final String? error;
  final String currentQuery;
  final String selectedCategory;

  SearchState({
    this.multiResults = const [],
    this.movieResults = const [],
    this.tvResults = const [],
    this.personResults = const [],
    this.companyResults = const [],
    this.collectionResults = const [],
    this.keywordResults = const [],
    this.isLoading = false,
    this.error,
    this.currentQuery = '',
    this.selectedCategory = 'multi',
  });

  SearchState copyWith({
    List<SearchResult>? multiResults,
    List<SearchResult>? movieResults,
    List<SearchResult>? tvResults,
    List<Person>? personResults,
    List<Company>? companyResults,
    List<Collection>? collectionResults,
    List<Keyword>? keywordResults,
    bool? isLoading,
    String? error,
    String? currentQuery,
    String? selectedCategory,
  }) {
    return SearchState(
      multiResults: multiResults ?? this.multiResults,
      movieResults: movieResults ?? this.movieResults,
      tvResults: tvResults ?? this.tvResults,
      personResults: personResults ?? this.personResults,
      companyResults: companyResults ?? this.companyResults,
      collectionResults: collectionResults ?? this.collectionResults,
      keywordResults: keywordResults ?? this.keywordResults,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentQuery: currentQuery ?? this.currentQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}
