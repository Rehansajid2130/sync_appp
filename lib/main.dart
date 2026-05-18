import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/services/storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/data/mock_data.dart';
import 'core/routes/app_routes.dart';
import 'core/utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Error Handling
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.e('Flutter Error', details.exception, details.stack);
  };

  await StorageService.init();
  await NotificationService.init();
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
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'HelperHive',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}
