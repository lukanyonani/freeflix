import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fullscreen_window/fullscreen_window.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fullscreen_window/fullscreen_window.dart';
import 'package:get/get.dart';
// Modern web-specific imports using package:web
import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'dart:ui_web' as ui;

/// Universal PlayScreen that works on both Web and Mobile platforms
/// - Uses HTML iframe with package:web for web platform
/// - Uses InAppWebView for mobile platforms
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
  // Mobile WebView related variables
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;

  // Web iframe related variables
  late String iframeId;

  // Common state variables
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    print('🚀 PlayScreen initialized');
    print('📱 Platform detection: ${GetPlatform.isWeb ? "WEB" : "MOBILE"}');
    print('🎬 Content type: ${widget.isMovie ? "Movie" : "TV Show"}');
    print('🆔 Content ID: ${widget.id}');

    if (widget.season != null && widget.episode != null) {
      print('📺 Season: ${widget.season}, Episode: ${widget.episode}');
    }

    if (GetPlatform.isWeb) {
      // Web platform initialization
      print('🌐 Initializing web platform...');
      _initializeWebPlatform();
    } else {
      // Mobile platform initialization
      print('📱 Initializing mobile platform...');
      _initializeMobilePlatform();
    }
  }

  /// Initialize web-specific functionality
  void _initializeWebPlatform() {
    print('🌐 Setting up HTML iframe for web...');

    // Generate unique iframe ID with timestamp
    iframeId = 'video-iframe-${DateTime.now().millisecondsSinceEpoch}';
    print('🔗 Generated iframe ID: $iframeId');

    // Register the iframe view factory
    _registerIframeViewFactory();
  }

  /// Initialize mobile-specific functionality
  void _initializeMobilePlatform() {
    print('📱 Configuring mobile device orientation...');

    // Force landscape orientation for better video viewing experience
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]).then((_) {
      print('📱 ✅ Landscape orientation set successfully');
    }).catchError((error) {
      print('📱 ❌ Failed to set orientation: $error');
    });

    // Enter fullscreen mode
    print('📱 Entering fullscreen mode...');
    FullScreenWindow.setFullScreen(true).then((_) {
      print('📱 ✅ Fullscreen mode activated');
    }).catchError((error) {
      print('📱 ❌ Failed to enter fullscreen: $error');
    });
  }

  /// Register HTML iframe view factory for web platform using package:web
  void _registerIframeViewFactory() {
    print('🌐 Registering iframe view factory...');

    ui.platformViewRegistry.registerViewFactory(
      iframeId,
      (int viewId) {
        print('🌐 Creating iframe element with viewId: $viewId');

        // Create iframe element using package:web
        final iframe = web.HTMLIFrameElement()
          ..src = getEmbedUrl()
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allowFullscreen = true;

        // Set attributes using setAttribute
        iframe.setAttribute('allow',
            'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture');
        iframe.setAttribute('allowfullscreen', 'true');
        iframe.setAttribute('webkitallowfullscreen', 'true');
        iframe.setAttribute('mozallowfullscreen', 'true');

        print('🌐 Iframe source URL: ${iframe.src}');

        // Set up load event listener using modern event handling
        iframe.addEventListener(
            'load',
            (web.Event event) {
              print('🌐 ✅ Iframe loaded successfully');
              if (mounted) {
                setState(() {
                  isLoading = false;
                });
                print('🌐 Loading state updated: false');
              }
            }.toJS);

        // Set up error event listener
        iframe.addEventListener(
            'error',
            (web.Event event) {
              print('🌐 ❌ Iframe load error: $event');
              if (mounted) {
                setState(() {
                  isLoading = false;
                });
              }
            }.toJS);

        print('🌐 ✅ Iframe element created and configured');
        return iframe;
      },
    );

    print('🌐 ✅ View factory registered successfully');
  }

  @override
  void dispose() {
    print('🗑️ PlayScreen disposing...');

    if (!GetPlatform.isWeb) {
      print('📱 Reverting mobile platform settings...');

      // Revert to portrait orientation
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]).then((_) {
        print('📱 ✅ Portrait orientation restored');
      }).catchError((error) {
        print('📱 ❌ Failed to restore orientation: $error');
      });

      // Exit fullscreen mode
      FullScreenWindow.setFullScreen(false).then((_) {
        print('📱 ✅ Fullscreen mode deactivated');
      }).catchError((error) {
        print('📱 ❌ Failed to exit fullscreen: $error');
      });
    }

    print('🗑️ ✅ PlayScreen disposed successfully');
    super.dispose();
  }

  /// Generate the appropriate embed URL based on content type
  String getEmbedUrl() {
    String url;

    if (widget.isMovie) {
      // Movie URL format
      url = 'https://vidsrc.in/embed/movie/${widget.id}';
      print('🎬 Generated movie URL: $url');
    } else {
      // TV show requires season & episode
      if (widget.season == null || widget.episode == null) {
        final error = 'Season and episode must be provided for TV shows.';
        print('❌ URL generation error: $error');
        throw ArgumentError(error);
      }

      url =
          'https://vidsrc.in/embed/tv/${widget.id}/${widget.season}-${widget.episode}';
      print('📺 Generated TV show URL: $url');
    }

    return url;
  }

  /// Handle back navigation with proper cleanup
  Future<bool> _onWillPop() async {
    print('🔙 Back navigation triggered');

    if (!GetPlatform.isWeb) {
      print('📱 Exiting fullscreen before navigation...');
      try {
        await FullScreenWindow.setFullScreen(false);
        print('📱 ✅ Fullscreen exited successfully');
      } catch (error) {
        print('📱 ❌ Failed to exit fullscreen: $error');
      }
    }

    print('🔙 ✅ Navigation allowed');
    return true;
  }

  /// Build the appropriate video player widget based on platform
  Widget _buildVideoPlayer() {
    if (GetPlatform.isWeb) {
      print('🌐 Building web video player (HTML iframe)');
      return Container(
        width: double.infinity,
        height: double.infinity,
        child: HtmlElementView(
          viewType: iframeId,
        ),
      );
    } else {
      print('📱 Building mobile video player (InAppWebView)');
      return InAppWebView(
        key: webViewKey,
        initialUrlRequest: URLRequest(
          url: WebUri(getEmbedUrl()),
        ),
        initialSettings: InAppWebViewSettings(
          allowsBackForwardNavigationGestures: true,
          mediaPlaybackRequiresUserGesture: false,
          javaScriptEnabled: true,
          domStorageEnabled: true,
          allowsInlineMediaPlayback: true,
        ),
        onWebViewCreated: (controller) {
          print('📱 WebView created successfully');
          webViewController = controller;
        },
        onLoadStart: (controller, url) {
          print('📱 WebView load started: $url');
        },
        onLoadStop: (controller, url) {
          print('📱 ✅ WebView load completed: $url');
          if (mounted) {
            setState(() {
              isLoading = false;
            });
            print('📱 Loading state updated: false');
          }
        },
        onLoadError: (controller, url, code, message) {
          print('📱 ❌ WebView load error: $message (Code: $code)');
          if (mounted) {
            setState(() {
              isLoading = false;
            });
          }
        },
        shouldOverrideUrlLoading: (controller, action) async {
          final requested = action.request.url;
          final main = WebUri(getEmbedUrl());

          print('📱 URL loading request: $requested');
          print('📱 Main domain: ${main.host}');

          if (requested != null && requested.host != main.host) {
            print('📱 🚫 Blocking external navigation to: ${requested.host}');
            return NavigationActionPolicy.CANCEL;
          }

          print('📱 ✅ Allowing navigation');
          return NavigationActionPolicy.ALLOW;
        },
      );
    }
  }

  /// Build loading indicator
  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.black87,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              strokeWidth: 3.0,
            ),
          ],
        ),
      ),
    );
  }

  /// Build back button overlay
  Widget _buildBackButton() {
    return Positioned(
      top: 16,
      left: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            print('🔙 Back button pressed');
            Navigator.of(context).pop();
          },
          tooltip: 'Go back',
        ),
      ),
    );
  }

  /// Build platform indicator (for debugging)
  Widget _buildPlatformIndicator() {
    return Positioned(
      top: 16,
      right: 16,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: GetPlatform.isWeb
              ? Colors.blue.withOpacity(0.8)
              : Colors.green.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              GetPlatform.isWeb ? Icons.web : Icons.phone_android,
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 6),
            Text(
              GetPlatform.isWeb ? 'WEB' : _getPlatformName(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get detailed platform name using GetX platform detection
  String _getPlatformName() {
    if (GetPlatform.isAndroid) return 'ANDROID';
    if (GetPlatform.isIOS) return 'iOS';
    if (GetPlatform.isMacOS) return 'macOS';
    if (GetPlatform.isWindows) return 'WINDOWS';
    if (GetPlatform.isLinux) return 'LINUX';
    if (GetPlatform.isFuchsia) return 'FUCHSIA';
    return 'MOBILE';
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ Building PlayScreen UI');

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // Main video player
              _buildVideoPlayer(),

              // Loading indicator (shown when isLoading is true)
              if (isLoading) _buildLoadingIndicator(),

              // Back button overlay
              _buildBackButton(),

              // Platform indicator (for debugging - remove in production)
              _buildPlatformIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
