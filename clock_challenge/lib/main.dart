import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const Challenge03());
}

class Challenge03 extends StatefulWidget {
  const Challenge03({Key? key}) : super(key: key);

  static const radius = 300.0;

  @override
  State<Challenge03> createState() => _Challenge03State();
}

class _Challenge03State extends State<Challenge03> {
  bool useArabicNumbers = true;
  DateTime time = DateTime.now();
  late final Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() {
        time = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Clock Challenge'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              useArabicNumbers = !useArabicNumbers;
            });
          },
          child: const Icon(Icons.refresh),
        ),
        body: Center(
          child: CustomPaint(
            foregroundPainter: ClockPainter(
                time: DateTime.now(), useArabicNumbers: useArabicNumbers),
            child: Container(
              height: Challenge03.radius,
              width: Challenge03.radius,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                    colors: [
                      Colors.grey.shade100,
                      Colors.grey.shade400,
                    ],
                    begin: const Alignment(-0.2, -0.8),
                    end: const Alignment(1.0, 0.2)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  final bool useArabicNumbers;
  final DateTime time;

  ClockPainter({required this.time, this.useArabicNumbers = true});

  static const angleBetweenEachNumber = 360.0 / amountNumbers;
  static const amountNumbers = 12;
  static const hourLineLength = 10.0;
  static const numberFontSize = 15.0;
  static const tenMinutesLineLength = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width != size.height) throw Exception();
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final hourLinesCircleRadius = radius * 0.9;
    drawOuterCircle(canvas, center, radius);
    drawInnerCircle(canvas, center, radius);
    for (int i = 0; i < amountNumbers; i++) {
      final angle = (-2 * angleBetweenEachNumber) + i * angleBetweenEachNumber;
      final p1 = getTriangleOffset(hourLinesCircleRadius, angle) + center;
      final p2 = p1 - getTriangleOffset(hourLineLength, angle);
      canvas.drawLine(
          p1,
          p2,
          Paint()
            ..color = Colors.black
            ..strokeWidth = 3.0);
      paintHourText(canvas, p1, angle, size, i);
      paintTenMinuteLines(
          canvas, p1, angle, size, i, center, hourLinesCircleRadius);
    }
    drawSecondsPointer(canvas, radius, center);
    drawMinutesPointer(canvas, radius, center);
    drawHoursPointer(canvas, radius, center);
  }

  Offset getTriangleOffset(double hypotenuse, double angle) {
    return Offset(hypotenuse * math.cos(degreesToRadians(angle)),
        hypotenuse * math.sin(degreesToRadians(angle)));
  }

  Offset getTriangleOffsetInverse(double hypotenuse, double angle) {
    return Offset(hypotenuse * (1 - math.cos(degreesToRadians(angle))),
        hypotenuse * (1 - math.sin(degreesToRadians(angle))));
  }

  static const romanNumerals = {
    1: 'I',
    2: 'II',
    3: 'III',
    4: 'IV',
    5: 'V',
    6: 'VI',
    7: 'VII',
    8: 'VIII',
    9: 'IX',
    10: 'X',
    11: 'XI',
    12: 'XII',
  };
  String getNumber(int nth) {
    if (useArabicNumbers) {
      return nth.toString();
    } else {
      return romanNumerals[nth]!;
    }
  }

  double degreesToRadians(double degrees) {
    return (degrees / 360.0) * 2 * math.pi;
  }

  @override
  bool shouldRepaint(covariant ClockPainter oldDelegate) {
    return oldDelegate.useArabicNumbers != useArabicNumbers ||
        oldDelegate.time != time;
  }

  void drawOuterCircle(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10.0);
  }

  void drawInnerCircle(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius * 0.05, Paint());
  }

  void paintHourText(Canvas canvas, Offset p1, double angle, Size size, int i) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: getNumber(i + 1),
        style: const TextStyle(
          color: Colors.black,
          fontSize: numberFontSize,
        ),
      ),
    );
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    final inverseOffset = getTriangleOffsetInverse(numberFontSize / 2.0, angle);
    textPainter.paint(canvas,
        p1 - getTriangleOffset(hourLineLength * 3, angle) - inverseOffset);
  }

  void paintTenMinuteLines(Canvas canvas, Offset p1, double angle, Size size,
      int i, Offset center, double hourLinesCircleRadius) {
    for (int j = 0; j < 4; j++) {
      final minuteLineAngle = angle + (angleBetweenEachNumber / 5.0) * (j + 1);
      final p1 =
          getTriangleOffset(hourLinesCircleRadius, minuteLineAngle) + center;
      final p2 = p1 - getTriangleOffset(tenMinutesLineLength, minuteLineAngle);
      canvas.drawLine(
          p1,
          p2,
          Paint()
            ..color = Colors.black
            ..strokeWidth = 2.0);
    }
  }

  void drawSecondsPointer(Canvas canvas, double radius, Offset center) {
    final angle =
        ((time.second + time.millisecond / 1000.0) / 60.0) * 360.0 - 90.0;
    final p1 = getTriangleOffset(-0.3 * radius, angle) + center;
    final p2 = p1 + getTriangleOffset(1 * radius, angle);
    canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = Colors.red
          ..strokeWidth = 3.0);
  }

  void drawMinutesPointer(Canvas canvas, double radius, Offset center) {
    final angle = (time.minute / 60.0 +
                time.second / 3600.0 +
                time.millisecond +
                3600000.0) *
            360.0 -
        90.0;

    final p1 = getTriangleOffset(-0.15 * radius, angle) + center;
    final p2 = p1 + getTriangleOffset(1 * radius, angle);
    canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = Colors.black
          ..strokeWidth = 3.0);
  }

  int getHour(DateTime time) {
    final hour = time.hour;
    if (hour == 0) return 12;
    if (hour >= 1 && hour <= 12) return hour;
    return hour - 12;
  }

  void drawHoursPointer(Canvas canvas, double radius, Offset center) {
    final angle = (getHour(time) / 12.0 +
                time.minute / 3600.0 +
                time.second / 3600000.0) *
            360.0 -
        90;

    final p1 = getTriangleOffset(-0.15 * radius, angle) + center;
    final p2 = p1 + getTriangleOffset(0.7 * radius, angle);
    canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = Colors.black
          ..strokeWidth = 4.0);
  }
}
