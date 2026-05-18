import 'package:flutter/material.dart';
import '../core/data/mock_data.dart';
import '../core/theme/app_colors.dart';
import '../models/service_provider.dart';
import 'service_detail_screen.dart';

// This is the AI-Powered Service Search Screen (Dashboard V2)
class AiServiceSearchScreen extends StatefulWidget {
  const AiServiceSearchScreen({super.key});

  @override
  State<AiServiceSearchScreen> createState() =>
      _AiServiceSearchScreenState();
}

class _AiServiceSearchScreenState
    extends State<AiServiceSearchScreen> {
  final TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatItem> messages = [];

  bool showMap = false;
  bool showTyping = false;
  bool providerSelected = false;
  bool _isMapExpanded = false;
  int _orchestrationStep = 0; // 0: Understanding, 1: Finding, 2: Checking, 3: Ranking

  int selectedMapStyle = 0;

  final List<String> mapStyles = [
    "Apple Style",
    "Dark AI",
    "Google Maps",
    "Soft Green",
  ];

  @override
  void initState() {
    super.initState();

    messages.add(
      ChatItem(
        isAi: true,
        message:
            "Hi 👋 Tell me what service you need and I’ll find the best nearby provider for you.",
      ),
    );
  }

  void sendMessage() async {
    if (controller.text.trim().isEmpty) return;

    String userMessage = controller.text.trim();

    setState(() {
      messages.add(
        ChatItem(
          isAi: false,
          message: userMessage,
        ),
      );

      showTyping = true;
    });

    controller.clear();

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      showTyping = false;
      messages.add(ChatItem(isAi: true, isOrchestrating: true));
    });

    // Simulate orchestration steps
    for (int i = 0; i < 4; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      setState(() => _orchestrationStep = i);
      _scrollToBottom();
    }

    await Future.delayed(const Duration(milliseconds: 400));

    final query = userMessage.toLowerCase();
    final categories = MockData.providers.map((p) => p.category.toLowerCase()).toSet();
    bool foundMatch = false;
    
    for (var cat in categories) {
      if (query.contains(cat) || query.contains(cat.replaceAll('ing', ''))) {
        foundMatch = true;
        break;
      }
    }

    // Default to showing results if they ask for any service or common terms
    if (foundMatch || query.contains("service") || query.contains("help") || query.contains("someone")) {
      setState(() {
        showMap = true;

        messages.add(
          ChatItem(
            isAi: true,
            message: "I found some great professionals nearby who can help with your request!",
          ),
        );

        messages.add(
          ChatItem(
            isAi: true,
            isProviderCards: true,
          ),
        );
      });
    } else {
      setState(() {
        messages.add(
          ChatItem(
            isAi: true,
            message: "I'm not sure which service you need. Could you specify if you need cleaning, repairs, or another service?",
          ),
        );
      });
    }
    
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void selectProvider(ServiceProvider provider) {
    // Navigate to the actual service provider detail page
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
                      Text(
                        "Lahore, Pakistan",
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: dark ? Colors.white : Colors.black),
                      ),
                      const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
                    ],
                  ),
                ],
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
            GestureDetector(
              onTap: () => setState(() => _isMapExpanded = !_isMapExpanded),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                height: _isMapExpanded ? 300 : 140, // Interactive expansion
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                  gradient: LinearGradient(
                    colors: dark
                        ? [const Color(0xFF1A1A1A), const Color(0xFF111111)]
                        : [Colors.green.shade50, Colors.white],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    children: [
                      // Better Map Visual Mock
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.1,
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 10),
                            itemBuilder: (context, index) => Container(decoration: BoxDecoration(border: Border.all(color: dark ? Colors.white10 : Colors.green.withOpacity(0.1)))),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: _isMapExpanded ? 60 : 40,
                              color: AppColors.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isMapExpanded ? "Explore Nearby Professionals" : "Tap to expand map",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: dark ? Colors.white38 : Colors.green.shade300,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "LIVE",
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      // Mock Pins
                      Positioned(bottom: 40, left: 60, child: mockPin()),
                      Positioned(top: 60, right: 80, child: mockPin()),
                      Positioned(bottom: 20, right: 40, child: mockPin(active: true)),
                    ],
                  ),
                ),
              ),
            ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              itemCount:
                  messages.length + (showTyping ? 2 : 1), // Added one for spacer
              itemBuilder: (context, index) {
                if (index == messages.length + (showTyping ? 1 : 0)) {
                  return const SizedBox(height: 40); // Spacer at the end
                }

                if (showTyping &&
                    index == messages.length) {
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
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
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
                        child: Text(
                          item.message ?? "",
                          style: TextStyle(
                            color: isAi ? (dark ? Colors.white : Colors.black87) : Colors.white,
                            height: 1.5,
                            fontSize: 15,
                          ),
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
                              decoration: const InputDecoration(
                                hintText: "Type your message...",
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
      {'label': 'Checking Availability', 'icon': Icons.calendar_today},
      {'label': 'Ranking Results', 'icon': Icons.star_outline},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
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
                    child: Container(height: 1, color: isCompleted ? Colors.green : Colors.grey.withOpacity(0.3)),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget providerCardsSection() {
    // We use the real providers from MockData for these cards
    final List<ServiceProvider> displayProviders = MockData.providers.take(2).toList();
    
    return Column(
      children: displayProviders.map((p) => providerCard(p)).toList(),
    );
  }

  Widget providerCard(ServiceProvider provider) {
    bool dark = Theme.of(context).brightness == Brightness.dark;
    bool isTopMatch = provider.rating >= 4.8;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF252525) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage("https://i.pravatar.cc/150?u=${provider.id}"),
                    fit: BoxFit.cover,
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
                        Text(provider.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const Spacer(),
                        if (isTopMatch)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: const Text("Top Match", style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text("${provider.rating} (128)", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const SizedBox(width: 8),
                        const Icon(Icons.circle, size: 4, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text("1.2 km away", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 14, color: Colors.green.shade600),
                        const SizedBox(width: 4),
                        Text("Can arrive in 25 mins", style: TextStyle(color: Colors.green.shade600, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => selectProvider(provider),
                icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Text("From ", style: TextStyle(color: Colors.grey, fontSize: 14)),
              const Text("\$20", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Spacer(),
              const Text("Tap to view profile", style: TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget aiThinkingWidget() {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).cardColor,
      ),
      child: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text("AI Orchestrating...", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          SizedBox(height: 12),
          Text("• Understanding request"),
          Text("• Extracting location"),
          Text("• Searching providers"),
          Text("• Ranking best matches"),
        ],
      ),
    );
  }

  Widget mockPin({bool active = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 28 : 22,
      height: active ? 28 : 22,
      decoration: BoxDecoration(
        color:
            active ? Colors.green : Colors.greenAccent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(.4),
            blurRadius: 12,
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

  ChatItem({
    required this.isAi,
    this.message,
    this.isProviderCards = false,
    this.isOrchestrating = false,
  });
}