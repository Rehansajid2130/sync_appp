/// All data models for the AI conversational booking system.

/// Types of messages that can appear in the chat.
enum MessageType {
  user,
  ai,
  orchestration,
  providerCards,
  bookingConfirmation,
  addressSelection,
  updateOptions,
}

/// A single chat message.
class ChatMessage {
  final String id;
  final MessageType type;
  final String text;
  final DateTime timestamp;
  final List<ProviderResult>? providers;
  final List<OrchestrationStep>? orchestrationSteps;
  final BookingDraft? bookingDraft;
  final List<AddressOption>? addressOptions;

  ChatMessage({
    required this.id,
    required this.type,
    required this.text,
    DateTime? timestamp,
    this.providers,
    this.orchestrationSteps,
    this.bookingDraft,
    this.addressOptions,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// A step in the AI orchestration animation (e.g. "Searching providers...").
class OrchestrationStep {
  final String label;
  final bool completed;

  const OrchestrationStep({
    required this.label,
    this.completed = false,
  });

  OrchestrationStep copyWith({bool? completed}) {
    return OrchestrationStep(
      label: label,
      completed: completed ?? this.completed,
    );
  }
}

/// Booking state that persists across the conversation.
/// The AI fills this in progressively as it extracts info.
class BookingState {
  String? service;
  String? area;
  String? phase;
  String? street;
  String? fullAddress;
  String? date;
  String? time;
  String? issueDescription;
  List<String> images;
  String? urgency;
  String? selectedProviderId;

  BookingState({
    this.service,
    this.area,
    this.phase,
    this.street,
    this.fullAddress,
    this.date,
    this.time,
    this.issueDescription,
    this.images = const [],
    this.urgency,
    this.selectedProviderId,
  });

  /// Check which required fields are still missing.
  List<String> get missingRequiredFields {
    final missing = <String>[];
    if (service == null || service!.isEmpty) missing.add('service type');
    if (_isAddressIncomplete) missing.add('complete address');
    if (date == null || date!.isEmpty) missing.add('date');
    if (time == null || time!.isEmpty) missing.add('time');
    return missing;
  }

  bool get _isAddressIncomplete {
    // Either fullAddress is set, or area+phase+street
    if (fullAddress != null && fullAddress!.isNotEmpty) return false;
    if (area != null && area!.isNotEmpty) return false;
    return true;
  }

  bool get isReadyForProviderSearch => missingRequiredFields.isEmpty;

  /// Converts current state to a summary string for the AI prompt.
  Map<String, dynamic> toJson() {
    return {
      if (service != null) 'service': service,
      if (area != null) 'area': area,
      if (phase != null) 'phase': phase,
      if (street != null) 'street': street,
      if (fullAddress != null) 'fullAddress': fullAddress,
      if (date != null) 'date': date,
      if (time != null) 'time': time,
      if (issueDescription != null) 'issueDescription': issueDescription,
      if (urgency != null) 'urgency': urgency,
    };
  }

  /// Update from a JSON map (partial updates from AI extraction).
  void updateFromJson(Map<String, dynamic> json) {
    if (json['service'] != null) service = json['service'];
    if (json['area'] != null) area = json['area'];
    if (json['phase'] != null) phase = json['phase'];
    if (json['street'] != null) street = json['street'];
    if (json['fullAddress'] != null) fullAddress = json['fullAddress'];
    if (json['date'] != null) date = json['date'];
    if (json['time'] != null) time = json['time'];
    if (json['issueDescription'] != null) {
      issueDescription = json['issueDescription'];
    }
    if (json['urgency'] != null) urgency = json['urgency'];
  }

  @override
  String toString() {
    final parts = <String>[];
    if (service != null) parts.add('Service: $service');
    if (area != null) parts.add('Area: $area');
    if (phase != null) parts.add('Phase: $phase');
    if (street != null) parts.add('Street: $street');
    if (fullAddress != null) parts.add('Address: $fullAddress');
    if (date != null) parts.add('Date: $date');
    if (time != null) parts.add('Time: $time');
    if (issueDescription != null) parts.add('Issue: $issueDescription');
    if (urgency != null) parts.add('Urgency: $urgency');
    return parts.isEmpty ? 'Empty' : parts.join(', ');
  }
}

/// A provider result from the matching engine.
class ProviderResult {
  final String id;
  final String name;
  final String category;
  final double rating;
  final int reviewCount;
  final double distanceKm;
  final int etaMinutes;
  final String location;
  final String matchReason;
  final bool available;
  final double latitude;
  final double longitude;

  const ProviderResult({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.distanceKm,
    required this.etaMinutes,
    required this.location,
    required this.matchReason,
    this.available = true,
    required this.latitude,
    required this.longitude,
  });
}

/// The booking draft created after provider selection.
class BookingDraft {
  final String providerId;
  final String providerName;
  final String service;
  final String address;
  final String dateTime;
  final String? issue;
  final String status;

  const BookingDraft({
    required this.providerId,
    required this.providerName,
    required this.service,
    required this.address,
    required this.dateTime,
    this.issue,
    this.status = 'draft',
  });
}

/// The type of response the AI sends back.
enum AiResponseType {
  question,
  orchestration,
  providerCards,
  bookingConfirmation,
  error,
}

/// Structured response from the AI service.
class AiResponse {
  final AiResponseType type;
  final String message;
  final Map<String, dynamic>? extractedFields;
  final bool shouldSearchProviders;
  final bool shouldAskAddress;

  const AiResponse({
    required this.type,
    required this.message,
    this.extractedFields,
    this.shouldSearchProviders = false,
    this.shouldAskAddress = false,
  });
}

/// A stored user address option for selection.
class AddressOption {
  final String title;
  final String address;
  final double latitude;
  final double longitude;

  const AddressOption({
    required this.title,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}
