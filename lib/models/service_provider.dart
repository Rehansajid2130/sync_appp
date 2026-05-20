import 'package:flutter/material.dart';

class ServiceProvider {
  final String id;
  final String name;
  final String category;
  final double rating;
  final int reviewCount;
  final String location;
  final IconData icon;
  final Color avatarColor;
  final List<String> availableTimes;
  final String description;
  final int experience;

  const ServiceProvider({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.location,
    required this.icon,
    required this.avatarColor,
    this.availableTimes = const [],
    this.description = '',
    this.experience = 0,
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
    'availableTimes': availableTimes,
    'description': description,
    'experience': experience,
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
    availableTimes: json['availableTimes'] != null ? List<String>.from(json['availableTimes']) : const [],
    description: json['description'] ?? '',
    experience: json['experience'] ?? 0,
  );
}
