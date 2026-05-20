import 'dart:math';
import '../../core/data/mock_data.dart';
import '../../models/service_provider.dart';
import '../models/chat_models.dart';

/// Matches and ranks service providers based on booking requirements.
/// Uses existing MockData providers.
class ProviderMatchingService {
  static final _random = Random(42);

  /// Search for providers matching the booking state.
  /// Returns ranked ProviderResult list with fake distance/ETA data.
  static List<ProviderResult> searchProviders(BookingState bookingState) {
    final service = bookingState.service?.toLowerCase() ?? '';

    // Filter providers by matching category
    List<ServiceProvider> matched = MockData.providers.where((p) {
      final cat = p.category.toLowerCase();
      // Fuzzy match: "plumbing" matches "Plumbing", "repair" matches "Repairing"
      if (service.contains('plumb') && cat.contains('plumb')) return true;
      if (service.contains('clean') && cat.contains('clean')) return true;
      if (service.contains('electri') && cat.contains('electri')) return true;
      if ((service.contains('repair') || service.contains('fix')) &&
          cat.contains('repair')) return true;
      if (service.contains('heat') && cat.contains('heat')) return true;
      // If no specific match, include repairing as general fallback
      if (service.contains('ac') && cat.contains('repair')) return true;
      return false;
    }).toList();

    // If no exact match found, return top-rated providers as fallback
    if (matched.isEmpty) {
      matched = List.from(MockData.providers)
        ..sort((a, b) => b.rating.compareTo(a.rating));
      matched = matched.take(3).toList();
    }

    // Sort by rating (best first)
    matched.sort((a, b) => b.rating.compareTo(a.rating));

    // Convert to ProviderResult with simulated distance/ETA
    // Use user's address area to generate realistic-ish coords
    final baseLatitude = _getBaseLatitude(bookingState);
    final baseLongitude = _getBaseLongitude(bookingState);
    final requestedTime = bookingState.time;

    final results = matched.map<ProviderResult>((p) {
      final distanceKm = 0.5 + _random.nextDouble() * 4.5; // 0.5 - 5.0 km
      final etaMinutes = (distanceKm * 6).round() + _random.nextInt(10); // rough ETA
      final isAvailable = _checkAvailability(p.availableTimes, requestedTime);

      return ProviderResult(
        id: p.id,
        name: p.name,
        category: p.category,
        rating: p.rating,
        reviewCount: p.reviewCount,
        distanceKm: double.parse(distanceKm.toStringAsFixed(1)),
        etaMinutes: etaMinutes,
        matchReason: _generateMatchReason(p, bookingState),
        available: isAvailable,
        location: p.location,
        latitude: baseLatitude + (_random.nextDouble() - 0.5) * 0.02,
        longitude: baseLongitude + (_random.nextDouble() - 0.5) * 0.02,
      );
    }).toList();

    // Sort: available providers first, then by rating
    results.sort((a, b) {
      if (a.available != b.available) return a.available ? -1 : 1;
      return b.rating.compareTo(a.rating);
    });

    return results;
  }

  static double _getBaseLatitude(BookingState state) {
    final area = (state.area ?? state.fullAddress ?? '').toLowerCase();
    if (area.contains('dha') || area.contains('lahore')) return 31.4697;
    if (area.contains('bogor') || area.contains('situ')) return -6.58913;
    if (area.contains('jakarta')) return -6.17511;
    return -6.58913; // default
  }

  static double _getBaseLongitude(BookingState state) {
    final area = (state.area ?? state.fullAddress ?? '').toLowerCase();
    if (area.contains('dha') || area.contains('lahore')) return 74.4085;
    if (area.contains('bogor') || area.contains('situ')) return 106.7262;
    if (area.contains('jakarta')) return 106.82715;
    return 106.7262; // default
  }



  /// Check if a provider is available at the requested time.
  static bool _checkAvailability(List<String> availableTimes, String? requestedTime) {
    if (requestedTime == null || requestedTime.isEmpty) return true;
    if (availableTimes.isEmpty) return true;

    final reqLower = requestedTime.toLowerCase().replaceAll(' ', '');
    for (final slot in availableTimes) {
      final slotLower = slot.toLowerCase().replaceAll(' ', '');
      // Exact match or partial match (e.g. "2pm" matches "02:00 PM")
      if (slotLower.contains(reqLower) || reqLower.contains(slotLower)) {
        return true;
      }
      // Extract hour from both and compare
      final reqHour = _extractHour(requestedTime);
      final slotHour = _extractHour(slot);
      if (reqHour != null && slotHour != null && reqHour == slotHour) {
        return true;
      }
    }
    // If no exact match, still mark as available but with lower priority
    // (they might adjust their schedule)
    return true; // For now, mark all as available since mock data has limited slots
  }

  /// Extract hour number from time string like "2 PM" or "14:00"
  static int? _extractHour(String timeStr) {
    final match = RegExp(r'(\d{1,2})').firstMatch(timeStr);
    if (match == null) return null;
    int hour = int.parse(match.group(1)!);
    if (timeStr.toLowerCase().contains('pm') && hour < 12) hour += 12;
    if (timeStr.toLowerCase().contains('am') && hour == 12) hour = 0;
    return hour;
  }

  static String _generateMatchReason(
      ServiceProvider provider, BookingState state) {
    if (provider.rating >= 4.9) {
      return 'Top rated ${provider.category.toLowerCase()} specialist';
    }
    if (provider.reviewCount > 100) {
      return 'Most experienced with ${provider.reviewCount}+ reviews';
    }
    return 'Best match for your ${state.service?.toLowerCase() ?? "service"} needs';
  }
}
