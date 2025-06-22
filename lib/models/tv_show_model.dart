class TvShowDetail {
  final bool adult;
  final String? backdropPath;
  final List<CreatedBy> createdBy;
  final List<int> episodeRunTime;
  final String firstAirDate;
  final List<Genre> genres;
  final String homepage;
  final int id;
  final bool inProduction;
  final List<String> languages;
  final String lastAirDate;
  final Episode? lastEpisodeToAir;
  final String? name;
  final Episode? nextEpisodeToAir;
  final List<Network> networks;
  final int numberOfEpisodes;
  final int numberOfSeasons;
  final List<String> originCountry;
  final String originalLanguage;
  final String originalName;
  final String overview;
  final double popularity;
  final String? posterPath;
  final List<ProductionCompany> productionCompanies;
  final List<ProductionCountry> productionCountries;
  final List<Season> seasons;
  final List<SpokenLanguage> spokenLanguages;
  final String status;
  final String tagline;
  final String type;
  final double voteAverage;
  final int voteCount;

  TvShowDetail({
    required this.adult,
    this.backdropPath,
    required this.createdBy,
    required this.episodeRunTime,
    required this.firstAirDate,
    required this.genres,
    required this.homepage,
    required this.id,
    required this.inProduction,
    required this.languages,
    required this.lastAirDate,
    this.lastEpisodeToAir,
    this.name,
    this.nextEpisodeToAir,
    required this.networks,
    required this.numberOfEpisodes,
    required this.numberOfSeasons,
    required this.originCountry,
    required this.originalLanguage,
    required this.originalName,
    required this.overview,
    required this.popularity,
    this.posterPath,
    required this.productionCompanies,
    required this.productionCountries,
    required this.seasons,
    required this.spokenLanguages,
    required this.status,
    required this.tagline,
    required this.type,
    required this.voteAverage,
    required this.voteCount,
  });

  factory TvShowDetail.fromJson(Map<String, dynamic> json) {
    return TvShowDetail(
      adult: json['adult'] ?? false,
      backdropPath: json['backdrop_path'],
      createdBy: (json['created_by'] as List)
          .map((e) => CreatedBy.fromJson(e))
          .toList(),
      episodeRunTime: List<int>.from(json['episode_run_time'] ?? []),
      firstAirDate: json['first_air_date'] ?? '',
      genres: (json['genres'] as List).map((e) => Genre.fromJson(e)).toList(),
      homepage: json['homepage'] ?? '',
      id: json['id'] ?? 0,
      inProduction: json['in_production'] ?? false,
      languages: List<String>.from(json['languages'] ?? []),
      lastAirDate: json['last_air_date'] ?? '',
      lastEpisodeToAir: json['last_episode_to_air'] != null
          ? Episode.fromJson(json['last_episode_to_air'])
          : null,
      name: json['name'],
      nextEpisodeToAir: json['next_episode_to_air'] != null
          ? Episode.fromJson(json['next_episode_to_air'])
          : null,
      networks:
          (json['networks'] as List).map((e) => Network.fromJson(e)).toList(),
      numberOfEpisodes: json['number_of_episodes'] ?? 0,
      numberOfSeasons: json['number_of_seasons'] ?? 0,
      originCountry: List<String>.from(json['origin_country'] ?? []),
      originalLanguage: json['original_language'] ?? '',
      originalName: json['original_name'] ?? '',
      overview: json['overview'] ?? '',
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      posterPath: json['poster_path'],
      productionCompanies: (json['production_companies'] as List)
          .map((e) => ProductionCompany.fromJson(e))
          .toList(),
      productionCountries: (json['production_countries'] as List)
          .map((e) => ProductionCountry.fromJson(e))
          .toList(),
      seasons:
          (json['seasons'] as List).map((e) => Season.fromJson(e)).toList(),
      spokenLanguages: (json['spoken_languages'] as List)
          .map((e) => SpokenLanguage.fromJson(e))
          .toList(),
      status: json['status'] ?? '',
      tagline: json['tagline'] ?? '',
      type: json['type'] ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
    );
  }
}

class CreatedBy {
  final int id;
  final String creditId;
  final String name;
  final int gender;
  final String? profilePath;

  CreatedBy({
    required this.id,
    required this.creditId,
    required this.name,
    required this.gender,
    this.profilePath,
  });

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    return CreatedBy(
      id: json['id'] ?? 0,
      creditId: json['credit_id'] ?? '',
      name: json['name'] ?? '',
      gender: json['gender'] ?? 0,
      profilePath: json['profile_path'],
    );
  }
}

