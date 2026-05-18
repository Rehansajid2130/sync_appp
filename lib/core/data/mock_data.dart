import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/service_provider.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class Booking {
  final String id;
  final String serviceName;
  final String providerName;
  final String clientName;
  String status; // Changed to non-final for status updates
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
    serviceName: json['serviceName'],
    providerName: json['providerName'],
    clientName: json['clientName'] ?? 'John Doe',
    status: json['status'],
    date: DateTime.parse(json['date']),
    time: json['time'],
    icon: IconData(json['iconCodePoint'], fontFamily: 'MaterialIcons'),
    description: json['description'] ?? '',
    imagePaths: json['imagePaths'] != null ? List<String>.from(json['imagePaths']) : const [],
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
    title: json['title'],
    subtitle: json['subtitle'],
    icon: IconData(json['iconCodePoint'], fontFamily: 'MaterialIcons'),
    timestamp: DateTime.parse(json['timestamp']),
    isRead: json['isRead'] ?? false,
  );
}

class MockData {
  static List<ServiceProvider> providers = [];
  static List<Booking> bookings = [];
  static List<AppNotification> notifications = [];
  
  // Current logged in user info
  static String currentUserName = 'John Doe';
  static String currentUserEmail = 'john@example.com';
  static bool isUserRegisteredAsProvider = false;

  // Notification settings
  static Map<String, bool> notificationSettings = {
    'General Notification': true,
    'App Updates': true,
    'Service Reminders': true,
    'Payment Request': true,
    'Discount Available': false,
    'Promotions': false,
  };

  // Initialize and load everything from "database" (Local Storage)
  static Future<void> init() async {
    await loadProviders();
    await loadBookings();
    await loadNotifications();
    await loadSettings();
  }

  static Future<void> loadSettings() async {
    final jsonString = StorageService.getData('notification_settings');
    if (jsonString != null) {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      data.forEach((key, value) {
        if (notificationSettings.containsKey(key)) {
          notificationSettings[key] = value as bool;
        }
      });
    }
  }

  static Future<void> saveSettings() async {
    final jsonString = jsonEncode(notificationSettings);
    await StorageService.saveData('notification_settings', jsonString);
  }

  static Future<void> loadProviders() async {
    final jsonString = StorageService.getData('providers_data');
    final userJson = StorageService.getData('current_user');
    
    if (userJson != null) {
      final data = jsonDecode(userJson);
      currentUserName = data['name'];
      currentUserEmail = data['email'];
      isUserRegisteredAsProvider = data['isProvider'] ?? false;
    }

    if (jsonString == null) {
      // Seed initial data
      providers = [
        const ServiceProvider(
          id: 'p1',
          name: 'James Anderson',
          category: 'Cleaning',
          rating: 4.9,
          reviewCount: 128,
          location: 'New York, US',
          icon: Icons.cleaning_services_outlined,
          avatarColor: Color(0xFF91CBAE),
          availableTimes: ['08:00 AM', '10:00 AM', '01:00 PM', '03:00 PM'],
        ),
        const ServiceProvider(
          id: 'p2',
          name: 'Sarah Williams',
          category: 'Cleaning',
          rating: 4.8,
          reviewCount: 97,
          location: 'New York, US',
          icon: Icons.cleaning_services_outlined,
          avatarColor: Color(0xFF7DD5F5),
          availableTimes: ['09:00 AM', '11:00 AM', '02:00 PM', '04:00 PM'],
        ),
        const ServiceProvider(
          id: 'p3',
          name: 'Michael Brown',
          category: 'Repairing',
          rating: 4.7,
          reviewCount: 214,
          location: 'Brooklyn, US',
          icon: Icons.handyman_outlined,
          avatarColor: Color(0xFFFFB347),
          availableTimes: ['08:00 AM', '12:00 PM', '06:00 PM', '08:00 PM'],
        ),
      ];
      await saveProviders();
    } else {
      final List<dynamic> list = jsonDecode(jsonString);
      providers = list.map((item) => ServiceProvider.fromJson(item)).toList();
    }
  }

  static Future<void> saveProviders() async {
    final jsonString = jsonEncode(providers.map((p) => p.toJson()).toList());
    await StorageService.saveData('providers_data', jsonString);
    
    final userJson = jsonEncode({
      'name': currentUserName,
      'email': currentUserEmail,
      'isProvider': isUserRegisteredAsProvider,
    });
    await StorageService.saveData('current_user', userJson);
  }

