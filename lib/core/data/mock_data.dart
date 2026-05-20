import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/service_provider.dart';
import '../config/supabase_config.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';

class Booking {
  final String id;
  final String serviceName;
  final String providerName;
  final String clientName;
  String status; 
  final DateTime date;
  final String time;
  final IconData icon;
  final String description;
  final List<String> imagePaths;

  Booking({
    required this.id,
    required this.serviceName,
    required this.providerName,
    required this.clientName,
    required this.status,
    required this.date,
    required this.time,
    required this.icon,
    this.description = '',
    this.imagePaths = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'serviceName': serviceName,
    'providerName': providerName,
    'clientName': clientName,
    'status': status,
    'date': date.toIso8601String(),
    'time': time,
    'iconCodePoint': icon.codePoint,
    'description': description,
    'imagePaths': imagePaths,
  };

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'],
    serviceName: json['serviceName'] ?? (json['service_name'] ?? 'Service'),
    providerName: json['providerName'] ?? (json['provider_name'] ?? 'Provider'),
    clientName: json['clientName'] ?? (json['client_name'] ?? 'John Doe'),
    status: json['status'] ?? 'Upcoming',
    date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    time: json['time'] ?? '12:00 PM',
    icon: IconData(json['iconCodePoint'] ?? (json['icon_code_point'] ?? Icons.build_circle_outlined.codePoint), fontFamily: 'MaterialIcons'),
    description: json['description'] ?? '',
    imagePaths: json['imagePaths'] != null 
        ? List<String>.from(json['imagePaths']) 
        : (json['image_paths'] != null ? List<String>.from(json['image_paths']) : const []),
  );
}

class AppNotification {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final DateTime timestamp;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'iconCodePoint': icon.codePoint,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'],
    title: json['title'] ?? '',
    subtitle: json['subtitle'] ?? '',
    icon: IconData(json['iconCodePoint'] ?? (json['icon_code_point'] ?? Icons.notifications.codePoint), fontFamily: 'MaterialIcons'),
    timestamp: DateTime.parse(json['timestamp'] ?? (json['created_at'] ?? DateTime.now().toIso8601String())),
    isRead: json['isRead'] ?? (json['is_read'] ?? false),
  );
}

class UserAddress {
  final String title;
  final String address;
  final double latitude;
  final double longitude;
  bool isSelected;
  bool isMain;

  UserAddress({
    required this.title,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.isSelected = false,
    this.isMain = false,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'isSelected': isSelected,
    'isMain': isMain,
  };

  factory UserAddress.fromJson(Map<String, dynamic> json) => UserAddress(
    title: json['title'] ?? '',
    address: json['address'] ?? '',
    latitude: json['latitude']?.toDouble() ?? 0.0,
    longitude: json['longitude']?.toDouble() ?? 0.0,
    isSelected: json['isSelected'] ?? (json['is_selected'] ?? false),
    isMain: json['isMain'] ?? (json['is_main'] ?? false),
  );
}

class MockData {
  static List<ServiceProvider> providers = [];
  static List<Booking> bookings = [];
  static List<AppNotification> notifications = [];
  static List<UserAddress> addresses = [];
  
  static String get currentUserName => AuthService.currentUser?.name ?? 'Guest';
  static String get currentUserEmail => AuthService.currentUser?.email ?? '';
  static bool get isUserRegisteredAsProvider => AuthService.currentUser?.isProvider ?? false;

  // Notification settings (kept local as it's device-specific prefs)
  static Map<String, bool> notificationSettings = {
    'General Notification': true,
    'App Updates': true,
    'Service Reminders': true,
    'Payment Request': true,
    'Discount Available': false,
    'Promotions': false,
  };

  static Future<void> init() async {
    await loadSettings();
    if (!SupabaseConfig.isSupabaseActive) return; // Wait for active db connection
    
    await loadProviders();
    if (AuthService.isLoggedIn) {
      await loadBookings();
      await loadNotifications();
      await loadAddresses();
    }
  }

