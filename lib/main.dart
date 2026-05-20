import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/data/mock_data.dart';
import 'core/routes/app_routes.dart';
import 'core/utils/app_logger.dart';
import 'package:provider/provider.dart';
import 'core/config/api_keys.dart';
import 'ai/state/chat_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Error Handling
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.e('Flutter Error', details.exception, details.stack);
  };

  await StorageService.init();
  await NotificationService.init();
  
  // Try initializing Supabase with dynamic fallback protection
  try {
    if (SupabaseConfig.url.isNotEmpty && SupabaseConfig.anonKey.isNotEmpty &&
        !SupabaseConfig.url.contains('PLACEHOLDER') && !SupabaseConfig.anonKey.contains('PLACEHOLDER')) {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      SupabaseConfig.isSupabaseActive = true;
      AppLogger.i('Supabase Initialized Successfully');
    } else {
      AppLogger.w('SupabaseConfig: Credentials not fully set. Dynamic SharedPreferences mode active.');
    }
  } catch (e, stack) {
    AppLogger.e('Supabase Init Failed. Falling back to local SharedPreferences mode.', e, stack);
  }

  await MockData.init();
  
  AppLogger.i('App Initialized Successfully');
  
  final isDark = StorageService.isDarkMode();
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  
  runApp(const HelperHiveApp());
}

// Global theme switcher
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class HelperHiveApp extends StatelessWidget {
  const HelperHiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return ChangeNotifierProvider(
          create: (_) {
            final state = ChatState();
            state.initialize(ApiKeys.gemini);
            return state;
          },
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'HelperHive',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: currentMode,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.generateRoute,
          ),
        );
      },
    );
  }
}
