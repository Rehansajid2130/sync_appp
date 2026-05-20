import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:cross_file/cross_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../models/chat_models.dart';
import '../state/chat_state.dart';
import '../widgets/ai_map_widget.dart';
import '../widgets/provider_card_widget.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  late ChatState _chatState;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _chatState = Provider.of<ChatState>(context, listen: false);
    _chatState.addListener(_onStateChanged);
  }

  void _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      String recordPath = '';
      RecordConfig recordConfig = const RecordConfig(encoder: AudioEncoder.opus);

      if (!kIsWeb) {
        final tempDir = await getTemporaryDirectory();
        recordPath = p.join(tempDir.path, 'audio_${DateTime.now().millisecondsSinceEpoch}.aac');
        recordConfig = const RecordConfig(encoder: AudioEncoder.aacLc);
      }

      await _audioRecorder.start(
        recordConfig,
        path: recordPath, 
      );
      if (mounted) {
        setState(() {
          _isRecording = true;
          _textController.text = "🎤 Listening (Gemini Auto-Detect)...";
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission denied')),
        );
      }
    }
  }

  void _stopRecording() async {
    final path = await _audioRecorder.stop();
    if (mounted) {
      setState(() {
        _isRecording = false;
        _textController.clear();
      });
    }

    if (path != null) {
      final xfile = XFile(path);
      final bytes = await xfile.readAsBytes();
      // On web, record package usually records in WebM Opus.
      final mimeType = kIsWeb ? 'audio/webm' : 'audio/aac';
      _chatState.sendMessage('', audioBytes: bytes, mimeType: mimeType);
    }
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
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

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    _chatState.sendMessage(text);
  }

  @override
  void dispose() {
    _chatState.removeListener(_onStateChanged);
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090909) : AppColors.surfaceLightGray,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Contextual Premium App Bar Header
            Container(
              height: 64,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121211) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  // Back Action
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? Colors.white : AppColors.textDark,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Sparkle AI Avatar / Icon Block
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.deepTeal.withOpacity(0.15) : AppColors.pastelBlue.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppColors.deepTeal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title & Status
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HelperHive AI',
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : AppColors.textDark,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'AI Booking Companion',
                              style: GoogleFonts.nunito(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Mock Mode Indicator
                  if (_chatState.isMockMode)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Mock Mode',
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.orange,
                        ),
                      ),
                    ),

                  // Action Buttons
                  IconButton(
                    icon: Icon(
                      Icons.info_outline_rounded,
                      color: isDark ? Colors.white70 : AppColors.textDark,
                      size: 20,
                    ),
                    onPressed: _showBookingStateDialog,
                    tooltip: 'View Booking State',
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: isDark ? Colors.white70 : AppColors.textDark,
                      size: 20,
                    ),
                    onPressed: _chatState.resetConversation,
                    tooltip: 'Reset',
                  ),
                ],
              ),
            ),

            if (_chatState.mapVisible)
              AiMapWidget(
                providers: _chatState.providers,
                selectedProvider: _chatState.selectedProvider,
                onProviderTapped: (p) => _chatState.selectProvider(p),
              ),
            Expanded(
              child: _chatState.messages.isEmpty
                  ? const Center(child: CircularProgressIndicator(color: AppColors.deepTeal))
                  : ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: _chatState.messages.length,
                      itemBuilder: (context, index) =>
                          _buildMessage(_chatState.messages[index]),
                    ),
            ),

            if (_chatState.isAiTyping)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.deepTeal),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI is thinking...',
                      style: GoogleFonts.nunito(
                        color: AppColors.mutedGray,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

            // Confirm booking button
            if (_chatState.selectedProvider != null && !_chatState.bookingConfirmed)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _chatState.confirmBooking,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text('Confirm Booking with ${_chatState.selectedProvider!.name}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),

            // Post-booking buttons
            if (_chatState.bookingConfirmed)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _chatState.startBookingUpdate,
                        icon: const Icon(Icons.edit_rounded, size: 16),
                        label: const Text('Update Booking'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white70 : AppColors.deepTeal,
                          side: BorderSide(
                            color: isDark ? Colors.white38 : AppColors.deepTeal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _chatState.resetConversation,
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('New Booking'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.deepTeal,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          textStyle: GoogleFonts.nunito(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Input area
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF121211) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                  ),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1C1C1B) : AppColors.surfaceLightGray,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                focusNode: _focusNode,
                                style: GoogleFonts.nunito(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : AppColors.textDark,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Describe your issue...',
                                  hintStyle: GoogleFonts.nunito(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMutedGray,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => _sendMessage(),
                                enabled: !_chatState.isAiTyping &&
                                    !_chatState.isSearchingProviders &&
                                    !_chatState.waitingForAddressSelection,
                              ),
                            ),
                            GestureDetector(
                              onTap: _isRecording ? _stopRecording : _startRecording,
                              child: Icon(
                                _isRecording ? Icons.mic : Icons.mic_none,
                                color: _isRecording ? Colors.red : AppColors.textMutedGray,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: (_chatState.isAiTyping ||
                              _chatState.isSearchingProviders ||
                              _chatState.waitingForAddressSelection)
                          ? null
                          : _sendMessage,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (_chatState.isAiTyping ||
                                  _chatState.isSearchingProviders ||
                                  _chatState.waitingForAddressSelection)
                              ? AppColors.deepTeal.withOpacity(0.3)
                              : AppColors.deepTeal,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    switch (message.type) {
      case MessageType.user:
        return _buildUserBubble(message);
      case MessageType.ai:
        return _buildAiBubble(message);
      case MessageType.orchestration:
        return _buildOrchestration();
      case MessageType.providerCards:
        return _buildProviderCards(message);
      case MessageType.bookingConfirmation:
        return _buildBookingConfirmation(message);
      case MessageType.addressSelection:
        return _buildAddressSelection(message);
      case MessageType.updateOptions:
        return _buildUpdateOptions();
    }
  }

  Widget _buildUserBubble(ChatMessage message) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
          decoration: BoxDecoration(
            color: isDark ? AppColors.deepTeal.withOpacity(0.4) : AppColors.pastelBlue,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.04) : Colors.transparent,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            message.text,
            style: GoogleFonts.nunito(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.charcoalDark,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAiBubble(ChatMessage message) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF121211) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            message.text,
            style: GoogleFonts.nunito(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.charcoalDark,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrchestration() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.03) : AppColors.pastelBlue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _chatState.currentOrchestrationSteps.map((step) {
          final Color iconColor = step.completed 
              ? (isDark ? AppColors.pastelGreen : AppColors.deepTeal)
              : AppColors.mutedGray;
          final Color labelColor = step.completed
              ? (isDark ? Colors.white70 : AppColors.charcoalDark)
              : AppColors.mutedGray;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                step.completed
                    ? Icon(Icons.check_circle_rounded, color: iconColor, size: 18)
                    : const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.deepTeal,
                        ),
                      ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    step.label,
                    style: GoogleFonts.nunito(
                      fontSize: 12.5,
                      fontWeight: step.completed ? FontWeight.w700 : FontWeight.w600,
                      color: labelColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProviderCards(ChatMessage message) {
    if (message.providers == null || message.providers!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ProviderCardList(
        providers: message.providers!,
        selectedProvider: _chatState.selectedProvider,
        onProviderSelected: (p) => _chatState.selectProvider(p),
      ),
    );
  }

  Widget _buildBookingConfirmation(ChatMessage message) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    final Color bgColor = isDark ? const Color(0xFF162B28) : AppColors.pastelGreen.withOpacity(0.3);
    final Color borderColor = isDark ? AppColors.deepTeal.withOpacity(0.4) : AppColors.pastelGreen;
    final Color textColor = isDark ? AppColors.pastelGreen : AppColors.deepTeal;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, color: textColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message.text,
              style: GoogleFonts.nunito(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: textColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSelection(ChatMessage message) {
    if (message.addressOptions == null || message.addressOptions!.isEmpty) {
      return const SizedBox.shrink();
    }
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: message.addressOptions!.map((addr) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161616) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.01),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.06) : AppColors.surfaceLightGray,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on_rounded, color: AppColors.deepTeal, size: 18),
                ),
                title: Text(
                  addr.title,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.textDark,
                  ),
                ),
                subtitle: Text(
                  addr.address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppColors.mutedGray,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDark ? Colors.white54 : AppColors.mutedGray,
                ),
                onTap: () => _chatState.selectAddress(addr),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showBookingStateDialog() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Current Booking State',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : AppColors.textDark,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _stateRow('Service', _chatState.bookingState.service),
              _stateRow('Area', _chatState.bookingState.area),
              _stateRow('Phase', _chatState.bookingState.phase),
              _stateRow('Street', _chatState.bookingState.street),
              _stateRow('Address', _chatState.bookingState.fullAddress),
              _stateRow('Date', _chatState.bookingState.date),
              _stateRow('Time', _chatState.bookingState.time),
              _stateRow('Issue', _chatState.bookingState.issueDescription),
              _stateRow('Urgency', _chatState.bookingState.urgency),
              _stateRow('Provider', _chatState.bookingState.selectedProviderId),
              const Divider(height: 24),
              if (_chatState.bookingState.missingRequiredFields.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Missing: ${_chatState.bookingState.missingRequiredFields.join(", ")}',
                    style: GoogleFonts.nunito(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              Row(
                children: [
                  Text(
                    'Ready for Search: ',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDark ? Colors.white70 : AppColors.textDark,
                    ),
                  ),
                  Text(
                    _chatState.bookingState.isReadyForProviderSearch ? 'Yes' : 'No',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: _chatState.bookingState.isReadyForProviderSearch
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Mode: ',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDark ? Colors.white70 : AppColors.textDark,
                    ),
                  ),
                  Text(
                    _chatState.isMockMode ? "Mock" : "Gemini API",
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppColors.deepTeal,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                color: AppColors.deepTeal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stateRow(String label, String? value) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white70 : AppColors.textDark,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '—',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w600,
                color: value != null 
                    ? (isDark ? Colors.white : AppColors.textDark)
                    : AppColors.textMutedGray,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateOptions() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _updateChip(Icons.access_time_rounded, 'Date & Time', 'time'),
          _updateChip(Icons.location_on_rounded, 'Location', 'location'),
          _updateChip(Icons.person_rounded, 'Provider', 'provider'),
          _updateChip(Icons.build_rounded, 'Service', 'service'),
        ],
      ),
    );
  }

  Widget _updateChip(IconData icon, String label, String field) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ActionChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isDark ? Colors.white : AppColors.deepTeal,
      ),
      label: Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : AppColors.charcoalDark,
        ),
      ),
      backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      side: BorderSide(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.04),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onPressed: () => _chatState.updateField(field),
    );
  }
}
