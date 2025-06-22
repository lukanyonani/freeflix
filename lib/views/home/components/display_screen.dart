import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freeflix/data/movie_api.dart';
import 'package:freeflix/data/tv_show_api.dart';
import '../../../data/ad_manager.dart';
import '../../shared/components/play_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class ShowScreen extends StatefulWidget {
  final int showId;
  final bool isMovie; // Determines if it's a movie or a TV show

  const ShowScreen({super.key, required this.showId, required this.isMovie});

  @override
  // ignore: library_private_types_in_public_api
  _ShowScreenState createState() => _ShowScreenState();
}

class _ShowScreenState extends State<ShowScreen> {
  final MoviesApiService apiService = MoviesApiService();
  final TvShowsApiService tvApiService = TvShowsApiService();
  Map<String, dynamic>? showDetails;
  List<dynamic> episodes = [];
  int selectedSeason = 1;
  int numberOfSeason = 1;

  late RewardedAd rewardedAd;
  bool isRewardedAdReady = false;

  @override
  void initState() {
    super.initState();
    _fetchShowDetails();
    initAds();
    loadRewardedAd();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  Future<void> loadRewardedAd() async {
    RewardedAd.load(
      adUnitId: AdsManager.rewardedAdID,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            rewardedAd = ad;
            isRewardedAdReady = true;
          });
        },
        onAdFailedToLoad: (error) {
          debugPrint("Failed to load refresh page");
          setState(() {
            isRewardedAdReady = false;
          });
        },
      ),
    );
  }

  //ADS
  Future<InitializationStatus> initAds() {
    return MobileAds.instance.initialize();
  }

  Future<void> _fetchShowDetails() async {
    final details = widget.isMovie
        ? await apiService.fetchShowDetails(widget.showId)
        : await tvApiService.fetchShowDetails(widget.showId);
    setState(() {
      showDetails = details;
      if (!widget.isMovie && details['number_of_seasons'] > 0) {
        _fetchEpisodes(selectedSeason);
      }
      numberOfSeason = selectedSeason;
    });
  }

  Future<void> _fetchEpisodes(int seasonNumber) async {
    if (widget.isMovie) return;
    final seasonEpisodes =
        await tvApiService.fetchEpisodes(widget.showId, seasonNumber);
    setState(() {
      episodes = seasonEpisodes;
    });
  }

  Future<void> _refreshData() async {
    await _fetchShowDetails();
    await initAds();
    await loadRewardedAd();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          color: Colors.red, // Customize refresh indicator color
          child: showDetails == null
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Colors.red,
                ))
              : SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(), // Enables pull to refresh
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShowThumb(
                        showDetails: showDetails,
                        isMovie: widget.isMovie,
                        seasonNumber: !widget.isMovie ? 1 : null,
                        episodeNumber: !widget.isMovie ? 1 : null,
                        rewardedAd: isRewardedAdReady ? rewardedAd : null,
                      ),
                      const SizedBox(height: 2),
                      ShowDescription(showDetails: showDetails, widget: widget),
                      const SizedBox(height: 12),
                      if (!widget.isMovie &&
                          showDetails!['number_of_seasons'] > 0)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton<int>(
                            value: selectedSeason,
                            items: List.generate(
                                showDetails!['number_of_seasons'], (index) {
                              return DropdownMenuItem<int>(
                                value: index + 1,
                                child: Text('Season ${index + 1}'),
                              );
                            }),
                            onChanged: (int? value) {
                              if (value != null) {
                                setState(() {
                                  selectedSeason = value;
                                  _fetchEpisodes(selectedSeason);
                                  numberOfSeason = selectedSeason;
                                });
                              }
                            },
                            underline: const SizedBox.shrink(),
                            isDense: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.red,
                            ),
                            style: const TextStyle(color: Colors.white),
                            dropdownColor: Colors.black,
                          ),
                        ),
                      if (!widget.isMovie)
                        EpisodeList(
                          episodes: episodes,
                          showDetails: showDetails,
                          isMovie: false,
                          seasonNumber: selectedSeason,
                          rewardedAd: isRewardedAdReady ? rewardedAd : null,
                        ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class EpisodeList extends StatelessWidget {
  const EpisodeList({
    super.key,
    required this.episodes,
    required this.showDetails,
    required this.isMovie,
    this.seasonNumber,
    this.rewardedAd,
  });

  final RewardedAd? rewardedAd;
  final Map<String, dynamic>? showDetails;
  final bool isMovie;
  final int? seasonNumber;
  final List episodes;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Prevents unnecessary space
      children: [
        ListView.builder(
          shrinkWrap: true, // Ensures the list only takes up necessary space
          physics:
              const NeverScrollableScrollPhysics(), // Prevents internal scrolling
          padding: EdgeInsets.zero, // Removes extra padding
          itemCount: episodes.length,
          itemBuilder: (context, index) {
            final episode = episodes[index];
            final episodeThumbnail = episode['still_path'] != null
                ? 'https://image.tmdb.org/t/p/w500${episode['still_path']}'
                : 'https://via.placeholder.com/150'; // Placeholder if no image
            final int episodeNumber = episode['episode_number'] ?? 0;
            final episodeName = episode['name'] ?? 'Unknown Episode';

            return Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 4.0, horizontal: 8.0), // Adjust spacing
              child: InkWell(
                onTap: () {
                  if (rewardedAd != null) {
                    rewardedAd!.show(
                      onUserEarnedReward:
                          (AdWithoutView ad, RewardItem rewardItem) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlayScreen(
                              id: showDetails!['id'].toString(),
                              isMovie: isMovie,
                              season: seasonNumber,
                              episode: episode[
                                  'episode_number'], // Extract the episode number
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayScreen(
                          id: showDetails!['id'].toString(),
                          isMovie: isMovie,
                          season: seasonNumber,
                          episode: episode[
                              'episode_number'], // Extract the episode number
                        ),
                      ),
                    );
                  }
                },
                child: SizedBox(
                  width: double.infinity, // Ensures row takes full width
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Aligns content at the top
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                            8), // Optional: rounded corners
                        child: Image.network(
                          episodeThumbnail,
                          width: 120,
                          height: 75,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 75,
                              color: Colors.grey[800],
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        // Ensures text does not overflow
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Episode $episodeNumber:',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              episodeName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class ShowThumb extends StatelessWidget {
  const ShowThumb({
    super.key,
    required this.showDetails,
    required this.isMovie,
    this.seasonNumber,
    this.episodeNumber,
    this.rewardedAd,
  });

  final Map<String, dynamic>? showDetails;
  final bool isMovie;
  final int? seasonNumber;
  final int? episodeNumber;

  final RewardedAd? rewardedAd; // Add RewardedAd as a parameter

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CachedNetworkImage(
          imageUrl:
              'https://image.tmdb.org/t/p/w500${showDetails!['poster_path']}',
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(color: Colors.red),
          ),
          errorWidget: (context, url, error) => const Icon(
            Icons.broken_image,
            size: 50,
            color: Colors.white,
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.play_arrow_rounded,
            size: 90,
            color: Color.fromARGB(255, 187, 187, 187),
          ),
          onPressed: () {
            if (rewardedAd != null) {
              rewardedAd!.show(
                onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayScreen(
                        id: showDetails!['id'].toString(),
                        isMovie: isMovie,
                        season: seasonNumber,
                        episode: episodeNumber,
                      ),
                    ),
                  );
                },
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayScreen(
                    id: showDetails!['id'].toString(),
                    isMovie: isMovie,
                    season: seasonNumber,
                    episode: episodeNumber,
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

class ShowDescription extends StatelessWidget {
  const ShowDescription({
    super.key,
    required this.showDetails,
    required this.widget,
  });

  final Map<String, dynamic>? showDetails;
  final ShowScreen widget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(showDetails!['title'] ?? showDetails!['name'] ?? '',
              style:
                  const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
          Row(
            children: [
              if (!widget.isMovie) ...[
                const Text(' ',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
                Text(
                  '${showDetails!['number_of_seasons']} Seasons',
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
              ],
              Text(
                showDetails!['adult'] == true ? '  18+' : '  PG',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                size: 14,
                index <
                        ((showDetails!['vote_average'] as num?)?.toDouble() ??
                                0) ~/
                            2
                    ? Icons.star
                    : Icons.star_border,
                color: Colors.amber,
              );
            }),
          ),
          const SizedBox(height: 10),
          Text(showDetails!['overview'] ?? 'No description available.',
              style: const TextStyle(
                fontSize: 11,
              )),
        ],
      ),
    );
  }
}
