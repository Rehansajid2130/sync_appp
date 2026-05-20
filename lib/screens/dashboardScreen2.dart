import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/data/mock_data.dart';
import '../core/theme/app_colors.dart';
import '../models/service_provider.dart';
import 'service_detail_screen.dart';
import 'address_selection_screen.dart';
import 'main_navigation_screen.dart';

// This is the AI-Powered Service Search Screen (Dashboard V2)
class AiServiceSearchScreen extends StatefulWidget {
  const AiServiceSearchScreen({super.key});

  @override
  State<AiServiceSearchScreen> createState() => _AiServiceSearchScreenState();
}

class _AiServiceSearchScreenState extends State<AiServiceSearchScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MapController _mapController = MapController();

  final List<ChatItem> messages = [];

  bool showMap = false;
  bool showTyping = false;
  bool _isMapExpanded = false;
  int _orchestrationStep = 0; // 0: Understanding, 1: Finding, 2: Checking, 3: Ranking
  String _orchestrationMessage = "AI Agent thinking...";
  LatLng _mapCenter = const LatLng(-6.58913, 106.7262); // Bogor Situ Udik (Default matching MockData)

  int selectedMapStyle = 0;
  final List<String> mapStyles = [
    "Apple Light",
    "Dark AI",
    "Street Maps",
    "Soft Voyager",
  ];

  // Conversation state tracking
  int aiFlowState = 0; 
  // 0 = Initial request input
  // 1 = Location/Address resolution
  // 2 = Issue details clarification
  // 3 = Provider selection
  // 4 = Time slot selection
  // 5 = Booking review & confirmation
  // 6 = Booking success & predicted checklist

  String selectedCategory = "AC Repair";
  IconData categoryIcon = Icons.ac_unit;
  UserAddress? selectedAddress;
  String? selectedIssue;
  ServiceProvider? selectedProvider;
  String? selectedTime;

  @override
  void initState() {
    super.initState();

    // Load coordinates from MockData's active address
    if (MockData.addresses.isNotEmpty) {
      final selected = MockData.addresses.firstWhere((a) => a.isSelected, orElse: () => MockData.addresses.first);
      _mapCenter = LatLng(selected.latitude, selected.longitude);
      selectedAddress = selected;
    }

    messages.add(
      ChatItem(
        isAi: true,
        message: "Hi 👋 I am your HelperHive AI assistant. Tell me what you need help with (e.g. \"My AC is making noise\", \"Need a plumber at DHA\"), and I'll orchestrate the booking for you!",
      ),
    );
  }

  void sendMessage() async {
    if (controller.text.trim().isEmpty) return;
    String userMessage = controller.text.trim();

    setState(() {
      messages.add(ChatItem(isAi: false, message: userMessage));
      showTyping = true;
    });

    controller.clear();
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 800));

    if (aiFlowState == 0) {
      // Step 1: Parse requested intent
      final query = userMessage.toLowerCase();
      if (query.contains("clean") || query.contains("wash") || query.contains("sweep")) {
        selectedCategory = "Cleaning";
        categoryIcon = Icons.cleaning_services_outlined;
      } else if (query.contains("plumb") || query.contains("leak") || query.contains("pipe") || query.contains("sink") || query.contains("water")) {
        selectedCategory = "Plumber";
        categoryIcon = Icons.plumbing;
      } else if (query.contains("electric") || query.contains("wiring") || query.contains("switch") || query.contains("light") || query.contains("fan")) {
        selectedCategory = "Electrician";
        categoryIcon = Icons.electrical_services;
      } else if (query.contains("geyser") || query.contains("heater") || query.contains("boiler")) {
        selectedCategory = "Geyser";
        categoryIcon = Icons.local_fire_department;
      } else {
        selectedCategory = "AC Repair";
        categoryIcon = Icons.ac_unit;
      }

      // Resolve user addresses from MockData
      final mainAddress = MockData.addresses.isNotEmpty 
          ? MockData.addresses.firstWhere((a) => a.isSelected, orElse: () => MockData.addresses.first)
          : null;

      setState(() {
        showTyping = false;
        aiFlowState = 1; // Transition to address resolution
        showMap = true;
        if (mainAddress != null) {
          _mapCenter = LatLng(mainAddress.latitude, mainAddress.longitude);
          selectedAddress = mainAddress;
        }

        messages.add(
          ChatItem(
            isAi: true,
            message: "I detected that you need **$selectedCategory** services! 🛠️\n\nTo find the best nearby providers, should I use your primary address: **${mainAddress?.title ?? 'Home'}**?\n`${mainAddress?.address ?? 'Lahore, Pakistan'}`",
            interactiveType: 'address_resolution',
            options: [
              "Yes, use ${mainAddress?.title ?? 'Home'}",
              if (MockData.addresses.length > 1) "Use ${MockData.addresses.firstWhere((a) => !a.isSelected, orElse: () => MockData.addresses.last).title}",
              "Select custom address",
            ],
          ),
        );
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(_mapCenter, 13.5);
      });

    } else {
      // In other states, parse user's general text input as their clarification detail choice
      setState(() {
        showTyping = false;
      });
      handleInteractiveOption(userMessage, aiFlowState == 1 ? 'address_resolution' : (aiFlowState == 2 ? 'issue_clarification' : 'general'));
    }

    _scrollToBottom();
  }

  void handleInteractiveOption(String option, String type) async {
    setState(() {
      messages.add(ChatItem(isAi: false, message: option));
      showTyping = true;
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 1000));

    setState(() {
      showTyping = false;
    });

    if (type == 'address_resolution') {
      // Handle Address confirmation
      UserAddress resolved = MockData.addresses.first;
      if (option.contains("Apartment") || option.toLowerCase().contains("apartment")) {
        resolved = MockData.addresses.firstWhere((a) => a.title.contains("Apartment"), orElse: () => MockData.addresses.first);
      } else {
        resolved = MockData.addresses.firstWhere((a) => a.isSelected, orElse: () => MockData.addresses.first);
      }

      setState(() {
        selectedAddress = resolved;
        _mapCenter = LatLng(resolved.latitude, resolved.longitude);
        aiFlowState = 2; // Transition to issue details

        String followUpMessage = "Got it! Let's use **${resolved.title}**.\n\nTo help the professional prepare the correct tools and give an accurate estimation, could you specify the exact issue with your **$selectedCategory**?";

        List<String> options = [];
        if (selectedCategory == "AC Repair") {
          options = ['Not cooling at all', 'Making a loud noise', 'Not turning on', 'Water leaking', 'Other/General service'];
        } else if (selectedCategory == "Cleaning") {
          options = ['Deep home cleaning', 'Kitchen deep sanitization', 'Sofa & Carpet cleaning', 'Post-renovation cleaning'];
        } else if (selectedCategory == "Plumber") {
          options = ['Water pipe leaking', 'Low tap pressure', 'Blocked drain/toilet', 'Install new taps/sinks'];
        } else {
          options = ['Short circuit/Tripping', 'Install ceiling fan', 'Light fixtures & bulbs', 'Replace socket boards'];
        }

        messages.add(
          ChatItem(
            isAi: true,
            message: followUpMessage,
            interactiveType: 'issue_clarification',
            options: options,
          ),
        );
      });

      _mapController.move(_mapCenter, 14.5);

    } else if (type == 'issue_clarification') {
      // Handle issue clarification
      setState(() {
        selectedIssue = option;
        aiFlowState = 3; // Transition to provider search list

        messages.add(
          ChatItem(
            isAi: true,
            message: "I found the best local matching professionals for **$selectedCategory** near your location! Here are the top matches ranked by proximity, specialized skillsets, and ratings:",
          ),
        );

        messages.add(
          ChatItem(
            isAi: true,
            isProviderCards: true,
          ),
        );
      });

    } else if (type == 'provider_selection') {
      // Handle provider selection
      final providerId = option;
      final provider = MockData.providers.firstWhere((p) => p.id == providerId, orElse: () => MockData.providers.first);

      setState(() {
        selectedProvider = provider;
        aiFlowState = 4; // Transition to time selection

        List<String> timeSlots = [];
        if (provider.availableTimes.isNotEmpty) {
          timeSlots = provider.availableTimes.map((t) => "Tomorrow - $t").toList();
        } else {
          timeSlots = ['Tomorrow - 09:00 AM', 'Tomorrow - 11:00 AM', 'Tomorrow - 02:00 PM', 'Tomorrow - 04:00 PM'];
        }

        messages.add(
          ChatItem(
            isAi: true,
            message: "Excellent choice! **${provider.name}** is a highly rated specialist in our database.\n\nWhen would you like **${provider.name}** to arrive at your address?",
            interactiveType: 'time_selection',
            options: timeSlots,
          ),
        );
      });

    } else if (type == 'time_selection') {
      // Handle time slot selection
      setState(() {
        selectedTime = option;
        aiFlowState = 5; // Transition to booking review & confirmation

        messages.add(
          ChatItem(
            isAi: true,
            message: "Wonderful! I have reserved that slot. Let's verify all details before dispatching the request to the provider:",
            interactiveType: 'booking_confirmation',
          ),
        );
      });

    } else if (type == 'booking_confirmation') {
      if (option == "Cancel & Restart") {
        setState(() {
          aiFlowState = 0;
          showMap = false;
          messages.clear();
          messages.add(
            ChatItem(
              isAi: true,
              message: "Let's restart! Tell me what service you need and I'll find the best provider for you.",
            ),
          );
        });
      } else {
        // Confirm & create booking
        setState(() {
          showTyping = true;
        });

        await Future.delayed(const Duration(milliseconds: 1500));

        try {
          String serviceName = selectedCategory;
          if (selectedIssue != null && selectedIssue!.isNotEmpty) {
            serviceName += " - $selectedIssue";
          }

          String timeVal = "10:00 AM";
          int daysToAdd = 1;
          if (selectedTime != null) {
            daysToAdd = selectedTime!.contains("Tomorrow") ? 1 : 0;
            timeVal = selectedTime!.replaceAll("Tomorrow - ", "").replaceAll("Today - ", "");
          }

          // Create actual Booking in storage so it updates classic lists
          final finalBooking = Booking(
            id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
            serviceName: serviceName,
            providerName: selectedProvider?.name ?? "James Anderson",
            clientName: MockData.currentUserName,
            status: 'Pending',
            date: DateTime.now().add(Duration(days: daysToAdd)),
            time: timeVal,
            icon: categoryIcon,
            description: "AI-Parsed Request: client reports that the $selectedCategory is '${selectedIssue ?? 'General Service Request'}'. Primary address: ${selectedAddress?.title ?? 'Home'}.",
          );

          await MockData.addBooking(finalBooking);

          setState(() {
            showTyping = false;
            aiFlowState = 6; // Success state with provider briefing & tool prediction

            messages.add(
              ChatItem(
                isAi: true,
                message: "Your booking has been successfully dispatched! 🎉\n\nYour job request is now **Pending** with **${selectedProvider?.name ?? 'James Anderson'}**, who has been alerted on their provider dashboard.\n\nTo optimize efficiency, our AI parsed the request details and transmitted the following briefing and material recommendations directly to the specialist:",
                interactiveType: 'booking_success',
              ),
            );
          });
        } catch (e, stack) {
          debugPrint("AI Confirm Booking Error: $e\n$stack");
          setState(() {
            showTyping = false;
            // Do not advance aiFlowState to 6, keep it at 5 so they can retry/adjust
            messages.add(
              ChatItem(
                isAi: true,
                message: "Sorry, I couldn't complete the booking due to a scheduling conflict: ${e.toString().replaceAll("Exception: ", "")}. Please choose a different slot.",
              ),
            );
          });
        }
      }
    } else if (type == 'booking_success') {
      // Reset chatbot conversation flow to allow booking another service
      setState(() {
        aiFlowState = 0;
        showMap = false;
        selectedCategory = "AC Repair";
        selectedAddress = null;
        selectedIssue = null;
        selectedProvider = null;
        selectedTime = null;
        messages.clear();
        messages.add(
          ChatItem(
            isAi: true,
            message: "Hi 👋 I am your HelperHive AI assistant. Tell me what you need help with (e.g. \"My AC is making noise\", \"Need a plumber at DHA\"), and I'll orchestrate the booking for you!",
          ),
        );
      });
    } else {
      // Handle fallback/unrecognized text inputs in conversation
      setState(() {
        messages.add(
          ChatItem(
            isAi: true,
            message: "I didn't quite catch that. Could you select one of the interactive options above, or describe the service you need again?",
          ),
        );
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        // A secondary micro-deferred jump handles the dynamic layout growth of cards
        Future.delayed(const Duration(milliseconds: 50), () {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    });
  }

  void selectProviderDirectly(ServiceProvider provider) {
    // Used when tapping map marker directly
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailScreen(provider: provider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool dark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 80,
        backgroundColor: dark ? const Color(0xFF111111) : Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.green.withOpacity(.1),
              child: const Icon(Icons.person, color: Colors.green, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddressSelectionScreen()),
                  );
                  setState(() {
                    if (MockData.addresses.isNotEmpty) {
                      final selected = MockData.addresses.firstWhere((a) => a.isSelected, orElse: () => MockData.addresses.first);
                      _mapCenter = LatLng(selected.latitude, selected.longitude);
                      selectedAddress = selected;
                      _mapController.move(_mapCenter, 13.5);
                    }
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello ${MockData.currentUserName.split(' ').first} 👋",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: dark ? Colors.white70 : Colors.black54),
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 12, color: Colors.green.shade600),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            selectedAddress?.title ?? (MockData.addresses.isNotEmpty 
                                ? MockData.addresses.firstWhere((a) => a.isSelected, orElse: () => MockData.addresses.first).title
                                : "Lahore, Pakistan"),
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: dark ? Colors.white : Colors.black),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _buildHeaderAction(Icons.search, Colors.green, true),
            const SizedBox(width: 8),
            _buildHeaderAction(Icons.notifications_none, dark ? Colors.white10 : Colors.grey.shade100, false),
          ],
        ),
      ),
      body: Column(
        children: [
          if (showMap)
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              height: _isMapExpanded ? 320 : 150, // Expanded height
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _mapCenter,
                          initialZoom: 13.5,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: selectedMapStyle == 0
                                ? 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png'
                                : selectedMapStyle == 1
                                    ? 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png'
                                    : selectedMapStyle == 2
                                        ? 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
                                        : 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.helperhive.app',
                          ),
                          MarkerLayer(
                            markers: [
                              // Resolved client location pin
                              Marker(
                                point: _mapCenter,
                                width: 45,
                                height: 45,
                                child: const Icon(Icons.my_location, color: Colors.blue, size: 28),
                              ),
                              // Live dynamic nearby provider pins matching selected Category with dynamic spacing
                              ...MockData.providers.where((p) {
                                final categoryLower = p.category.toLowerCase();
                                final selectedLower = selectedCategory.toLowerCase();
                                return categoryLower == selectedLower ||
                                       (selectedLower == "ac repair" && categoryLower == "repairing") ||
                                       (selectedLower == "plumbing" && categoryLower == "plumber") ||
                                       (selectedLower == "plumber" && categoryLower == "plumbing") ||
                                       (selectedLower == "electrician" && categoryLower == "electrical") ||
                                       (selectedLower == "electrical" && categoryLower == "electrician") ||
                                       (selectedLower == "geyser" && categoryLower == "heating") ||
                                       (selectedLower == "heating" && categoryLower == "geyser");
                              }).toList().asMap().entries.map((entry) {
                                final int index = entry.key;
                                final ServiceProvider p = entry.value;

                                // Dynamically distribute coordinates around the user center beautifully
                                double latOffset = 0.0;
                                double lngOffset = 0.0;
                                if (index == 0) {
                                  latOffset = 0.003; lngOffset = -0.004;
                                } else if (index == 1) {
                                  latOffset = -0.004; lngOffset = 0.003;
                                } else if (index == 2) {
                                  latOffset = 0.004; lngOffset = 0.005;
                                } else if (index == 3) {
                                  latOffset = -0.003; lngOffset = -0.005;
                                } else if (index == 4) {
                                  latOffset = 0.002; lngOffset = 0.006;
                                } else if (index == 5) {
                                  latOffset = -0.005; lngOffset = -0.002;
                                } else if (index == 6) {
                                  latOffset = 0.005; lngOffset = -0.003;
                                } else {
                                  latOffset = -0.002; lngOffset = 0.004 + ((index - 7) * 0.0015);
                                }
                                final LatLng pos = LatLng(_mapCenter.latitude + latOffset, _mapCenter.longitude + lngOffset);

                                return Marker(
                                  point: pos,
                                  width: 44,
                                  height: 44,
                                  child: GestureDetector(
                                    onTap: () => selectProviderDirectly(p),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: p.avatarColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(categoryIcon, color: Colors.white, size: 18),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Expand/Collapse overlay button
                    Positioned(
                      top: 12,
                      left: 12,
                      child: GestureDetector(
                        onTap: () => setState(() => _isMapExpanded = !_isMapExpanded),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: dark ? const Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 4),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isMapExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                                size: 16,
                                color: dark ? Colors.white70 : Colors.black87,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isMapExpanded ? "Collapse" : "Expand",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: dark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Live status indicator
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "AI SEARCH MAP",
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // Map Style Toggler overlay
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedMapStyle = (selectedMapStyle + 1) % mapStyles.length;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: dark ? const Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: dark ? Colors.white12 : Colors.black.withOpacity(0.05)),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 6),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.layers_outlined, size: 16, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                mapStyles[selectedMapStyle],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: dark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              itemCount: messages.length + (showTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (showTyping && index == messages.length) {
                  return aiThinkingWidget();
                }

                final item = messages[index];

                if (item.isOrchestrating) {
                  return _buildOrchestrationTimeline(dark);
                }

                if (item.isProviderCards) {
                  return providerCardsSection();
                }

                bool isAi = item.isAi;
                return Align(
                  alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                    children: [
                      if (isAi)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 4),
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.green.withOpacity(0.1),
                            child: const Icon(Icons.smart_toy_outlined, color: Colors.green, size: 14),
                          ),
                        ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                        decoration: BoxDecoration(
                          color: isAi 
                              ? (dark ? const Color(0xFF1E1E1E) : Colors.grey.shade100)
                              : AppColors.primary,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(24),
                            topRight: const Radius.circular(24),
                            bottomLeft: Radius.circular(isAi ? 4 : 24),
                            bottomRight: Radius.circular(isAi ? 24 : 4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.message ?? "",
                              style: TextStyle(
                                color: isAi ? (dark ? Colors.white : Colors.black87) : Colors.white,
                                height: 1.5,
                                fontSize: 15,
                              ),
                            ),
                            // Render custom interactive controls for that message bubble if needed
                            if (item.interactiveType != null) ...[
                              const SizedBox(height: 12),
                              _buildInteractiveOptions(item, dark),
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: dark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: dark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                      ),
                      child: Row(
                        children: [
                          IconButton(onPressed: () {}, icon: const Icon(Icons.attach_file, size: 20, color: Colors.grey)),
                          Expanded(
                            child: TextField(
                              controller: controller,
                              onSubmitted: (_) => sendMessage(),
                              decoration: const InputDecoration(
                                hintText: "Describe what you need here...",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                          ),
                          IconButton(onPressed: () {}, icon: const Icon(Icons.mic_none, size: 22, color: Colors.green)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.green,
                    child: IconButton(
                      onPressed: sendMessage,
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveOptions(ChatItem item, bool dark) {
    final type = item.interactiveType;
    final options = item.options ?? [];

    if (type == 'address_resolution' || type == 'issue_clarification' || type == 'time_selection') {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((opt) {
          return InkWell(
            onTap: () => handleInteractiveOption(opt, type ?? ''),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Text(
                opt,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    if (type == 'booking_confirmation') {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF282828) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: dark ? Colors.white12 : Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(categoryIcon, color: Colors.green, size: 18),
                const SizedBox(width: 8),
                Text(
                  "$selectedCategory Booking Brief",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildBriefRow(Icons.location_on_outlined, "Address", selectedAddress?.title ?? "Home"),
            _buildBriefRow(Icons.warning_amber_outlined, "Issue Reported", selectedIssue ?? "General"),
            _buildBriefRow(Icons.person_outline, "Provider Match", selectedProvider?.name ?? "James Anderson"),
            _buildBriefRow(Icons.access_time_outlined, "Schedule", selectedTime ?? "Tomorrow 10:00 AM"),
            _buildBriefRow(Icons.payments_outlined, "Est. Cost Range", "\$25 - \$40"),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => handleInteractiveOption("Confirm & Dispatch ⚡", 'booking_confirmation'),
                    child: const Text("Confirm & Dispatch ⚡", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => handleInteractiveOption("Cancel & Restart", 'booking_confirmation'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.restart_alt, color: Colors.red, size: 20),
                  ),
                )
              ],
            )
          ],
        ),
      );
    }

    if (type == 'booking_success') {
      // Predict materials list based on selected category
      List<String> tools = [];
      if (selectedCategory == "AC Repair") {
        tools = ['R-410a Refrigerant Canister', 'Digital Manifold Gauge Set', '45uF Starter Run Capacitor', 'Insulated Ratchet Wrench'];
      } else if (selectedCategory == "Plumber") {
        tools = ['Teflon Thread Seal Tape', 'Adjustable Pipe Wrench', 'Silicone Caulking Sealant', 'Sink Pipe Drain Trap'];
      } else if (selectedCategory == "Electrician") {
        tools = ['Digital Multimeter Tester', 'Heavy-Duty Insulated Screwdrivers', '20Amp Circuit Breaker Switch', 'Black PVC Electrical Tape'];
      } else {
        tools = ['Microfiber Dusters', 'Neutral pH Floor Cleaner', 'HEPA Filtered Dry Vacuum', 'Heavy Duty Latex Gloves'];
      }

      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF282828) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.withOpacity(0.4), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.terminal, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text(
                  "AI Briefing & Tool Prediction",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              "📝 PROVIDER BRIEF SUMMARY",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 4),
            Text(
              "\"Client at ${selectedAddress?.title} reported $selectedCategory is '$selectedIssue'. Urgency Level: High. ETA dispatched: $selectedTime.\"",
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 14),
            Text(
              "🛠 PREDICTED MATERIALS & CHECKLIST",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 6),
            ...tools.map((tool) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.green, size: 14),
                  const SizedBox(width: 6),
                  Text(tool, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            )),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => MainNavigationScreen.of(context)?.setIndex(1),
                    child: const Text("View My Bookings 📅", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => handleInteractiveOption("Book Another Service", 'booking_success'),
                  child: const Text("Book Another", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                )
              ],
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildBriefRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction(IconData icon, Color bgColor, bool isPrimary) {
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(icon, color: isPrimary ? Colors.white : Colors.grey, size: 22),
    );
  }

  Widget _buildOrchestrationTimeline(bool dark) {
    final steps = [
      {'label': 'Understanding', 'icon': Icons.psychology_outlined},
      {'label': 'Finding Providers', 'icon': Icons.search},
      {'label': 'Checking Schedule', 'icon': Icons.calendar_today},
      {'label': 'Ranking Results', 'icon': Icons.star_outline},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 14, height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
              ),
              const SizedBox(width: 8),
              Text(
                _orchestrationMessage,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (index) {
              bool isCompleted = index <= _orchestrationStep;
              return Expanded(
                child: Column(
                  children: [
                    Icon(
                      steps[index]['icon'] as IconData,
                      size: 20,
                      color: isCompleted ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      steps[index]['label'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                        color: isCompleted ? Colors.green : Colors.grey,
                      ),
                    ),
                    if (index < steps.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Container(height: 2, color: isCompleted ? Colors.green : Colors.grey.withOpacity(0.3)),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget providerCardsSection() {
    // Generate matches dynamically based on the selectedCategory
    final List<ServiceProvider> displayProviders = MockData.providers.where((p) {
      final categoryLower = p.category.toLowerCase();
      final selectedLower = selectedCategory.toLowerCase();
      return categoryLower == selectedLower ||
             (selectedLower == "ac repair" && categoryLower == "repairing") ||
             (selectedLower == "plumbing" && categoryLower == "plumber") ||
             (selectedLower == "plumber" && categoryLower == "plumbing") ||
             (selectedLower == "electrician" && categoryLower == "electrical") ||
             (selectedLower == "electrical" && categoryLower == "electrician") ||
             (selectedLower == "geyser" && categoryLower == "heating") ||
             (selectedLower == "heating" && categoryLower == "geyser");
    }).map((p) {
      return ServiceProvider(
        id: p.id,
        name: p.name,
        category: selectedCategory,
        rating: p.rating,
        reviewCount: p.reviewCount,
        location: p.location,
        icon: categoryIcon,
        avatarColor: p.avatarColor,
        availableTimes: p.availableTimes,
      );
    }).toList();

    if (displayProviders.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF252525) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: const Center(
          child: Text(
            "No matching service providers found nearby.",
            style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    return Column(
      children: displayProviders.map((p) => providerCard(p)).toList(),
    );
  }

  Widget providerCard(ServiceProvider provider) {
    bool dark = Theme.of(context).brightness == Brightness.dark;
    bool isTopMatch = provider.rating >= 4.8;

    // Build unique initials for a beautiful premium letter badge
    final initials = provider.name.split(' ').map((word) => word.isNotEmpty ? word[0] : '').take(2).join('');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF252525) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: dark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [
                      provider.avatarColor.withOpacity(0.85),
                      provider.avatarColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: provider.avatarColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(provider.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const Spacer(),
                        if (isTopMatch)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.green.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
                            child: const Text("98% Match", style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text("${provider.rating} (${provider.reviewCount})", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(width: 8),
                        const Icon(Icons.circle, size: 4, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text("1.2 km away", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.green.shade600),
                        const SizedBox(width: 4),
                        Text("Can arrive in 20 mins", style: TextStyle(color: Colors.green.shade600, fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            children: [
              const Text("Est. Hourly ", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const Text("\$25", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                ),
                onPressed: () => handleInteractiveOption(provider.id, 'provider_selection'),
                child: Text("Select ${provider.name.split(' ').first}", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget aiThinkingWidget() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: CircleAvatar(
              radius: 12,
              backgroundColor: Colors.green.withOpacity(0.1),
              child: const Icon(Icons.smart_toy_outlined, color: Colors.green, size: 14),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14, height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
                ),
                const SizedBox(width: 10),
                Text(
                  "AI agent typing...",
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatItem {
  final bool isAi;
  final String? message;
  final bool isProviderCards;
  final bool isOrchestrating;
  final String? interactiveType;
  final List<String>? options;
  final Map<String, dynamic>? data;

  ChatItem({
    required this.isAi,
    this.message,
    this.isProviderCards = false,
    this.isOrchestrating = false,
    this.interactiveType,
    this.options,
    this.data,
  });
}