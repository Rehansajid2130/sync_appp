import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../core/data/mock_data.dart';
import '../models/chat_models.dart';
import '../services/gemini_service.dart';
import '../services/provider_matching_service.dart';

class ChatState extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();

  final List<ChatMessage> _messages = [];
  final BookingState _bookingState = BookingState();
  List<ProviderResult> _providers = [];
  ProviderResult? _selectedProvider;
  bool _isAiTyping = false;
  bool _isSearchingProviders = false;
  bool _mapVisible = false;
  bool _isInitialized = false;
  bool _bookingConfirmed = false;
  bool _waitingForAddressSelection = false;
  List<OrchestrationStep> _currentOrchestrationSteps = [];

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  BookingState get bookingState => _bookingState;
  List<ProviderResult> get providers => List.unmodifiable(_providers);
  ProviderResult? get selectedProvider => _selectedProvider;
  bool get isAiTyping => _isAiTyping;
  bool get isSearchingProviders => _isSearchingProviders;
  bool get mapVisible => _mapVisible;
  bool get isInitialized => _isInitialized;
  bool get isMockMode => _geminiService.isMockMode;
  bool get bookingConfirmed => _bookingConfirmed;
  bool get waitingForAddressSelection => _waitingForAddressSelection;
  List<OrchestrationStep> get currentOrchestrationSteps =>
      List.unmodifiable(_currentOrchestrationSteps);

  Future<void> initialize(String apiKey) async {
    await _geminiService.initialize(apiKey);
    _isInitialized = true;
    _messages.add(ChatMessage(
      id: 'welcome',
      type: MessageType.ai,
      text: 'Hi! 👋 I\'m your HelperHive assistant. '
          'Tell me what service you need and I\'ll find the best provider near you.\n\n'
          'For example: "I need a plumber tomorrow at 2 PM"',
    ));
    notifyListeners();
  }

  Future<void> sendMessage(String userText, {Uint8List? audioBytes, String? mimeType}) async {
    if (userText.trim().isEmpty && audioBytes == null) return;
    
    _messages.add(ChatMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      type: MessageType.user,
      text: audioBytes != null && userText.isEmpty ? "🎤 [Audio Message]" : userText.trim(),
    ));
    _isAiTyping = true;
    notifyListeners();

    // ── Auto-match saved address titles (e.g. "home", "apartment") ──
    if (_bookingState.fullAddress == null) {
      final userLower = userText.trim().toLowerCase();
      for (final addr in MockData.addresses) {
        if (userLower.contains(addr.title.toLowerCase())) {
          _bookingState.fullAddress = addr.address;
          _messages.add(ChatMessage(
            id: 'ai_auto_addr_${DateTime.now().millisecondsSinceEpoch}',
            type: MessageType.ai,
            text: 'I recognized "${addr.title}". I\'ll use this address: ${addr.address}',
          ));
          notifyListeners();
          await Future.delayed(const Duration(milliseconds: 600));
          break;
        }
      }
    }

    final lastAiMsg = _messages.reversed
        .firstWhere((m) => m.type == MessageType.ai,
            orElse: () => ChatMessage(id: '', type: MessageType.ai, text: ''))
        .text;

    final response = await _geminiService.sendMessage(
      userText.trim(),
      _bookingState,
      lastAiMessage: lastAiMsg.isNotEmpty ? lastAiMsg : null,
      audioBytes: audioBytes,
      mimeType: mimeType,
    );
    if (response.extractedFields != null) {
      _bookingState.updateFromJson(response.extractedFields!);
    }

    if (response.shouldSearchProviders) {
      await _handleAddressCheckAndSearch(response.message);
    } else {
      // Intercept if AI is asking for address/location and we have stored addresses
      final isAskingLocation = response.message.toLowerCase().contains('area') ||
          response.message.toLowerCase().contains('location') ||
          response.message.toLowerCase().contains('address') ||
          response.message.toLowerCase().contains('phase');

      if (isAskingLocation && MockData.addresses.isNotEmpty && _bookingState.fullAddress == null) {
        await _handleAddressCheckAndSearch(response.message);
      } else {
        _isAiTyping = false;
        _messages.add(ChatMessage(
          id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
          type: MessageType.ai,
          text: response.message,
        ));
        notifyListeners();
      }
    }
  }

  Future<void> _handleAddressCheckAndSearch(String aiMessage) async {
    final storedAddresses = MockData.addresses;
    if (_bookingState.fullAddress == null && storedAddresses.isNotEmpty) {
      _isAiTyping = false;
      _waitingForAddressSelection = true;

      final addressOptions = storedAddresses
          .map((a) => AddressOption(title: a.title, address: a.address,
                latitude: a.latitude, longitude: a.longitude))
          .toList();

      if (storedAddresses.length == 1) {
        final addr = storedAddresses.first;
        _bookingState.fullAddress = addr.address;
        _waitingForAddressSelection = false;
        _messages.add(ChatMessage(
          id: 'ai_addr_${DateTime.now().millisecondsSinceEpoch}',
          type: MessageType.ai,
          text: 'I\'ll use your saved address: "${addr.title}" — ${addr.address}',
        ));
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 500));
        await _handleProviderSearch(aiMessage);
      } else {
        _messages.add(ChatMessage(
          id: 'ai_addr_ask_${DateTime.now().millisecondsSinceEpoch}',
          type: MessageType.ai,
          text: 'I found ${storedAddresses.length} saved addresses. Which one for this booking?',
        ));
        _messages.add(ChatMessage(
          id: 'addr_select_${DateTime.now().millisecondsSinceEpoch}',
          type: MessageType.addressSelection,
          text: '',
          addressOptions: addressOptions,
        ));
        notifyListeners();
      }
    } else {
      await _handleProviderSearch(aiMessage);
    }
  }

  Future<void> selectAddress(AddressOption address) async {
    _bookingState.fullAddress = address.address;
    _waitingForAddressSelection = false;
    _messages.add(ChatMessage(
      id: 'user_addr_${DateTime.now().millisecondsSinceEpoch}',
      type: MessageType.user,
      text: '📍 ${address.title}',
    ));
    _messages.add(ChatMessage(
      id: 'ai_addr_conf_${DateTime.now().millisecondsSinceEpoch}',
      type: MessageType.ai,
      text: 'Using "${address.title}". Finding providers near you...',
    ));
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    await _handleProviderSearch('');
  }

  Future<void> _handleProviderSearch(String aiMessage) async {
    _isSearchingProviders = true;
    _isAiTyping = false;
    _currentOrchestrationSteps = [
      const OrchestrationStep(label: 'Understanding your request...'),
      const OrchestrationStep(label: 'Checking your location...'),
      const OrchestrationStep(label: 'Searching nearby providers...'),
      const OrchestrationStep(label: 'Checking provider availability...'),
      const OrchestrationStep(label: 'Ranking best matches...'),
    ];
    _messages.add(ChatMessage(
      id: 'orch_${DateTime.now().millisecondsSinceEpoch}',
      type: MessageType.orchestration,
      text: 'Processing...',
      orchestrationSteps: List.from(_currentOrchestrationSteps),
    ));
    notifyListeners();

    for (int i = 0; i < _currentOrchestrationSteps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      _currentOrchestrationSteps[i] =
          _currentOrchestrationSteps[i].copyWith(completed: true);
      notifyListeners();
    }

    _providers = ProviderMatchingService.searchProviders(_bookingState);
    await Future.delayed(const Duration(milliseconds: 400));
    _isSearchingProviders = false;

    if (_providers.isNotEmpty) {
      _mapVisible = true;
      final availableCount = _providers.where((p) => p.available).length;
      _messages.add(ChatMessage(
        id: 'ai_results_${DateTime.now().millisecondsSinceEpoch}',
        type: MessageType.ai,
        text: 'I found ${_providers.length} ${_bookingState.service?.toLowerCase() ?? "service"} '
            'providers near you. $availableCount available at your requested time:',
      ));
      _messages.add(ChatMessage(
        id: 'providers_${DateTime.now().millisecondsSinceEpoch}',
        type: MessageType.providerCards,
        text: '',
        providers: _providers,
      ));
    } else {
      _messages.add(ChatMessage(
        id: 'ai_noresult_${DateTime.now().millisecondsSinceEpoch}',
        type: MessageType.ai,
        text: 'No providers found for that service in your area. Try a different service or location?',
      ));
    }
    notifyListeners();
  }

  void selectProvider(ProviderResult provider) {
    _selectedProvider = provider;
    _bookingState.selectedProviderId = provider.id;
    _messages.add(ChatMessage(
      id: 'ai_selected_${DateTime.now().millisecondsSinceEpoch}',
      type: MessageType.ai,
      text: 'You selected ${provider.name} '
          '(⭐ ${provider.rating}, ${provider.distanceKm} km, ~${provider.etaMinutes} min).\n\n'
          '• Describe the issue in detail\n'
          '• Add special instructions\n'
          '• Or tap "Confirm Booking" below',
    ));
    notifyListeners();
  }

  Future<void> confirmBooking() async {
    if (_selectedProvider == null) return;
    final addr = _bookingState.fullAddress ??
        [_bookingState.area,
         if (_bookingState.phase != null) 'Phase ${_bookingState.phase}',
         if (_bookingState.street != null) 'Street ${_bookingState.street}',
        ].where((s) => s != null).join(', ');
    final draft = BookingDraft(
      providerId: _selectedProvider!.id,
      providerName: _selectedProvider!.name,
      service: _bookingState.service ?? 'Service',
      address: addr,
      dateTime: '${_bookingState.date ?? "TBD"} at ${_bookingState.time ?? "TBD"}',
      issue: _bookingState.issueDescription,
      status: 'confirmed',
    );

    // Resolve standard icon based on category
    IconData resolvedIcon = Icons.build_circle_outlined;
    final svcLower = (draft.service).toLowerCase();
    if (svcLower.contains('clean')) {
      resolvedIcon = Icons.cleaning_services_outlined;
    } else if (svcLower.contains('plumb')) {
      resolvedIcon = Icons.plumbing;
    } else if (svcLower.contains('electri')) {
      resolvedIcon = Icons.electrical_services;
    } else if (svcLower.contains('repair') || svcLower.contains('fix') || svcLower.contains('ac')) {
      resolvedIcon = Icons.handyman_outlined;
    } else if (svcLower.contains('heat')) {
      resolvedIcon = Icons.local_fire_department;
    }

    // Resolve date string to DateTime object
    DateTime resolvedDate = DateTime.now().add(const Duration(days: 1)); // default tomorrow
    final dateStr = (_bookingState.date ?? '').toLowerCase();
    if (dateStr.contains('today')) {
      resolvedDate = DateTime.now();
    } else if (dateStr.contains('tomorrow')) {
      resolvedDate = DateTime.now().add(const Duration(days: 1));
    } else {
      final parsed = DateTime.tryParse(_bookingState.date ?? '');
      if (parsed != null) {
        resolvedDate = parsed;
      }
    }

    final bookingId = 'ai_${DateTime.now().millisecondsSinceEpoch}';
    final realBooking = Booking(
      id: bookingId,
      serviceName: draft.service,
      providerName: draft.providerName,
      clientName: MockData.currentUserName,
      status: 'Upcoming',
      date: resolvedDate,
      time: _bookingState.time ?? '12:00 PM',
      icon: resolvedIcon,
      description: _bookingState.issueDescription ?? 'Booked via HelperHive AI Concierge',
      imagePaths: List.from(_bookingState.images),
    );

    try {
      await MockData.addBooking(realBooking);

      _messages.add(ChatMessage(
        id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
        type: MessageType.bookingConfirmation,
        text: '✅ Booking Confirmed!\n\n'
            '📋 Service: ${draft.service}\n'
            '👤 Provider: ${draft.providerName}\n'
            '📍 Address: ${draft.address}\n'
            '📅 When: ${draft.dateTime}\n'
            '${draft.issue != null ? "🔧 Issue: ${draft.issue}\n" : ""}'
            '\nYour provider will be notified!',
        bookingDraft: draft,
      ));
      _bookingConfirmed = true;
    } catch (e) {
      _messages.add(ChatMessage(
        id: 'booking_error_${DateTime.now().millisecondsSinceEpoch}',
        type: MessageType.ai,
        text: "Sorry, I couldn't complete the booking due to a scheduling conflict: ${e.toString().replaceAll("Exception: ", "")}. Please choose a different slot.",
      ));
      _bookingConfirmed = false;
    }
    notifyListeners();
  }

  /// Show update options to user.
  void startBookingUpdate() {
    _bookingConfirmed = false;
    _messages.add(ChatMessage(
      id: 'ai_update_${DateTime.now().millisecondsSinceEpoch}',
      type: MessageType.ai,
      text: 'What would you like to update?',
    ));
    _messages.add(ChatMessage(
      id: 'ai_update_opts_${DateTime.now().millisecondsSinceEpoch}',
      type: MessageType.updateOptions,
      text: '',
    ));
    notifyListeners();
  }

  /// Clear a specific booking field and let the AI re-ask for it.
  void updateField(String field) {
    _selectedProvider = null;
    _providers.clear();
    _mapVisible = false;

    String clearedLabel;
    switch (field) {
      case 'time':
        _bookingState.time = null;
        _bookingState.date = null;
        clearedLabel = 'date & time';
        break;
      case 'location':
        _bookingState.fullAddress = null;
        _bookingState.area = null;
        _bookingState.phase = null;
        _bookingState.street = null;
        clearedLabel = 'location';
        break;
      case 'provider':
        _bookingState.selectedProviderId = null;
        clearedLabel = 'provider';
        break;
      case 'service':
        _bookingState.service = null;
        clearedLabel = 'service type';
        break;
      default:
        clearedLabel = field;
    }

    _messages.add(ChatMessage(
      id: 'user_upd_${DateTime.now().millisecondsSinceEpoch}',
      type: MessageType.user,
      text: 'I want to change the $clearedLabel',
    ));

    // Now send through the AI to re-ask for the missing field
    sendMessage('I want to change the $clearedLabel');
  }

  void resetConversation() {
    _messages.clear();
    _providers.clear();
    _selectedProvider = null;
    _isAiTyping = false;
    _isSearchingProviders = false;
    _mapVisible = false;
    _bookingConfirmed = false;
    _waitingForAddressSelection = false;
    _currentOrchestrationSteps.clear();
    _bookingState.service = null;
    _bookingState.area = null;
    _bookingState.phase = null;
    _bookingState.street = null;
    _bookingState.fullAddress = null;
    _bookingState.date = null;
    _bookingState.time = null;
    _bookingState.issueDescription = null;
    _bookingState.urgency = null;
    _bookingState.selectedProviderId = null;
    _bookingState.images = const [];
    _geminiService.resetConversation();
    _messages.add(ChatMessage(
      id: 'welcome',
      type: MessageType.ai,
      text: 'Hi! 👋 I\'m your HelperHive assistant. '
          'Tell me what service you need and I\'ll find the best provider near you.\n\n'
          'For example: "I need a plumber tomorrow at 2 PM"',
    ));
    notifyListeners();
  }
}
