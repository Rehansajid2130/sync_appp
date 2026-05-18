import 'package:flutter/material.dart';

class ServiceProvider {
  final String id; // Added ID
  final String name;
  final String category;
  final double rating;
  final int reviewCount;
  final String location;
  final IconData icon;
  final Color avatarColor;
  final String priceRange; // Added priceRange
  final List<String> availableTimes; // Added availableTimes

  const ServiceProvider({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.icon,
    required this.avatarColor,
    this.priceRange = "\$\$ - \$\$\$", // Escaped dollars
    this.availableTimes = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'rating': rating,
    'reviewCount': reviewCount,
    'location': location,
    'iconCodePoint': icon.codePoint,
    'colorValue': avatarColor.value,
    'priceRange': priceRange,
    'availableTimes': availableTimes,
  };

  factory ServiceProvider.fromJson(Map<String, dynamic> json) => ServiceProvider(
    id: json['id'] ?? json['name'].hashCode.toString(),
    name: json['name'],
    category: json['category'],
    rating: (json['rating'] as num).toDouble(),
    reviewCount: json['reviewCount'],
    location: json['location'],
    icon: IconData(json['iconCodePoint'], fontFamily: 'MaterialIcons'),
    avatarColor: Color(json['colorValue']),
    priceRange: json['priceRange'] ?? "\$\$", // Escaped dollars
    availableTimes: json['availableTimes'] != null ? List<String>.from(json['availableTimes']) : const [],
  );
}
