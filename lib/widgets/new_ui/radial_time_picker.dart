import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';

class RadialTimePicker extends StatefulWidget {
  final int initialHour;
  final String initialPeriod; // "AM" or "PM"
  final ValueChanged<TimeOfDay>? onTimeSelected;

  const RadialTimePicker({
    super.key,
    this.initialHour = 7,
    this.initialPeriod = "AM",
    this.onTimeSelected,
  });

  @override
  State<RadialTimePicker> createState() => _RadialTimePickerState();
}

class _RadialTimePickerState extends State<RadialTimePicker> {
  late int _selectedHour;
  late String _selectedPeriod;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialHour;
    _selectedPeriod = widget.initialPeriod;
  }

  void _updateHourFromCoordinates(Offset localPosition, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double dx = localPosition.dx - centerX;
    final double dy = localPosition.dy - centerY;

    // Calculate angle in radians
    double angle = atan2(dy, dx);
    
    // Shift angle so 12 o'clock is at the top (-pi/2)
    double adjustedAngle = angle + pi / 2;
    if (adjustedAngle < 0) {
      adjustedAngle += 2 * pi;
    } else if (adjustedAngle >= 2 * pi) {
      adjustedAngle -= 2 * pi;
    }

    // Convert angle to hour index (1 to 12)
    int hour = (adjustedAngle / (2 * pi) * 12).round();
    if (hour == 0) hour = 12;

    if (hour != _selectedHour) {
      setState(() {
        _selectedHour = hour;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String displayTime = _selectedHour.toString().padLeft(2, '0') + ":00";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF090909) : Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag indicator bar
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),

          // Header Metric Readout
          Text(
            displayTime,
            style: GoogleFonts.nunito(
              fontSize: 54,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.textDark,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),

          // AM / PM Segmented Capsule Switch
          Container(
            height: 38,
            width: 140,
            decoration: BoxDecoration(
              color: AppColors.surfaceLightGray,
              borderRadius: BorderRadius.circular(19.0),
            ),
            padding: const EdgeInsets.all(3.0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPeriod = "AM"),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedPeriod == "AM" ? AppColors.textDark : Colors.transparent,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "AM",
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _selectedPeriod == "AM" ? Colors.white : AppColors.textMutedGray,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPeriod = "PM"),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedPeriod == "PM" ? AppColors.textDark : Colors.transparent,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "PM",
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: _selectedPeriod == "PM" ? Colors.white : AppColors.textMutedGray,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Interactive Radial Clock
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: GestureDetector(
                onPanStart: (details) {
                  _updateHourFromCoordinates(details.localPosition, const Size(250, 250));
                },
                onPanUpdate: (details) {
                  _updateHourFromCoordinates(details.localPosition, const Size(250, 250));
                },
                child: CustomPaint(
                  size: const Size(250, 250),
                  painter: ClockDialPainter(
                    selectedHour: _selectedHour,
                    isDark: isDark,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Confirmation Action Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                if (widget.onTimeSelected != null) {
                  int militaryHour = _selectedHour;
                  if (_selectedPeriod == "PM" && _selectedHour != 12) {
                    militaryHour += 12;
                  } else if (_selectedPeriod == "AM" && _selectedHour == 12) {
                    militaryHour = 0;
                  }
                  widget.onTimeSelected!(TimeOfDay(hour: militaryHour, minute: 0));
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepTeal,
                shape: const StadiumBorder(),
              ),
              child: Text(
                "Done",
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ClockDialPainter extends CustomPainter {
  final int selectedHour;
  final bool isDark;

  ClockDialPainter({
    required this.selectedHour,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final Offset center = Offset(centerX, centerY);
    final double radius = size.width / 2;

    // Draw the Dial Background Plate
    final Paint dialPlatePaint = Paint()
      ..color = isDark ? const Color(0xFF161616) : AppColors.surfaceLightGray
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, dialPlatePaint);

    // Draw Outer Timeline Arcs:
    // Green (recommended / free hours): e.g. 9 AM - 1 PM (hour 9 to 1)
    // Red/Orange (unavailable / conflicted hours): e.g. 2 PM - 5 PM (hour 2 to 5)
    final Paint arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    // Math angle conversion: angle corresponding to hour (h) is: h * pi / 6 - pi / 2
    // Hour 9 to Hour 1 (9, 10, 11, 12, 1)
    arcPaint.color = AppColors.secondaryGreen;
    double startAngleGreen = 9 * pi / 6 - pi / 2; // Hour 9
    double sweepAngleGreen = 4 * pi / 6; // 4 hours sweep
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 3),
      startAngleGreen,
      sweepAngleGreen,
      false,
      arcPaint,
    );

    // Hour 2 to Hour 5 (2, 3, 4, 5)
    arcPaint.color = AppColors.alertOrange;
    double startAngleRed = 2 * pi / 6 - pi / 2; // Hour 2
    double sweepAngleRed = 3 * pi / 6; // 3 hours sweep
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 3),
      startAngleRed,
      sweepAngleRed,
      false,
      arcPaint,
    );

    // Draw Standard 12-Hour Markers
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final double textRadius = radius - 36;
    for (int hour = 1; hour <= 12; hour++) {
      final double angle = hour * pi / 6 - pi / 2;
      final Offset position = Offset(
        centerX + textRadius * cos(angle),
        centerY + textRadius * sin(angle),
      );

      final bool isSelected = hour == selectedHour;

      textPainter.text = TextSpan(
        text: hour.toString(),
        style: GoogleFonts.nunito(
          color: isSelected
              ? Colors.transparent // Hide original text since Node covers it
              : (isDark ? Colors.white60 : Colors.black87),
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
        ),
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        position - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }

    // DRAW THE INTERACTIVE SELECTOR NEEDLE & NODE
    final double selectedAngle = selectedHour * pi / 6 - pi / 2;
    final Offset nodePosition = Offset(
      centerX + textRadius * cos(selectedAngle),
      centerY + textRadius * sin(selectedAngle),
    );

    // Draw thin needle pointer arm line
    final Paint needlePaint = Paint()
      ..color = AppColors.deepTeal.withOpacity(0.6)
      ..strokeWidth = 2.0;
    canvas.drawLine(center, nodePosition, needlePaint);

    // Glowing selection dot directly underneath
    final Paint glowPaint = Paint()
      ..color = AppColors.deepTeal.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(nodePosition, 22, glowPaint);

    // Draw central pivot point
    final Paint pivotPaint = Paint()
      ..color = AppColors.deepTeal
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, pivotPaint);

    // Distinct black circle selector node
    final Paint nodePaint = Paint()
      ..color = AppColors.charcoalDark
      ..style = PaintingStyle.fill;
    canvas.drawCircle(nodePosition, 18, nodePaint);

    // Accent selected integer text inside the node
    textPainter.text = TextSpan(
      text: selectedHour.toString(),
      style: GoogleFonts.nunito(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w900,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      nodePosition - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant ClockDialPainter oldDelegate) {
    return oldDelegate.selectedHour != selectedHour || oldDelegate.isDark != isDark;
  }
}
