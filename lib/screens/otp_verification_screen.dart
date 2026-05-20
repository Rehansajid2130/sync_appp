import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import 'create_new_password_screen.dart';
import 'new_ui/new_auth_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final bool isFromSignup;

  const OtpVerificationScreen({
    super.key, 
    this.email = 'fajar***@gmail.com',
    this.isFromSignup = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(4, (index) => TextEditingController());
  int _currentFocusedIndex = 0;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 4; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          setState(() {
            _currentFocusedIndex = i;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    for (var node in _focusNodes) node.dispose();
    for (var controller in _controllers) controller.dispose();
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161616) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppColors.charcoalDark, size: 16),
            ),
          ),
        ),
        title: Text(
          'Verification',
          style: GoogleFonts.nunito(
            color: isDark ? Colors.white : AppColors.charcoalDark,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF111111) : Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.deepTeal.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mark_email_read_rounded, color: AppColors.deepTeal, size: 40),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Enter Verification Code',
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.charcoalDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'We have sent an OTP code to\n${widget.email}.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          color: isDark ? Colors.white70 : AppColors.mutedGray,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) => _buildOtpBox(index, isDark)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.isFromSignup) {
                      _showSuccessDialog(context, isDark);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CreateNewPasswordScreen(email: widget.email)),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepTeal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: Text(
                    'Verify Code',
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index, bool isDark) {
    bool isFocused = _currentFocusedIndex == index;
    bool hasText = _controllers[index].text.isNotEmpty;

    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : AppColors.offWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFocused || hasText
              ? AppColors.deepTeal
              : (isDark ? Colors.white10 : Colors.black.withOpacity(0.04)),
          width: 2,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white : AppColors.charcoalDark,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(counterText: '', border: InputBorder.none),
        onChanged: (value) => _onChanged(value, index),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF161616) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(color: AppColors.pastelGreen, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded, color: Color(0xFF1A6B3C), size: 50),
                ),
                const SizedBox(height: 32),
                Text('Successful', style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.charcoalDark)),
                const SizedBox(height: 12),
                Text(
                  'Your account has been successfully registered.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(color: isDark ? Colors.white70 : AppColors.mutedGray, fontSize: 15, fontWeight: FontWeight.w600, height: 1.5),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const NewAuthScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.deepTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)), elevation: 0),
                    child: Text('Continue to Login', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
