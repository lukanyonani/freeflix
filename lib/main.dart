import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'app/bindings/app_bindings.dart';
import 'firebase_options.dart';
import 'views/splash_screen.dart';

import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
  //MobileAds.instance.initialize();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FreeFlix',
      darkTheme: ThemeData.dark(),
      //themeMode: ThemeData.dark,
      initialBinding: AppBindings(),
      home: SplashScreen(),
      // getPages: AppPages.routes,
      // initialRoute: AppPages.INITIAL,
    );
  }
}