  static Future<void> loadSettings() async {
    final jsonString = StorageService.getData('notification_settings');
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final Map<String, dynamic> data = jsonDecode(jsonString);
        data.forEach((key, value) {
          if (notificationSettings.containsKey(key)) {
            notificationSettings[key] = value as bool;
          }
        });
      } catch (_) {}
    }
  }

  static Future<void> saveSettings() async {
    final jsonString = jsonEncode(notificationSettings);
    await StorageService.saveData('notification_settings', jsonString);
  }

  static Future<void> loadProviders() async {
    try {
      final List<dynamic> response = await Supabase.instance.client
          .from('service_providers')
          .select();
      
      if (response.isNotEmpty) {
        providers = response.map((item) => ServiceProvider.fromJson(item)).toList();
      }
    } catch (e) {
      // Supabase strict enforcing - no local fallback
      providers = [];
    }
  }

  static Future<void> registerProvider(ServiceProvider provider) async {
    providers.removeWhere((p) => p.id == provider.id || p.name == provider.name);
    providers.add(provider);
    
    try {
      await Supabase.instance.client.from('service_providers').upsert({
        'id': provider.id,
        'name': provider.name,
        'category': provider.category,
        'rating': provider.rating,
        'reviewCount': provider.reviewCount,
        'location': provider.location,
        'iconCodePoint': provider.icon.codePoint,
        'colorValue': provider.avatarColor.value,
        'availableTimes': provider.availableTimes,
        'description': provider.description,
        'experience': provider.experience,
      });
    } catch (e) {
      // Failed to upload to Supabase
    }
  }

  static Future<void> loadBookings() async {
    try {
      final uid = AuthService.currentUser!.uid;
      final List<dynamic> response = await Supabase.instance.client
          .from('bookings')
          .select()
          .or('client_id.eq.$uid,provider_id.eq.$uid')
          .order('date', ascending: false);

      bookings = response.map((item) => Booking.fromJson(item)).toList();
    } catch (e) {
      bookings = [];
    }
  }

  static Future<void> addBooking(Booking booking) async {
    // 1. Availability validation
    final provider = providers.firstWhere(
      (p) => p.name.trim().toLowerCase() == booking.providerName.trim().toLowerCase(),
      orElse: () => const ServiceProvider(
        id: '',
        name: '',
        category: '',
        rating: 0.0,
        reviewCount: 0,
        location: '',
        icon: Icons.build,
        avatarColor: Colors.grey,
        availableTimes: [],
      ),
    );

    if (provider.id.isNotEmpty && provider.availableTimes.isNotEmpty) {
      final isTimeSlotAvailable = provider.availableTimes.any(
        (t) => t.trim().toLowerCase() == booking.time.trim().toLowerCase()
      );
      if (!isTimeSlotAvailable) {
        throw Exception('${booking.providerName} is not available at ${booking.time}.');
      }
    }

    if (booking.status.isEmpty || booking.status == 'Upcoming') {
      booking.status = 'Pending';
    }

    bookings.insert(0, booking);
    
    try {
      final uid = AuthService.currentUser!.uid;
      await Supabase.instance.client.from('bookings').insert({
        'id': booking.id,
        'service_name': booking.serviceName,
        'provider_name': booking.providerName,
        'client_name': booking.clientName,
        'status': booking.status,
        'date': booking.date.toIso8601String(),
        'time': booking.time,
        'icon_code_point': booking.icon.codePoint,
        'description': booking.description,
        'image_paths': booking.imagePaths,
        'client_id': uid,
        'provider_id': provider.id,
      });
    } catch (e) {}

    // Add notification for customer
    await addNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Booking Confirmed',
      subtitle: 'Your ${booking.serviceName} with ${booking.providerName} is confirmed.',
      icon: Icons.check_circle_outline,
      timestamp: DateTime.now(),
    ));

    // Add notification for provider
    await addNotification(AppNotification(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Job Request!',
      subtitle: 'You have a new ${booking.serviceName} request from ${booking.clientName}.',
      icon: Icons.business_center_outlined,
      timestamp: DateTime.now(),
    ));
  }

  static Future<void> updateBookingStatus(String id, String newStatus) async {
    final index = bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      bookings[index].status = newStatus;
      
      try {
        await Supabase.instance.client
            .from('bookings')
            .update({'status': newStatus})
            .eq('id', id);
      } catch (_) {}
    }
  }

  static Future<void> cancelBooking(String id) async {
    await updateBookingStatus(id, 'Cancelled');
  }

  static Future<void> rescheduleBooking(String id, String newTime) async {
    final index = bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      bookings[index] = Booking(
        id: bookings[index].id,
        serviceName: bookings[index].serviceName,
        providerName: bookings[index].providerName,
        clientName: bookings[index].clientName,
        status: 'Rescheduled',
        date: bookings[index].date,
        time: newTime,
        icon: bookings[index].icon,
        description: bookings[index].description,
        imagePaths: bookings[index].imagePaths,
      );
      
      try {
        await Supabase.instance.client
            .from('bookings')
            .update({'time': newTime, 'status': 'Rescheduled'})
            .eq('id', id);
      } catch (_) {}
    }
  }

  static Future<void> loadNotifications() async {
    try {
      final uid = AuthService.currentUser!.uid;
      final List<dynamic> response = await Supabase.instance.client
          .from('notifications')
          .select()
          .eq('user_id', uid)
          .order('timestamp', ascending: false);

      notifications = response.map((item) => AppNotification.fromJson(item)).toList();
    } catch (e) {
      notifications = [];
    }
  }

  static Future<void> addNotification(AppNotification notification) async {
    notifications.insert(0, notification);
    try {
      final uid = AuthService.currentUser!.uid;
      await Supabase.instance.client.from('notifications').insert({
        'id': notification.id,
        'title': notification.title,
        'subtitle': notification.subtitle,
        'icon_code_point': notification.icon.codePoint,
        'timestamp': notification.timestamp.toIso8601String(),
        'is_read': notification.isRead,
        'user_id': uid,
      });
    } catch (_) {}
  }

  static Future<void> loadAddresses() async {
    try {
      final uid = AuthService.currentUser!.uid;
      final List<dynamic> response = await Supabase.instance.client
          .from('addresses')
          .select()
          .eq('user_id', uid);

      if (response.isNotEmpty) {
        addresses = response.map((item) => UserAddress.fromJson(item)).toList();
      } else {
        addresses = [];
      }
    } catch (_) {
      addresses = [];
    }
  }

  static Future<void> saveAddress(UserAddress address) async {
    addresses.add(address);
    try {
      final uid = AuthService.currentUser!.uid;
      await Supabase.instance.client.from('addresses').insert({
        'title': address.title,
        'address': address.address,
        'latitude': address.latitude,
        'longitude': address.longitude,
        'is_selected': address.isSelected,
        'is_main': address.isMain,
        'user_id': uid,
      });
    } catch (_) {}
  }

  // Stub to prevent compilation errors in UI screens that iterate addresses and save all
  static Future<void> saveAddresses() async {
    // With Supabase, we should ideally upsert individual rows. 
    // This stub prevents crash. The addresses list is already modified in memory.
  }
}
