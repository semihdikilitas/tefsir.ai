import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import '../core/constants/app_colors.dart';

class QiblaCompassScreen extends StatefulWidget {
  const QiblaCompassScreen({super.key});

  @override
  State<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends State<QiblaCompassScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kıble Pusulası',
          style: TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: StreamBuilder<QiblahDirection>(
            stream: FlutterQiblah.qiblahStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.gold),
                      SizedBox(height: 16),
                      Text(
                        'Pusula kalibre ediliyor...',
                        style: TextStyle(color: AppColors.textLight),
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sensors_off_rounded, color: AppColors.gold.withValues(alpha: 0.5), size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'Pusula sensörüne erişilemiyor',
                        style: TextStyle(color: AppColors.textLight, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Cihazınızda manyetik sensör bulunmalıdır.\nLütfen cihazınızı kalibre etmek için\nhavada 8 çizerek sallayın.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 13, height: 1.5),
                      ),
                    ],
                  ),
                );
              }

              final qiblahDirection = snapshot.data!;
              return _buildCompass(qiblahDirection);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCompass(QiblahDirection qiblah) {
    final qiblahAngle = qiblah.qiblah;
    final heading = qiblah.direction;
    // Kıble'ye ne kadar yakın olduğumuzu hesapla (0 derece = tam kıbledeyiz)
    final offset = ((qiblahAngle - heading + 360) % 360);
    final isAligned = offset < 3 || offset > 357;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Kıbleye yakınlık göstergesi
          Text(
            isAligned ? 'Kıble Hizalandı ✨' : 'Kıbleye Yönleniyor...',
            style: TextStyle(
              color: isAligned ? AppColors.gold : AppColors.textLight.withValues(alpha: 0.7),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${offset.toStringAsFixed(0)}° sapma',
            style: TextStyle(
              color: AppColors.gold.withValues(alpha: 0.6),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 24),

          // PUSULA
          _buildCompassDial(heading, qiblahAngle, isAligned, offset),

          const SizedBox(height: 32),

          // Kıble Bilgi Kartı
          _buildQiblaInfoCard(offset),
        ],
      ),
    );
  }

  Widget _buildCompassDial(double heading, double qiblahAngle, bool isAligned, double offset) {
    final size = MediaQuery.of(context).size.width * 0.78;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Center(
          child: SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: _QiblaCompassPainter(
                heading: heading,
                qiblahAngle: qiblahAngle,
                isAligned: isAligned,
                pulseValue: _pulseController.value,
                isDark: true,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQiblaInfoCard(double offset) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.15), width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.gold, size: 18),
              const SizedBox(width: 6),
              Text(
                'Mekke, Suudi Arabistan',
                style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.8), fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoStat('Kıble Açısı', '${offset.toStringAsFixed(1)}°'),
              Container(height: 30, width: 1, color: AppColors.gold.withValues(alpha: 0.15)),
              _buildInfoStat('Mesafe', '~2.230 km'),
              Container(height: 30, width: 1, color: AppColors.gold.withValues(alpha: 0.15)),
              _buildInfoStat('Koordinat', '21.42° K\n39.82° D'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(color: AppColors.textLight, fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: AppColors.textLight.withValues(alpha: 0.5), fontSize: 11),
        ),
      ],
    );
  }
}

/// Pusula kadranını ve Kıble oku çizer.
class _QiblaCompassPainter extends CustomPainter {
  final double heading;
  final double qiblahAngle;
  final bool isAligned;
  final double pulseValue;
  final bool isDark;

