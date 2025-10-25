import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wonderkids.math/screens/badge_collection_screen.dart';
import 'package:wonderkids.math/screens/level_detail.dart';
import 'package:wonderkids.math/themes/app_theme.dart';
import 'package:wonderkids.math/utils/custom_page_route.dart';
import 'package:wonderkids.math/utils/route_observer.dart';
import 'package:wonderkids.math/widgets/app_shell.dart';

import 'app_open_ad_manager.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initFirebase();
  await _initAdMob();
  await _initAppCheck();

  runApp(const WonderKidsMathApp());
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('🔥 [Firebase] Initialized successfully');
  } catch (e, st) {
    debugPrint('❌ [Firebase] Initialization failed: $e\n$st');
  }
}

Future<void> _initAdMob() async {
  try {
    final status = await MobileAds.instance.initialize();
    for (final entry in status.adapterStatuses.entries) {
      debugPrint(
        '📢 [AdMob] Adapter: ${entry.key}, '
        'State: ${entry.value.state}, '
        'Latency: ${entry.value.latency} ms',
      );
    }

    // 🚀 Hiển thị quảng cáo AppOpen mỗi ngày 1 lần
    AppOpenAdManager.showAdIfAllowed();

    debugPrint('✅ [AdMob] SDK initialized successfully');
  } catch (e, st) {
    debugPrint('❌ [AdMob] Initialization failed: $e\n$st');
  }
}

Future<void> _initAppCheck() async {
  try {
    await FirebaseAppCheck.instance.activate(
      androidProvider: kDebugMode
          ? AndroidProvider.debug
          : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode
          ? AppleProvider.debug
          : AppleProvider.deviceCheck,
    );
    debugPrint('🔒 [AppCheck] Activated successfully');
  } catch (e, st) {
    debugPrint('⚠️ [AppCheck] Activation failed: $e\n$st');
  }
}

class WonderKidsMathApp extends StatefulWidget {
  const WonderKidsMathApp({super.key});

  @override
  State<WonderKidsMathApp> createState() => _WonderKidsMathAppState();
}

class _WonderKidsMathAppState extends State<WonderKidsMathApp> {
  bool _firstLaunchChecked = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLaunched = prefs.getBool('has_launched') ?? false;

    if (!hasLaunched) {
      await prefs.setBool('has_launched', true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).push(CustomPageRoute(child: const LevelDetail()));
      });
    }
    setState(() => _firstLaunchChecked = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_firstLaunchChecked) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'WonderKids Vui Học Toán',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [appRouteObserver],
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      // 🌙 ép theme tối fintech
      onGenerateRoute: (settings) {
        final routes = {
          LevelDetail.routeName: (_) => const LevelDetail(),
          '/badges': (_) => const BadgeCollectionScreen(),
        };
        final builder = routes[settings.name];
        if (builder != null) return CustomPageRoute(child: builder(context));
        return null;
      },
      home: const AppShell(),
    );
  }
}
