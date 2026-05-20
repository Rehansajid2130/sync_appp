import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/chat_message.dart';
import '../config/supabase_config.dart';
import 'auth_service.dart';
import 'storage_service.dart';

class ChatService {
  /// Send a message. Tries Supabase first, falls back to SharedPreferences.
  static Future<void> sendMessage({
    required String bookingId,
    required String text,
    required String senderId,
    required String senderName,
  }) async {
    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookingId: bookingId,
      senderId: senderId,
      senderName: senderName,
      text: text,
      timestamp: DateTime.now(),
      isRead: false,
    );

    if (SupabaseConfig.isSupabaseActive && AuthService.isLoggedIn) {
      try {
        await Supabase.instance.client.from('messages').insert(msg.toJson());
        return;
      } catch (e) {
        // Fallback to local
      }
    }

    // Local Fallback
    _saveLocalMessage(msg);
  }

  static void _saveLocalMessage(ChatMessage msg) {
    final key = 'chat_msgs_${msg.bookingId}';
    final existingJson = StorageService.getData(key);
    List<dynamic> list = [];
    if (existingJson != null && existingJson.isNotEmpty) {
      try {
        list = jsonDecode(existingJson);
      } catch (_) {}
    }
    list.add(msg.toJson());
    StorageService.saveData(key, jsonEncode(list));
  }

  /// Watch messages for a booking. Uses Supabase Realtime if available, else local snapshot.
  static Stream<List<ChatMessage>> watchMessages(String bookingId) async* {
    if (SupabaseConfig.isSupabaseActive && AuthService.isLoggedIn) {
      try {
        final stream = Supabase.instance.client
            .from('messages')
            .stream(primaryKey: ['id'])
            .eq('booking_id', bookingId)
            .order('timestamp', ascending: true);

        yield* stream.map((event) => event.map((e) => ChatMessage.fromJson(e)).toList());
        return;
      } catch (e) {
        // Fallback
      }
    }

    // Local Fallback (not real-time, just snapshot)
    final key = 'chat_msgs_$bookingId';
    final existingJson = StorageService.getData(key);
    List<ChatMessage> msgs = [];
    if (existingJson != null && existingJson.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(existingJson);
        msgs = list.map((e) => ChatMessage.fromJson(e)).toList();
      } catch (_) {}
    }
    yield msgs;
  }
}
