import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/review.dart';
import '../config/supabase_config.dart';
import 'storage_service.dart';

class ReviewService {
  static Future<void> submitReview({
    required String bookingId,
    required String providerId,
    required String clientName,
    required double rating,
    required String comment,
  }) async {
    final review = Review(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookingId: bookingId,
      providerId: providerId,
      clientName: clientName,
      rating: rating,
      comment: comment,
      timestamp: DateTime.now(),
    );

    if (SupabaseConfig.isSupabaseActive) {
      try {
        await Supabase.instance.client.from('reviews').insert(review.toJson());
        
        // Also update the provider's average rating in service_providers
        final reviews = await getProviderReviews(providerId);
        final newCount = reviews.length + 1; // +1 for the one we just added (if not reflected yet)
        final newRating = ((reviews.fold(0.0, (sum, r) => sum + r.rating) + rating) / newCount).toStringAsFixed(1);
        
        await Supabase.instance.client.from('service_providers').update({
          'rating': double.parse(newRating),
          'reviewCount': newCount,
        }).eq('id', providerId);
        
        return;
      } catch (e) {
        // Fallback
      }
    }

    // Local Fallback
    final key = 'reviews_$providerId';
    final existingJson = StorageService.getData(key);
    List<dynamic> list = [];
    if (existingJson != null && existingJson.isNotEmpty) {
      try {
        list = jsonDecode(existingJson);
      } catch (_) {}
    }
    list.add(review.toJson());
    StorageService.saveData(key, jsonEncode(list));
  }

  static Future<List<Review>> getProviderReviews(String providerId) async {
    if (SupabaseConfig.isSupabaseActive) {
      try {
        final List<dynamic> data = await Supabase.instance.client
            .from('reviews')
            .select()
            .eq('provider_id', providerId)
            .order('timestamp', ascending: false);
        return data.map((e) => Review.fromJson(e)).toList();
      } catch (_) {}
    }

    final key = 'reviews_$providerId';
    final existingJson = StorageService.getData(key);
    if (existingJson != null && existingJson.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(existingJson);
        return list.map((e) => Review.fromJson(e)).toList();
      } catch (_) {}
    }
    return [];
  }
}
