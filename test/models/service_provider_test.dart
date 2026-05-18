import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:sync_app/models/service_provider.dart';

void main() {
  group('ServiceProvider Model Tests', () {
    test('Should create a valid ServiceProvider instance', () {
      final provider = ServiceProvider(
        id: 'p1',
        name: 'Test Provider',
        category: 'Cleaning',
        rating: 4.8,
        reviewCount: 100,
        location: 'New York, US',
        icon: Icons.cleaning_services,
        avatarColor: Colors.blue,
        availableTimes: ['09:00 AM', '10:00 AM'],
      );

      expect(provider.id, 'p1');
      expect(provider.name, 'Test Provider');
      expect(provider.category, 'Cleaning');
      expect(provider.availableTimes.length, 2);
    });
  });
}
