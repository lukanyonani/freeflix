import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fullscreen_window/fullscreen_window.dart';

class PlayScreen extends StatefulWidget {
  final String id;
  final bool isMovie;
  final int? season;
  final int? episode;

  const PlayScreen({
    super.key,
    required this.id,
    this.isMovie = true,
    this.season,
    this.episode,
  });

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Force landscape and enter fullscreen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    FullScreenWindow.setFullScreen(true);
  }

  @override
  void dispose() {
    // Revert to portrait and exit fullscreen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    FullScreenWindow.setFullScreen(false);
    super.dispose();
  }

  String getEmbedUrl() {
    if (widget.isMovie) {
      // Movie
      return 'https://vidsrc.in/embed/movie/${widget.id}';
    } else {
      // TV show requires season & episode
      if (widget.season == null || widget.episode == null) {
        throw ArgumentError(
          'Season and episode must be provided for TV shows.',
        );
      }
      return 'https://vidsrc.in/embed/tv/${widget.id}/${widget.season}-${widget.episode}';
    }
  }

  Future<bool> _onWillPop() async {
    // Exit fullscreen before popping
    FullScreenWindow.setFullScreen(false);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                key: webViewKey,
                initialUrlRequest: URLRequest(
                  url: WebUri(getEmbedUrl()),
                ),
                initialSettings: InAppWebViewSettings(
                  allowsBackForwardNavigationGestures: true,
                  mediaPlaybackRequiresUserGesture: false,
                ),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStop: (_, __) {
                  setState(() => isLoading = false);
                },
                shouldOverrideUrlLoading: (controller, action) async {
                  final requested = action.request.url;
                  final main = WebUri(getEmbedUrl());
                  if (requested != null && requested.host != main.host) {
                    return NavigationActionPolicy.CANCEL;
                  }
                  return NavigationActionPolicy.ALLOW;
                },
              ),
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
