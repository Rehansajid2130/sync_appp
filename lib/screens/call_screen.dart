import 'package:flutter/material.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090909), // Midnight black
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80),
            const CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage('https://i.pravatar.cc/300?u=sarah'),
            ),
            const SizedBox(height: 32),
            const Text(
              'Sarah T.',
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            const Text(
              '02:45 Minutes',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCallAction(Icons.videocam_off_outlined, Colors.white10),
                  _buildCallAction(Icons.volume_up_outlined, Colors.white10),
                  _buildCallAction(Icons.call_end, Colors.red, isEnd: true, onTap: () => Navigator.pop(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallAction(IconData icon, Color color, {bool isEnd = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}
