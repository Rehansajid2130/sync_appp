import 'package:flutter/material.dart';
import 'core/services/storage_service.dart';
import 'core/data/mock_data.dart';
import 'package:provider/provider.dart';
import 'ai/state/chat_state.dart';
import 'ai/screens/ai_chat_screen.dart';

/// Separate entry point for testing the AI chat feature in isolation.
/// Run with: flutter run -t lib/main_ai.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await MockData.init();
  runApp(const AiTestApp());
}

class AiTestApp extends StatelessWidget {
  const AiTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HelperHive AI Test',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true,
      ),
      home: const ApiKeyScreen(),
    );
  }
}

/// Simple screen to enter the Gemini API key before launching the chat.
/// If left empty, it runs in mock mode.
class ApiKeyScreen extends StatefulWidget {
  const ApiKeyScreen({super.key});

  @override
  State<ApiKeyScreen> createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends State<ApiKeyScreen> {
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load saved API key if exists
    final saved = StorageService.getData('gemini_api_key');
    if (saved != null) {
      _apiKeyController.text = saved;
    }
  }

  void _launchChat({bool mockMode = false}) async {
    final apiKey = mockMode ? '' : _apiKeyController.text.trim();

    // Save API key for next time
    if (apiKey.isNotEmpty) {
      await StorageService.saveData('gemini_api_key', apiKey);
    }

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) {
            final state = ChatState();
            state.initialize(apiKey);
            return state;
          },
          child: const AiChatScreen(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HelperHive AI Setup')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'AI Conversational Booking',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your Gemini API key to use real AI, '
              'or skip to use mock mode (offline).',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'Gemini API Key',
                hintText: 'AIzaSy...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.key),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _launchChat(),
              icon: const Icon(Icons.smart_toy),
              label: const Text('Start with Gemini AI'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _launchChat(mockMode: true),
              icon: const Icon(Icons.science),
              label: const Text('Start in Mock Mode (No API Key)'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Mock Data Status',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('Providers loaded: ${MockData.providers.length}'),
            Text('Categories: ${MockData.providers.map((p) => p.category).toSet().join(", ")}'),
            Text('User: ${MockData.currentUserName}'),
          ],
        ),
      ),
    );
  }
}
