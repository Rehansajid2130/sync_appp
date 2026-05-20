class Review {
  final String id;
  final String bookingId;
  final String providerId;
  final String clientName;
  final double rating;
  final String comment;
  final DateTime timestamp;

  Review({
    required this.id,
    required this.bookingId,
    required this.providerId,
    required this.clientName,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'booking_id': bookingId,
    'provider_id': providerId,
    'client_name': clientName,
    'rating': rating,
    'comment': comment,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    id: json['id'],
    bookingId: json['booking_id'],
    providerId: json['provider_id'],
    clientName: json['client_name'],
    rating: (json['rating'] as num).toDouble(),
    comment: json['comment'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}
