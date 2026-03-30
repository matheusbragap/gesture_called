import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'views/login_view.dart';
import 'views/home_view.dart';

void main()  async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://your-supabase-url.supabase.co', //url do supabase
    anonKey: 'your-anon-key', //chave do supabase
  );
  runApp(const GestureCalledApp());
}

class GestureCalledApp extends StatelessWidget {
  const GestureCalledApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gesture Called',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ), 
      
      initialRoute: '/',
      routes: {
       '/': (context) => const LoginView(), 
        '/home': (context) => const HomeView(), 
        '/3d': (context) => const ThreeDShowcasePage(), 
      },
    );
  }
}

class ThreeDShowcasePage extends StatefulWidget {
  const ThreeDShowcasePage({super.key});

  @override
  State<ThreeDShowcasePage> createState() => _ThreeDShowcasePageState();
}

class _ThreeDShowcasePageState extends State<ThreeDShowcasePage>
    with TickerProviderStateMixin {
  late final AnimationController _timeController;
  late final AnimationController _pulseController;

  Offset _pointer = const Offset(0.0, 0.0);

  @override
  void initState() {
    super.initState();
    _timeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _updatePointer(Offset localPosition, Size size) {
    final dx = (localPosition.dx / size.width) * 2 - 1;
    final dy = (localPosition.dy / size.height) * 2 - 1;
    setState(() {
      _pointer = Offset(dx.clamp(-1.0, 1.0), dy.clamp(-1.0, 1.0));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return MouseRegion(
            onHover: (event) => _updatePointer(event.localPosition, size),
            child: GestureDetector(
              onPanUpdate: (details) =>
                  _updatePointer(details.localPosition, size),
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _timeController,
                  _pulseController,
                ]),
                builder: (context, _) {
                  final t = _timeController.value;
                  final pulse = Curves.easeInOut.transform(
                    _pulseController.value,
                  );

                  return DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF030915),
                          Color(0xFF0A1630),
                          Color(0xFF1C1454),
                        ],
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CustomPaint(
                          painter: _StarFieldPainter(
                            time: t,
                            pointer: _pointer,
                            pulse: pulse,
                          ),
                        ),
                        _build3DCluster(size, t, pulse),
                        _buildGlare(t, pulse),
                        _buildOverlayText(),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _build3DCluster(Size size, double t, double pulse) {
    final cards = List.generate(9, (index) {
      final depth = index / 8;
      final wave = math.sin((t * math.pi * 2) + index * 0.7);
      final yaw = (wave * 0.22) + _pointer.dx * 0.38;
      final pitch = (-wave * 0.15) + _pointer.dy * 0.34;
      final z = (depth - 0.5) * 420;
      final y = math.sin(t * math.pi * 4 + index) * 46;
      final x = math.cos(t * math.pi * 3 + index * 0.8) * 140;
      final scale = 0.66 + (1 - depth) * 0.74 + pulse * 0.12;
      final glow = (0.4 + (1 - depth) * 0.6).clamp(0.0, 1.0);

      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0018)
          ..translateByDouble(
            x + (_pointer.dx * 44),
            y + (_pointer.dy * 36),
            z,
            1.0,
          )
          ..rotateY(yaw)
          ..rotateX(pitch)
          ..rotateZ(math.sin(t * 5 + index) * 0.08)
          ..scaleByDouble(scale, scale, scale, 1.0),
        child: _GlassCard(index: index, glow: glow, phase: t),
      );
    });

    final rings = List.generate(3, (i) {
      final factor = i + 1;
      final spin = t * math.pi * (0.65 + i * 0.3);
      final radius = (size.shortestSide * 0.16) + i * 48;
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0015)
          ..rotateX(1.04 + i * 0.12 + _pointer.dy * 0.35)
          ..rotateY(spin * 0.4 + _pointer.dx * 0.6)
          ..rotateZ(spin),
        child: Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Color.lerp(
                const Color(0xFF61B8FF),
                const Color(0xFFFF8EC8),
                i / 3,
              )!.withValues(alpha: 0.34 + 0.14 * math.sin(t * 6 + factor)),
              width: 1.6,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.08),
                blurRadius: 18,
              ),
            ],
          ),
        ),
      );
    });

    return Center(
      child: Stack(alignment: Alignment.center, children: [...rings, ...cards]),
    );
  }

  Widget _buildGlare(double t, double pulse) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topLeft,
        child: Container(
          width: 420,
          height: 420,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                const Color(0xFF8EF7FF).withValues(alpha: 0.28 + pulse * 0.2),
                const Color(0x00000000),
              ],
              transform: GradientRotation((t * math.pi) * 0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayText() {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: const Text(
            '3D FLUID SHOWCASE  •  Move mouse or drag to shift perspective',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.index,
    required this.glow,
    required this.phase,
  });

  final int index;
  final double glow;
  final double phase;

  @override
  Widget build(BuildContext context) {
    final hue = (index * 0.12 + phase * 0.4) % 1;
    final colorA = HSVColor.fromAHSV(1, hue * 360, 0.56, 1).toColor();
    final colorB = HSVColor.fromAHSV(
      1,
      ((hue + 0.18) % 1) * 360,
      0.75,
      1,
    ).toColor();

    return Container(
      width: 210,
      height: 130,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorA.withValues(alpha: 0.52),
            colorB.withValues(alpha: 0.62),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.38)),
        boxShadow: [
          BoxShadow(
            color: colorB.withValues(alpha: 0.30 * glow),
            blurRadius: 26,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 18,
            child: Text(
              'Layer ${index + 1}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.92),
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  const _StarFieldPainter({
    required this.time,
    required this.pointer,
    required this.pulse,
  });

  final double time;
  final Offset pointer;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (var i = 0; i < 240; i++) {
      final seed = i * 0.61803398875;
      final angle =
          (seed * math.pi * 2) + (time * math.pi * 2 * (0.1 + i * 0.0007));
      final orbit = ((i * 27.0) % (size.shortestSide * 0.72)) + 20;
      final depth = ((time * 0.65 + seed) % 1);
      final depthScale = 0.25 + depth * 1.8;

      final px =
          center.dx + math.cos(angle) * orbit * depthScale + pointer.dx * 85;
      final py =
          center.dy + math.sin(angle) * orbit * depthScale + pointer.dy * 85;
      final radius = 0.7 + depth * 2.7;
      final alpha = (0.20 + depth * 0.72).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = HSVColor.fromAHSV(
          alpha,
          (180 + i * 0.9 + pulse * 40) % 360,
          0.48,
          1,
        ).toColor()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);

      canvas.drawCircle(Offset(px, py), radius, paint);
    }

    final beamPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0x22FFFFFF), Color(0x00FFFFFF), Color(0x24A8C8FF)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size)
      ..blendMode = BlendMode.plus;

    final beamWidth = size.width * (0.24 + pulse * 0.08);
    canvas.save();
    canvas.translate(size.width / 2 + pointer.dx * 90, size.height / 2);
    canvas.rotate(math.sin(time * math.pi * 2) * 0.22 + pointer.dx * 0.28);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset.zero,
          width: beamWidth,
          height: size.height * 1.3,
        ),
        const Radius.circular(999),
      ),
      beamPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.pointer != pointer ||
        oldDelegate.pulse != pulse;
  }
}
