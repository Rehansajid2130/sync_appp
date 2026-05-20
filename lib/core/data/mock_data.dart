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
  
  // Current logged in user info
  static String _currentUserName = 'John Doe';
  static String get currentUserName => AuthService.currentUser?.name ?? _currentUserName;
  static set currentUserName(String value) {
    _currentUserName = value;
  }

  static String _currentUserEmail = 'john@example.com';
  static String get currentUserEmail => AuthService.currentUser?.email ?? _currentUserEmail;
  static set currentUserEmail(String value) {
    _currentUserEmail = value;
  }

  static bool _isUserRegisteredAsProvider = false;
  static bool get isUserRegisteredAsProvider => AuthService.currentUser?.isProvider ?? _isUserRegisteredAsProvider;
  static set isUserRegisteredAsProvider(bool value) {
    _isUserRegisteredAsProvider = value;
  }

  // Notification settings
  static Map<String, bool> notificationSettings = {
    'General Notification': true,
    'App Updates': true,
    'Service Reminders': true,
    'Payment Request': true,
    'Discount Available': false,
    'Promotions': false,
  };

  // Initialize and load everything from "database" (Supabase with Local Fallback)
  static Future<void> init() async {
    await loadSettings();
    await loadProviders();
    await loadBookings();
    await loadNotifications();
    await loadAddresses();
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
    if (SupabaseConfig.isSupabaseActive) {
      try {
        final List<dynamic> response = await Supabase.instance.client
            .from('service_providers')
            .select();
        
        if (response.isNotEmpty) {
          providers = response.map((item) => ServiceProvider.fromJson(item)).toList();
          return;
        } else {
          // Seed Supabase with initial providers
          final initialList = _getSeedProviders();
          for (final p in initialList) {
            await Supabase.instance.client.from('service_providers').insert({
              'id': p.id,
              'name': p.name,
              'category': p.category,
              'rating': p.rating,
              'reviewCount': p.reviewCount,
              'location': p.location,
              'iconCodePoint': p.icon.codePoint,
              'colorValue': p.avatarColor.value,
              'availableTimes': p.availableTimes,
            });
          }
          providers = initialList;
          return;
        }
      } catch (e) {
        // Fallback to local storage on exception
      }
    }

    // Local SharedPreferences Fallback
    final jsonString = StorageService.getData('providers_data');
    bool needToSeed = false;
    if (jsonString == null || jsonString.isEmpty) {
      needToSeed = true;
    } else {
      try {
        final List<dynamic> list = jsonDecode(jsonString);
        providers = list.map((item) => ServiceProvider.fromJson(item)).toList();
        if (providers.length < 8) {
          needToSeed = true;
        }
      } catch (e) {
        needToSeed = true;
      }
    }

    if (needToSeed) {
      providers = _getSeedProviders();
      await saveProviders();
    }
  }

  static Future<void> saveProviders() async {
    final jsonString = jsonEncode(providers.map((p) => p.toJson()).toList());
    await StorageService.saveData('providers_data', jsonString);
  }

  static Future<void> registerProvider(ServiceProvider provider) async {
    providers.removeWhere((p) => p.id == provider.id || p.name == provider.name);
    providers.add(provider);
    if (SupabaseConfig.isSupabaseActive) {
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
      } catch (_) {}
    } else {
      await saveProviders();
    }
  }

  static List<ServiceProvider> _getSeedProviders() {
    return [
      const ServiceProvider(
        id: 'p1',
        name: 'James Anderson',
        category: 'Cleaning',
        rating: 4.9,
        reviewCount: 128,
        location: 'Situ Udik, Bogor',
        icon: Icons.cleaning_services_outlined,
        avatarColor: Color(0xFF91CBAE),
        availableTimes: ['08:00 AM', '10:00 AM', '01:00 PM', '03:00 PM'],
        description: 'Professional cleaning specialist with over 5 years of experience in residential and commercial spaces.',
        experience: 5,
      ),
      const ServiceProvider(
        id: 'p2',
        name: 'Sarah Williams',
        category: 'Cleaning',
        rating: 4.8,
        reviewCount: 97,
        location: 'Situ Udik, Bogor',
        icon: Icons.cleaning_services_outlined,
        avatarColor: Color(0xFF7DD5F5),
        availableTimes: ['09:00 AM', '11:00 AM', '02:00 PM', '04:00 PM'],
        description: 'Eco-friendly cleaning expert specializing in sanitization and organizing. Highly detailed and efficient.',
        experience: 4,
      ),
      const ServiceProvider(
        id: 'p3',
        name: 'Michael Brown',
        category: 'Repairing',
        rating: 4.7,
        reviewCount: 214,
        location: 'Situ Udik, Bogor',
        icon: Icons.handyman_outlined,
        avatarColor: Color(0xFFFFB347),
        availableTimes: ['08:00 AM', '12:00 PM', '06:00 PM', '08:00 PM'],
        description: 'General contractor for home repairs, carpentry, drywall patching, and furniture assembly.',
        experience: 8,
      ),
      const ServiceProvider(
        id: 'p4',
        name: 'David Miller',
        category: 'Repairing',
        rating: 4.9,
        reviewCount: 156,
        location: 'Situ Udik, Bogor',
        icon: Icons.ac_unit,
        avatarColor: Color(0xFFF19E9E),
        availableTimes: ['10:00 AM', '01:00 PM', '03:00 PM', '05:00 PM'],
        description: 'HVAC repair and maintenance technician. Keeping your homes comfortable year-round.',
        experience: 6,
      ),
      const ServiceProvider(
        id: 'p5',
        name: 'Robert Wilson',
        category: 'Plumbing',
        rating: 4.8,
        reviewCount: 88,
        location: 'Situ Udik, Bogor',
        icon: Icons.plumbing,
        avatarColor: Color(0xFF9EAFF1),
        availableTimes: ['09:00 AM', '11:00 AM', '02:00 PM', '04:00 PM'],
        description: 'Licensed plumber specializing in leak repairs, pipe replacements, and drain cleaning.',
        experience: 7,
      ),
      const ServiceProvider(
        id: 'p6',
        name: 'William Taylor',
        category: 'Electrical',
        rating: 4.9,
        reviewCount: 112,
        location: 'Situ Udik, Bogor',
        icon: Icons.electrical_services,
        avatarColor: Color(0xFFE9F19E),
        availableTimes: ['08:00 AM', '10:00 AM', '01:00 PM', '03:00 PM'],
        description: 'Residential electrician for light fixtures, outlets, wiring upgrades, and troubleshooting.',
        experience: 5,
      ),
      const ServiceProvider(
        id: 'p7',
        name: 'Richard Thomas',
        category: 'Heating',
        rating: 4.6,
        reviewCount: 64,
        location: 'Situ Udik, Bogor',
        icon: Icons.local_fire_department,
        avatarColor: Color(0xFFF1C49E),
        availableTimes: ['10:00 AM', '02:00 PM', '04:00 PM', '06:00 PM'],
        description: 'Heating systems repair specialist, boiler tune-ups, and thermostat installations.',
        experience: 6,
      ),
      const ServiceProvider(
        id: 'p8',
        name: 'Joseph Martinez',
        category: 'Plumbing',
        rating: 4.7,
        reviewCount: 75,
        location: 'Situ Udik, Bogor',
        icon: Icons.plumbing,
        avatarColor: Color(0xFFD49EF1),
        availableTimes: ['11:00 AM', '01:00 PM', '03:00 PM', '05:00 PM'],
        description: 'Emergency plumbing specialist. Fast response times and durable repair solutions.',
        experience: 4,
      ),
    ];
  }

  static Future<void> loadBookings() async {
    if (SupabaseConfig.isSupabaseActive && AuthService.isLoggedIn) {
      try {
        final uid = AuthService.currentUser!.uid;
        final List<dynamic> response = await Supabase.instance.client
            .from('bookings')
            .select()
            .or('client_id.eq.$uid,provider_id.eq.$uid')
            .order('date', ascending: false);

        bookings = response.map((item) => Booking.fromJson(item)).toList();
        
        // Guarantee pending requests for demo/evaluation
        if (!bookings.any((b) => b.status == 'Pending')) {
          final pendingList = _getSeedPendingBookings();
          for (final b in pendingList) {
            await Supabase.instance.client.from('bookings').insert({
              'id': b.id,
              'service_name': b.serviceName,
              'provider_name': b.providerName,
              'client_name': b.clientName,
              'status': b.status,
              'date': b.date.toIso8601String(),
              'time': b.time,
              'icon_code_point': b.icon.codePoint,
              'description': b.description,
              'image_paths': b.imagePaths,
              'client_id': uid,
            });
          }
          bookings.addAll(pendingList);
        }
        return;
      } catch (e) {
        // Fallback on error
      }
    }

    // Local SharedPreferences Fallback
    final jsonString = StorageService.getBookingsJson();
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(jsonString);
        bookings = list.map((item) => Booking.fromJson(item)).toList();
      } catch (_) {}
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

    if (!bookings.any((b) => b.status == 'Pending')) {
      bookings.addAll(_getSeedPendingBookings());
      await saveBookings();
    }
  }


  static void cancelBooking(String id) {
    final idx = bookings.indexWhere((b) => b.id == id);
    if (idx != -1) {
      bookings[idx].status = 'Cancelled';
      _saveBookings();
    }
  }

  static void rescheduleBooking(String id, String newTime) {
    final idx = bookings.indexWhere((b) => b.id == id);
    if (idx != -1) {
      final old = bookings[idx];
      bookings[idx] = Booking(
        id: old.id,
        serviceName: old.serviceName,
        providerName: old.providerName,
        clientName: old.clientName,
        status: old.status,
        date: old.date,
        time: newTime,
        icon: old.icon,
        description: old.description,
        imagePaths: old.imagePaths,
      );
      _saveBookings();
    }
  }

  static void _saveBookings() {
    saveBookings();
  }

  static List<Booking> _getSeedPendingBookings() {
    final name = currentUserName;
    return [
      Booking(
        id: 'pending_1',
        serviceName: 'AC Repair Service',
        providerName: name,
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
        providerName: name,
        clientName: 'Sarah Connor',
        status: 'Pending',
        date: DateTime.now().add(const Duration(days: 1)),
        time: '11:00 AM',
        icon: Icons.cleaning_services,
        description: 'Standard cleaning before moving in.',
      ),
    ];
  }

  static Future<void> saveBookings() async {
    final jsonString = jsonEncode(bookings.map((b) => b.toJson()).toList());
    await StorageService.saveBookingsJson(jsonString);
  }

  static Future<void> loadNotifications() async {
    if (SupabaseConfig.isSupabaseActive && AuthService.isLoggedIn) {
      try {
        final uid = AuthService.currentUser!.uid;
        final List<dynamic> response = await Supabase.instance.client
            .from('notifications')
            .select()
            .eq('user_id', uid)
            .order('timestamp', ascending: false);

        notifications = response.map((item) => AppNotification.fromJson(item)).toList();
        return;
      } catch (e) {
        // Fallback on error
      }
    }

    // Local SharedPreferences Fallback
    final jsonString = StorageService.getData('notifications_data');
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(jsonString);
        notifications = list.map((item) => AppNotification.fromJson(item)).toList();
      } catch (_) {}
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
        throw Exception('${booking.providerName} is not available at ${booking.time}. Available slots are: ${provider.availableTimes.join(", ")}');
      }
    }

    // 2. Scheduling conflict validation
    final targetDateStr = "${booking.date.year}-${booking.date.month}-${booking.date.day}";
    final hasConflict = bookings.any((b) {
      final bDateStr = "${b.date.year}-${b.date.month}-${b.date.day}";
      return b.providerName.trim().toLowerCase() == booking.providerName.trim().toLowerCase() &&
          bDateStr == targetDateStr &&
          b.time.trim().toLowerCase() == booking.time.trim().toLowerCase() &&
          b.status != 'Cancelled' &&
          b.status != 'Declined';
    });

    if (hasConflict) {
      throw Exception('${booking.providerName} already has an appointment scheduled on $targetDateStr at ${booking.time}. Please select a different slot.');
    }

    // Default status to Pending if not specified or defaults to Upcoming
    if (booking.status.isEmpty || booking.status == 'Upcoming') {
      booking.status = 'Pending';
    }

    bookings.insert(0, booking);
    
    if (SupabaseConfig.isSupabaseActive && AuthService.isLoggedIn) {
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
        });
      } catch (e) {
        // Log & save local
      }
    } else {
      await saveBookings();
    }

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

    await NotificationService.showNotification(
      id: booking.id.hashCode,
      title: 'Service Reminder: ${booking.serviceName}',
      body: 'Your appointment is at ${booking.time}. Tap to view details.',
    );
  }

  static Future<void> addNotification(AppNotification notification) async {
    notifications.insert(0, notification);

    if (SupabaseConfig.isSupabaseActive && AuthService.isLoggedIn) {
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
    } else {
      await saveNotifications();
    }
  }

  static Future<void> updateBookingStatus(String id, String newStatus) async {
    final index = bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      bookings[index].status = newStatus;
      
      if (SupabaseConfig.isSupabaseActive) {
        try {
          await Supabase.instance.client
              .from('bookings')
              .update({'status': newStatus})
              .eq('id', id);
        } catch (_) {}
      } else {
        await saveBookings();
      }
    }
  }

  static Future<void> addProvider(ServiceProvider provider) async {
    providers.add(provider);
    
    if (SupabaseConfig.isSupabaseActive) {
      try {
        await Supabase.instance.client.from('service_providers').insert({
          'id': provider.id,
          'name': provider.name,
          'category': provider.category,
          'rating': provider.rating,
          'reviewCount': provider.reviewCount,
          'location': provider.location,
          'iconCodePoint': provider.icon.codePoint,
          'colorValue': provider.avatarColor.value,
          'availableTimes': provider.availableTimes,
        });
      } catch (_) {}
    } else {
      await saveProviders();
    }
    
    await addNotification(AppNotification(
      id: 'reg_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Provider Registered',
      subtitle: 'Your business "${provider.name}" is now live on HelperHive!',
      icon: Icons.verified_user_outlined,
      timestamp: DateTime.now(),
    ));
  }

  static Future<void> loadAddresses() async {
    if (SupabaseConfig.isSupabaseActive && AuthService.isLoggedIn) {
      try {
        final uid = AuthService.currentUser!.uid;
        final List<dynamic> response = await Supabase.instance.client
            .from('addresses')
            .select()
            .eq('user_id', uid);

        if (response.isNotEmpty) {
          addresses = response.map((item) => UserAddress.fromJson(item)).toList();
          return;
        } else {
          addresses = [];
          return;
        }
      } catch (_) {}
    }

    // Local SharedPreferences Fallback
    final uid = AuthService.currentUser?.uid ?? 'guest';
    final jsonString = StorageService.getData('addresses_data_$uid');
    if (jsonString != null && jsonString.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(jsonString);
        addresses = list.map((item) => UserAddress.fromJson(item)).toList();
      } catch (_) {
        addresses = [];
      }
    } else {
      if (AuthService.isLoggedIn) {
        addresses = [];
      } else {
        addresses = [
          UserAddress(
            title: 'My Home',
            address: 'Komplek Situ Udik, Jl. Raya Dramaga Jawa Barat 16310',
            latitude: -6.58913,
            longitude: 106.7262,
            isSelected: true,
            isMain: true,
          ),
          UserAddress(
            title: 'Apartment',
            address: 'Jl. Kebon Jeruk No. 12, Jakarta Barat 11530',
            latitude: -6.17511,
            longitude: 106.82715,
            isSelected: false,
            isMain: false,
          ),
        ];
        await saveAddresses();
      }
    }
  }

  static Future<void> saveAddresses() async {
    if (SupabaseConfig.isSupabaseActive && AuthService.isLoggedIn) {
      try {
        final uid = AuthService.currentUser!.uid;
        // Simple transaction style: delete existing and insert new
        await Supabase.instance.client.from('addresses').delete().eq('user_id', uid);
        
        for (final a in addresses) {
          await Supabase.instance.client.from('addresses').insert({
            'title': a.title,
            'address': a.address,
            'latitude': a.latitude,
            'longitude': a.longitude,
            'is_selected': a.isSelected,
            'is_main': a.isMain,
            'user_id': uid,
          });
        }
      } catch (_) {}
    } else {
      final uid = AuthService.currentUser?.uid ?? 'guest';
      final jsonString = jsonEncode(addresses.map((a) => a.toJson()).toList());
      await StorageService.saveData('addresses_data_$uid', jsonString);
    }
  }
}