class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class Episode {
  final int id;
  final String name;
  final String overview;
  final double voteAverage;
  final int voteCount;
  final String airDate;
  final int episodeNumber;
  final String productionCode;
  final int runtime;
  final int seasonNumber;
  final int showId;
  final String? stillPath;

  Episode({
    required this.id,
    required this.name,
    required this.overview,
    required this.voteAverage,
    required this.voteCount,
    required this.airDate,
    required this.episodeNumber,
    required this.productionCode,
    required this.runtime,
    required this.seasonNumber,
    required this.showId,
    this.stillPath,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] ?? 0,
      airDate: json['air_date'] ?? '',
      episodeNumber: json['episode_number'] ?? 0,
      productionCode: json['production_code'] ?? '',
      runtime: json['runtime'] ?? 0,
      seasonNumber: json['season_number'] ?? 0,
      showId: json['show_id'] ?? 0,
      stillPath: json['still_path'],
    );
  }
}

class Network {
  final int id;
  final String? logoPath;
  final String name;
  final String originCountry;

  Network({
    required this.id,
    this.logoPath,
    required this.name,
    required this.originCountry,
  });

  factory Network.fromJson(Map<String, dynamic> json) {
    return Network(
      id: json['id'] ?? 0,
      logoPath: json['logo_path'],
      name: json['name'] ?? '',
      originCountry: json['origin_country'] ?? '',
    );
  }
}

class ProductionCompany {
  final int id;
  final String? logoPath;
  final String name;
  final String originCountry;

  ProductionCompany({
    required this.id,
    this.logoPath,
    required this.name,
    required this.originCountry,
  });

  factory ProductionCompany.fromJson(Map<String, dynamic> json) {
    return ProductionCompany(
      id: json['id'] ?? 0,
      logoPath: json['logo_path'],
      name: json['name'] ?? '',
      originCountry: json['origin_country'] ?? '',
    );
  }
}

class ProductionCountry {
  final String iso31661;
  final String name;

  ProductionCountry({
    required this.iso31661,
    required this.name,
  });

  factory ProductionCountry.fromJson(Map<String, dynamic> json) {
    return ProductionCountry(
      iso31661: json['iso_3166_1'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class Season {
  final String airDate;
  final int episodeCount;
  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final int seasonNumber;
  final double voteAverage; // Changed from int to double

  Season({
    required this.airDate,
    required this.episodeCount,
    required this.id,
    required this.name,
    required this.overview,
    this.posterPath,
    required this.seasonNumber,
    required this.voteAverage,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      airDate: json['air_date'] ?? '',
      episodeCount: (json['episode_count'] as num?)?.toInt() ?? 0,
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] ?? '',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      seasonNumber: (json['season_number'] as num?)?.toInt() ?? 0,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ??
          0.0, // Changed to double
    );
  }
}

class SpokenLanguage {
  final String englishName;
  final String iso6391;
  final String name;

  SpokenLanguage({
    required this.englishName,
    required this.iso6391,
    required this.name,
  });

  factory SpokenLanguage.fromJson(Map<String, dynamic> json) {
    return SpokenLanguage(
      englishName: json['english_name'] ?? '',
      iso6391: json['iso_639_1'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class TVShow {
  final int id;
  final String name;
  final String? thumbnail;
  final String overview;
  final double popularity;
  final double voteAverage;
  final int voteCount;
  final String? firstAirDate;
  final List<int> genreIds;
  final String? backdropPath;
  final String? originalLanguage;

  TVShow({
    required this.id,
    required this.name,
    this.thumbnail,
    required this.overview,
    required this.popularity,
    required this.voteAverage,
    required this.voteCount,
    this.firstAirDate,
    required this.genreIds,
    this.backdropPath,
    this.originalLanguage,
  });

  factory TVShow.fromJson(Map<String, dynamic> json) {
    return TVShow(
      id: json['id'],
      name: json['name'],
      thumbnail: json['poster_path'],
      overview: json['overview'],
      popularity: json['popularity'].toDouble(),
      voteAverage: json['vote_average'].toDouble(),
      voteCount: json['vote_count'],
      firstAirDate: json['first_air_date'],
      genreIds: List<int>.from(json['genre_ids']),
      backdropPath: json['backdrop_path'],
      originalLanguage: json['original_language'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'poster_path': thumbnail,
      'overview': overview,
      'popularity': popularity,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'first_air_date': firstAirDate,
      'genre_ids': genreIds,
      'backdrop_path': backdropPath,
      'original_language': originalLanguage,
    };
  }
}