  _QiblaCompassPainter({
    required this.heading,
    required this.qiblahAngle,
    required this.isAligned,
    required this.pulseValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Dış halka — gradient
    final outerPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xFFD4AF37).withValues(alpha: 0.05),
          const Color(0xFFD4AF37).withValues(alpha: 0.18),
          const Color(0xFFD4AF37).withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawCircle(center, radius, outerPaint);

    // Derece işaretleri
    _drawDegreeMarkers(canvas, center, radius, heading);

    // Yön işaretleri (K, G, D, B)
    _drawDirectionLabels(canvas, center, radius, heading);

    // Kıble okunun olduğu noktayı hesapla
    final qiblahRadians = (qiblahAngle - heading - 90) * (pi / 180);
    final qiblahX = center.dx + (radius - 36) * cos(qiblahRadians);
    final qiblahY = center.dy + (radius - 36) * sin(qiblahRadians);
    final qiblahPoint = Offset(qiblahX, qiblahY);

    // Pals (hizalıysa yeşil halka)
    if (isAligned) {
      final pulseRadius = 14 + (pulseValue * 22);
      final pulsePaint = Paint()
        ..color = const Color(0xFF2A9D8F).withValues(alpha: 0.35 * (1 - pulseValue))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(qiblahPoint, pulseRadius, pulsePaint);

      final pulseStroke = Paint()
        ..color = const Color(0xFF2A9D8F).withValues(alpha: 0.6 * (1 - pulseValue))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(qiblahPoint, pulseRadius, pulseStroke);
    }

    // Kıble oku (Kabe)
    _drawKaabaIcon(canvas, qiblahPoint, isAligned);

    // İç daire — cihaz yönü göstergesi
    final innerPaint = Paint()
      ..color = (isDark ? Colors.black : Colors.white).withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 14, innerPaint);

    final innerBorder = Paint()
      ..color = const Color(0xFFD4AF37).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, 14, innerBorder);

    // Kuzey ok göstergesi (cihazın baktığı yönü gösterir)
    final northArrow = Paint()
      ..color = const Color(0xFFD4AF37)
      ..style = PaintingStyle.fill;

    final arrowPath = Path()
      ..moveTo(center.dx, center.dy - 11)
      ..lineTo(center.dx - 5, center.dy + 4)
      ..lineTo(center.dx, center.dy + 1)
      ..lineTo(center.dx + 5, center.dy + 4)
      ..close();
    canvas.drawPath(arrowPath, northArrow);
  }

  void _drawDegreeMarkers(Canvas canvas, Offset center, double radius, double heading) {
    for (int i = 0; i < 360; i += 5) {
      final radians = (i - heading) * (pi / 180);
      final isMajor = i % 15 == 0;
      final innerR = radius - (isMajor ? 24 : 14);
      final outerR = radius - 4;

      final x1 = center.dx + innerR * cos(radians);
      final y1 = center.dy + innerR * sin(radians);
      final x2 = center.dx + outerR * cos(radians);
      final y2 = center.dy + outerR * sin(radians);

      final paint = Paint()
        ..color = (isMajor
                ? const Color(0xFFD4AF37).withValues(alpha: 0.7)
                : const Color(0xFFD4AF37).withValues(alpha: 0.35))
        ..strokeWidth = isMajor ? 2 : 1
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  void _drawDirectionLabels(Canvas canvas, Offset center, double radius, double heading) {
    const directions = [
      {'label': 'K', 'angle': 0},
      {'label': 'D', 'angle': 90},
      {'label': 'G', 'angle': 180},
      {'label': 'B', 'angle': 270},
    ];

    for (final d in directions) {
      final angle = (d['angle'] as int) - heading.toInt();
      final radians = angle * (pi / 180);
      final x = center.dx + (radius - 42) * cos(radians);
      final y = center.dy + (radius - 42) * sin(radians);

      final textPainter = TextPainter(
        text: TextSpan(
          text: d['label'] as String,
          style: TextStyle(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.85),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }
  }

  void _drawKaabaIcon(Canvas canvas, Offset center, bool isAligned) {
    const size = 16.0;
    final rect = Rect.fromCenter(center: center, width: size, height: size);

    final fillPaint = Paint()
      ..color = isAligned ? const Color(0xFF2A9D8F) : const Color(0xFFD4AF37)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = (isAligned ? const Color(0xFF2A9D8F) : const Color(0xFFD4AF37))
          .withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Kabe benzeri küp çizimi
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)));

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);

    // İç siyah şerit
    final stripePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    final stripeRect = Rect.fromLTRB(
      rect.left + 2,
      rect.center.dy - 3,
      rect.right - 2,
      rect.center.dy + 3,
    );
    canvas.drawRect(stripeRect, stripePaint);
  }

  @override
  bool shouldRepaint(covariant _QiblaCompassPainter oldDelegate) {
    return heading != oldDelegate.heading ||
        qiblahAngle != oldDelegate.qiblahAngle ||
        isAligned != oldDelegate.isAligned ||
        pulseValue != oldDelegate.pulseValue;
  }
}
