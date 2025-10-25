import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wonderkids.math/app_open_ad_manager.dart';
import 'package:wonderkids.math/firebase_options.dart';
import 'package:wonderkids.math/screens/badge_collection_screen.dart';
import 'package:wonderkids.math/screens/level_detail.dart';
import 'package:wonderkids.math/screens/map_screen.dart';
import 'package:wonderkids.math/themes/app_theme.dart';
import 'package:wonderkids.math/utils/custom_page_route.dart';
import 'package:wonderkids.math/utils/route_observer.dart';
import 'package:wonderkids.math/widgets/app_shell.dart';

// 🧮 Các màn học
import 'package:wonderkids.math/screens/learn_numbers.dart';
import 'package:wonderkids.math/screens/learn_numbers_20.dart';
import 'package:wonderkids.math/screens/learn_numbers_50.dart';
import 'package:wonderkids.math/screens/learn_numbers_100.dart';

// 🎮 Các màn trò chơi
import 'package:wonderkids.math/screens/game_compare.dart';
import 'package:wonderkids.math/screens/game_addition10.dart';
import 'package:wonderkids.math/screens/game_subtraction10.dart';
import 'package:wonderkids.math/screens/game_addition20.dart';
import 'package:wonderkids.math/screens/game_subtraction20.dart';
import 'package:wonderkids.math/screens/game_addition50.dart';
import 'package:wonderkids.math/screens/game_subtraction50.dart';
import 'package:wonderkids.math/screens/game_addition100.dart';
import 'package:wonderkids.math/screens/game_subtraction100.dart';
import 'package:wonderkids.math/screens/game_shapes.dart';
import 'package:wonderkids.math/screens/game_measure_time.dart';
import 'package:wonderkids.math/screens/game_final_boss.dart';

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
      themeMode: ThemeMode.dark, // 🌙 ép theme tối fintech
      home: const AppShell(),

      // ✅ Đăng ký tất cả route của Level
      onGenerateRoute: (settings) {
        final routes = <String, WidgetBuilder>{
          LevelDetail.routeName: (_) => const LevelDetail(),
          '/badges': (_) => const BadgeCollectionScreen(),
          '/map': (_) => const MapScreen(),

          // 🧮 Các màn học số
          '/learn_numbers': (_) => const LearnNumbersScreen(),
          '/learn_numbers_20': (_) => const LearnNumbers20Screen(),
          '/learn_numbers_50': (_) => const LearnNumbers50Screen(),
          '/learn_numbers_100': (_) => const LearnNumbers100Screen(),

          // 🎮 Các màn trò chơi
          '/game_compare': (_) => const GameCompareScreen(),
          '/game_addition10': (_) => const GameAddition10Screen(),
          '/game_subtraction10': (_) => const GameSubtraction10Screen(),
          '/game_addition20': (_) => const GameAddition20Screen(),
          '/game_subtraction20': (_) => const GameSubtraction20Screen(),
          '/game_addition50': (_) => const GameAddition50Screen(),
          '/game_subtraction50': (_) => const GameSubtraction50Screen(),
          '/game_addition100': (_) => const GameAddition100Screen(),
          '/game_subtraction100': (_) => const GameSubtraction100Screen(),
          '/game_shapes': (_) => const GameShapesScreen(),
          '/game_measure_time': (_) => const GameMeasureTimeScreen(),
        };

        final builder = routes[settings.name];
        if (builder != null) return CustomPageRoute(child: builder(context));
        return null;
      },
    );
  }
}