  static Future<void> loadBookings() async {
    final jsonString = StorageService.getBookingsJson();
    if (jsonString != null) {
      final List<dynamic> list = jsonDecode(jsonString);
      bookings = list.map((item) => Booking.fromJson(item)).toList();
    } else {
      bookings = [
        Booking(
          id: '1',
          serviceName: 'House Cleaning',
          providerName: 'James Anderson',
          clientName: 'Alex Carter',
          status: 'Upcoming',
          date: DateTime.now().add(const Duration(days: 1)),
          time: '09:00 AM',
          icon: Icons.cleaning_services_outlined,
          description: 'Need a deep clean for the 2-bedroom apartment.',
        ),
      ];
    }

    // Proactively guarantee that there are always 'Pending' requests for evaluation purposes.
    if (!bookings.any((b) => b.status == 'Pending')) {
      bookings.addAll([
        Booking(
          id: 'pending_1',
          serviceName: 'AC Repair Service',
          providerName: 'James Anderson',
          clientName: 'Cyrus Smith',
          status: 'Pending',
          date: DateTime.now(),
          time: '02:30 PM',
          icon: Icons.ac_unit,
          description: 'AC is making a weird noise and not cooling.',
        ),
        Booking(
          id: 'pending_2',
          serviceName: 'Deep Home Cleaning',
          providerName: 'James Anderson',
          clientName: 'Sarah Connor',
          status: 'Pending',
          date: DateTime.now().add(const Duration(days: 1)),
          time: '11:00 AM',
          icon: Icons.cleaning_services,
          description: 'Standard cleaning before moving in.',
        ),
      ]);
      await saveBookings();
    }
  }

  static Future<void> saveBookings() async {
    final jsonString = jsonEncode(bookings.map((b) => b.toJson()).toList());
    await StorageService.saveBookingsJson(jsonString);
  }

  static Future<void> loadNotifications() async {
    final jsonString = StorageService.getData('notifications_data');
    if (jsonString != null) {
      final List<dynamic> list = jsonDecode(jsonString);
      notifications = list.map((item) => AppNotification.fromJson(item)).toList();
    } else {
      notifications = [
        AppNotification(
          id: 'n1',
          title: 'Welcome to HelperHive',
          subtitle: 'Thanks for joining our community! 🎉',
          icon: Icons.celebration,
          timestamp: DateTime.now(),
        ),
      ];
      await saveNotifications();
    }
  }

  static Future<void> saveNotifications() async {
    final jsonString = jsonEncode(notifications.map((n) => n.toJson()).toList());
    await StorageService.saveData('notifications_data', jsonString);
  }

  // Helper to add a new booking
  static Future<void> addBooking(Booking booking) async {
    bookings.insert(0, booking);
    await saveBookings();
    
    // Add notification for customer
    await addNotification(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Booking Confirmed',
      subtitle: 'Your ${booking.serviceName} with ${booking.providerName} is confirmed.',
      icon: Icons.check_circle_outline,
      timestamp: DateTime.now(),
    ));

    // Add notification for provider (mocking as if we are the provider too for demo)
    await addNotification(AppNotification(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      title: 'New Job Request!',
      subtitle: 'You have a new ${booking.serviceName} request from ${booking.clientName}.',
      icon: Icons.business_center_outlined,
      timestamp: DateTime.now(),
    ));
  }

  static Future<void> sendJobReminder(Booking booking) async {
    if (!(notificationSettings['Service Reminders'] ?? true)) return;

    // Reminder for customer
    await addNotification(AppNotification(
      id: 'rem_c_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Service Reminder ⏰',
      subtitle: 'Your ${booking.serviceName} appointment with ${booking.providerName} is coming up at ${booking.time}!',
      icon: Icons.alarm,
      timestamp: DateTime.now(),
    ));

    // Reminder for provider
    await addNotification(AppNotification(
      id: 'rem_p_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Job Reminder 🛠',
      subtitle: 'You have an upcoming ${booking.serviceName} job for ${booking.clientName} at ${booking.time}.',
      icon: Icons.notification_important_outlined,
      timestamp: DateTime.now(),
    ));

    // SHOW SYSTEM NOTIFICATION
    await NotificationService.showNotification(
      id: booking.id.hashCode,
      title: 'Service Reminder: ${booking.serviceName}',
      body: 'Your appointment is at ${booking.time}. Tap to view details.',
    );
  }

  static Future<void> addNotification(AppNotification notification) async {
    notifications.insert(0, notification);
    await saveNotifications();
  }

  static Future<void> updateBookingStatus(String id, String newStatus) async {
    final index = bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      bookings[index].status = newStatus;
      await saveBookings();
    }
  }

  static Future<void> addProvider(ServiceProvider provider) async {
    providers.add(provider);
    isUserRegisteredAsProvider = true; // Mark the user as a registered provider
    await saveProviders();
    
    await addNotification(AppNotification(
      id: 'reg_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Provider Registered',
      subtitle: 'Your business "${provider.name}" is now live on HelperHive!',
      icon: Icons.verified_user_outlined,
      timestamp: DateTime.now(),
    ));
  }
}
