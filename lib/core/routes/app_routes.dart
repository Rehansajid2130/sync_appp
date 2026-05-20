import 'package:flutter/material.dart';
import '../../screens/splash_screen.dart';
import '../../screens/onboarding_screen.dart';
import '../../ai/screens/ai_chat_screen.dart';
import '../../screens/new_ui/new_navigation_wrapper.dart';
import '../../screens/new_ui/new_search_results_screen.dart';
import '../../screens/new_ui/new_provider_detail_screen.dart';
import '../../screens/new_ui/new_auth_screen.dart';
import '../../screens/new_ui/new_chat_screen.dart';
import '../../screens/new_ui/new_chat_detail_screen.dart';
import '../../screens/rate_provider_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String mainNav = '/mainNav';
  static const String aiChat = '/aiChat';
  static const String searchResults = '/searchResults';
  static const String providerDetail = '/providerDetail';
  static const String chat = '/chat';
  static const String chatDetail = '/chatDetail';
  static const String rateProvider = '/rateProvider';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
      case signup:
        // Both point to the new combined Auth screen
        return MaterialPageRoute(builder: (_) => const NewAuthScreen());
      case mainNav:
        return MaterialPageRoute(builder: (_) => const NewNavigationWrapper());
      case aiChat:
        return MaterialPageRoute(builder: (_) => const AiChatScreen());
      case searchResults:
        final initialQuery = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => NewSearchResultsScreen(initialQuery: initialQuery),
          settings: settings,
        );
      case providerDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => NewProviderDetailScreen(providerData: args),
          settings: settings,
        );
      case chat:
        return MaterialPageRoute(builder: (_) => const NewChatScreen());
      case chatDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => NewChatDetailScreen(chatArguments: args),
          settings: settings,
        );
      case rateProvider:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => RateProviderScreen(
            providerId: args?['providerId'] ?? '',
            providerName: args?['providerName'] ?? '',
            bookingId: args?['bookingId'] ?? '',
          ),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
