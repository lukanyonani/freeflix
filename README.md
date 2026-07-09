# FreeFlix

A Flutter streaming app for browsing and watching movies, TV shows, and anime, with a responsive layout that adapts across mobile, tablet, and desktop.

## Features

- Browse movies, TV shows, and anime with carousels and search
- Responsive UI: dedicated layouts for mobile, tablet, and desktop
- In-app video playback via `flutter_inappwebview`
- Fullscreen playback support
- Firebase Analytics integration and AdMob ads

## Tech stack

- **Flutter**, using **GetX** for routing/bindings and **Riverpod** for state management
- **Firebase Core / Analytics**
- **google_mobile_ads** for monetization

## Project layout

```
lib/
  app/            # bindings, routes, constants
  data/            # API clients (movies, TV, anime, video sources)
  models/           # data models
  providers/         # Riverpod providers
  viewmodels/         # view models
  views/            # screens, organized by feature and responsive layout
```

## Getting started

```bash
flutter pub get
flutter run
```

Requires Firebase configuration (`firebase_options.dart`) for your own project if you fork this.
