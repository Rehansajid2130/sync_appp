class ChatMessage {
  final String id;
  final String bookingId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.bookingId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'booking_id': bookingId,
    'sender_id': senderId,
    'sender_name': senderName,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'is_read': isRead,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'],
    bookingId: json['booking_id'],
    senderId: json['sender_id'],
    senderName: json['sender_name'],
    text: json['text'],
    timestamp: DateTime.parse(json['timestamp']),
    isRead: json['is_read'] ?? false,
  );
}
