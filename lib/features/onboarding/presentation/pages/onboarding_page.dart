import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/storage_services.dart';
import '../../../../routes/app_routes.dart';

// ─── DESIGN TOKENS ───────────────────────────────────────────────
class FK {
  // Colors (sampled from approved reference)
  static const cream = Color(0xFFFCF7F1); // splash bg
  static const ink = Color(0xFF152026); // primary text
  static const mid = Color(0xFF8A8278);
  static const deep = Color(0xFF5C564E);
  static const faint = Color(0xFFB5AFA5);
  static const stone = Color(0xFFE8E3DA);
  static const warm = Color(0xFFF0EBE2); // screen bg
  static const gold = Color(0xFFC4A97D);
  static const lost = Color(0xFF9B4D3C); // "lost time" red-brown
  static const accent = Color(0xFFE8632A); // FocusKey orange

  // Type helpers
  static TextStyle wordmark({double size = 40}) => GoogleFonts.lora(
    fontSize: size,
    fontWeight: FontWeight.w400,
    color: ink,
    height: 1.0,
  );

  static TextStyle serif({
    double size = 25,
    FontWeight weight = FontWeight.w400,
    Color color = ink,
    double height = 1.35,
  }) => GoogleFonts.cormorantGaramond(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );

  static TextStyle sans({
    double size = 13,
    FontWeight weight = FontWeight.w400,
    Color color = ink,
    double height = 1.4,
    double letterSpacing = 0,
  }) => GoogleFonts.dmSans(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

// ─── REVEAL: fade + translate-up on mount, with delay ────────────
class Reveal extends StatefulWidget {
  final Widget child;
  final int delayMs;
  final int durationMs;
  final double offsetY;
  const Reveal({
    super.key,
    required this.child,
    this.delayMs = 0,
    this.durationMs = 800,
    this.offsetY = 14,
  });

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _anim;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
    );
    _anim = CurvedAnimation(parent: _c, curve: const Cubic(.16, 1, .3, 1));
    _t = Timer(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (context, child) => Opacity(
      opacity: _anim.value,
      child: Transform.translate(
        offset: Offset(0, (1 - _anim.value) * widget.offsetY),
        child: child,
      ),
    ),
    child: widget.child,
  );
}

// ═══════════════════════════════════════════════════════════════
//  SCREEN 1 — SPLASH
// ═══════════════════════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  final VoidCallback onDone;
  const SplashScreen({super.key, required this.onDone});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0;
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    _timers.add(
      Timer(
        const Duration(milliseconds: 60),
        () => mounted ? setState(() => _opacity = 1) : null,
      ),
    );
    _timers.add(
      Timer(
        const Duration(milliseconds: 60 + 600 + 2700),
        () => mounted ? setState(() => _opacity = 0) : null,
      ),
    );
    _timers.add(
      Timer(
        const Duration(milliseconds: 60 + 600 + 2700 + 500),
        () => mounted ? widget.onDone() : null,
      ),
    );
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FK.cream,
      alignment: Alignment.center,
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: Duration(milliseconds: _opacity == 0 ? 500 : 600),
        curve: Curves.easeInOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('FocusKey', style: FK.wordmark(size: 40)),
            const SizedBox(height: 9),
            Text(
              'by Presence Labs',
              style: GoogleFonts.lora(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: FK.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SCREEN 2 — THE QUESTION
// ═══════════════════════════════════════════════════════════════
class QuestionScreen extends StatefulWidget {
  final ValueChanged<int> onNext;
  const QuestionScreen({super.key, required this.onNext});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  String _hrs = '';

  int get _value => int.tryParse(_hrs) ?? 0;
  bool get _ok => _value >= 1 && _value <= 18;

  void _tap(int n) {
    if (_hrs.length < 2) setState(() => _hrs += '$n');
  }

  void _del() {
    if (_hrs.isNotEmpty) {
      setState(() => _hrs = _hrs.substring(0, _hrs.length - 1));
    }
  }

  Widget _key(String label, VoidCallback onTap, {bool transparent = false}) {
    return Material(
      color: transparent ? Colors.transparent : FK.cream,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          child: label == '⌫'
              ? const Icon(Icons.backspace_outlined, size: 22, color: FK.ink)
              : Text(label, style: FK.sans(size: 19, color: FK.ink)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FK.cream,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Reveal(
                    delayMs: 200,
                    child: Text(
                      'How many hours a day does your phone take without you noticing?',
                      textAlign: TextAlign.center,
                      style: FK.serif(size: 27),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Reveal(
                    delayMs: 550,
                    child: Text(
                      "The hours you won't even remember spending, lost to mindless scrolling and absent-minded pickups, add up.",
                      textAlign: TextAlign.center,
                      style: FK.sans(size: 13, color: FK.deep, height: 1.65),
                    ),
                  ),
                  SizedBox(height: 44.h),
                  Reveal(
                    delayMs: 750,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 88.h,
                          child: Center(
                            child: Text(
                              _hrs.isEmpty ? '0' : _hrs,
                              style: GoogleFonts.inter(
                                fontSize: 62.sp,
                                fontWeight: FontWeight.w300,
                                color: _hrs.isEmpty ? FK.faint : FK.ink,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'HOURS',
                          style: FK.sans(
                            size: 11.sp,
                            weight: FontWeight.w500,
                            color: FK.accent,
                            letterSpacing: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Keypad panel
          Reveal(
            delayMs: 950,
            offsetY: 20,
            child: Container(
              decoration: const BoxDecoration(
                color: FK.warm,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                10,
                20,
                0 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                children: [
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 7,
                          crossAxisSpacing: 7,
                          mainAxisExtent: 50,
                        ),
                    children: [
                      for (var n = 1; n <= 9; n++) _key('$n', () => _tap(n)),
                      const SizedBox.shrink(),
                      _key('0', () => _tap(0)),
                      _key('⌫', _del, transparent: true),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: _ok ? FK.ink : FK.stone,
                      borderRadius: BorderRadius.circular(28),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(28),
                        onTap: _ok ? () => widget.onNext(_value) : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          alignment: Alignment.center,
                          child: Text(
                            'Continue',
                            style: FK.sans(
                              size: 14,
                              weight: FontWeight.w500,
                              color: _ok ? FK.cream : FK.mid,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
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
}

// ═══════════════════════════════════════════════════════════════
//  SCREEN 3 — THE TRUTH (life grid)
// ═══════════════════════════════════════════════════════════════
class TruthScreen extends StatefulWidget {
  final int hours;
  final VoidCallback onNext;
  const TruthScreen({super.key, required this.hours, required this.onNext});

  @override
  State<TruthScreen> createState() => _TruthScreenState();
}

class _TruthScreenState extends State<TruthScreen>
    with SingleTickerProviderStateMixin {
  static const int life = 90;
  late final int sleep;
  late final int screenYears;
  late final AnimationController _grid;
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    sleep = (life * (8 / 24)).round();
    final raw = (life * (widget.hours / 24)).round();
    screenYears = raw.clamp(0, life - sleep);

    _grid = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: life * 18 + 350),
    );
    _startTimer = Timer(const Duration(milliseconds: 1100), () {
      if (mounted) _grid.forward();
    });
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _grid.dispose();
    super.dispose();
  }

  String _cellType(int i) {
    if (i < sleep) return 'sleep';
    if (i < sleep + screenYears) return 'screen';
    return 'living';
  }

  Widget _legendDot(Color fill, {Color? borderColor}) => Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.circular(3),
      border: borderColor != null
          ? Border.all(color: borderColor, width: 1.5)
          : null,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final totalMs = life * 18 + 350;

    return Container(
      color: FK.cream,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Reveal(
            delayMs: 200,
            child: Text.rich(
              TextSpan(
                style: FK.serif(size: 25),
                children: [
                  TextSpan(text: '${widget.hours} '),
                  TextSpan(text: widget.hours == 1 ? 'hour' : 'hours'),
                  const TextSpan(text: ' a day becomes '),
                  TextSpan(
                    text: '$screenYears ${screenYears == 1 ? 'year' : 'years'}',
                    style: FK.serif(
                      size: 25,
                      weight: FontWeight.w500,
                      color: FK.lost,
                    ),
                  ),
                  const TextSpan(text: ' of your life.'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 10),
          Reveal(
            delayMs: 500,
            child: Text(
              'Each square is one year of a 90-year life.',
              style: FK.sans(size: 12, color: FK.deep),
            ),
          ),
          const SizedBox(height: 26),
          Reveal(
            delayMs: 750,
            child: SizedBox(
              width: 256,
              child: AnimatedBuilder(
                animation: _grid,
                builder: (context, _) {
                  return GridView.count(
                    crossAxisCount: 9,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    children: List.generate(life, (i) {
                      final start = (i * 18) / totalMs;
                      final end = ((i * 18) + 350) / totalMs;
                      final t = CurvedAnimation(
                        parent: _grid,
                        curve: Interval(start, end, curve: Curves.easeOut),
                      ).value;

                      final type = _cellType(i);
                      Color bg;
                      Border? border;
                      if (type == 'sleep') {
                        bg = Color.lerp(FK.stone, FK.ink, t)!;
                      } else if (type == 'screen') {
                        bg = Color.lerp(FK.stone, FK.lost, t)!;
                      } else {
                        bg = Color.lerp(FK.stone, FK.cream, t)!;
                        border = Border.all(
                          color: FK.mid.withOpacity(t),
                          width: 1.5,
                        );
                      }
                      return Container(
                        decoration: BoxDecoration(
                          color: bg,
                          border: border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 22),
          Reveal(
            delayMs: 1400,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendDot(FK.ink),
                const SizedBox(width: 8),
                Text('Sleep', style: FK.sans(size: 12)),
                const SizedBox(width: 24),
                _legendDot(FK.lost),
                const SizedBox(width: 8),
                Text('Lost time', style: FK.sans(size: 12)),
                const SizedBox(width: 24),
                _legendDot(Colors.transparent, borderColor: FK.mid),
                const SizedBox(width: 8),
                Text('Living', style: FK.sans(size: 12)),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Reveal(
            delayMs: 1900,
            durationMs: 1200,
            child: Text(
              'That time was engineered away by apps built to steal your attention, pulling you away from the people and goals that matter most.',
              textAlign: TextAlign.center,
              style: FK.sans(size: 13, height: 1.6),
            ),
          ),
          const SizedBox(height: 28),
          Reveal(
            delayMs: 2500,
            child: Material(
              color: FK.ink,
              borderRadius: BorderRadius.circular(28),
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: widget.onNext,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 48,
                  ),
                  child: Text(
                    'Continue',
                    style: FK.sans(
                      size: 14,
                      weight: FontWeight.w500,
                      color: FK.cream,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  SCREEN 4 — THE MESSAGE
// ═══════════════════════════════════════════════════════════════
class MessageScreen extends StatelessWidget {
  final VoidCallback onBegin;
  const MessageScreen({super.key, required this.onBegin});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FK.cream,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Reveal(
            delayMs: 500,
            durationMs: 1400,
            offsetY: 10,
            child: Text(
              'Your time, back in your hands.',
              textAlign: TextAlign.center,
              style: FK.serif(size: 28),
            ),
          ),
          const SizedBox(height: 26),
          Reveal(
            delayMs: 2000,
            durationMs: 1200,
            offsetY: 10,
            child: Text(
              'Thank you for taking this first step toward focus and presence.',
              textAlign: TextAlign.center,
              style: FK.serif(size: 20, height: 1.5),
            ),
          ),
          const SizedBox(height: 20),
          Reveal(
            delayMs: 3400,
            durationMs: 1200,
            offsetY: 8,
            child: Text(
              "What truly matters is waiting on the other side: more time and attention for the people around you, and for the goals you've been meaning to reach.",
              textAlign: TextAlign.center,
              style: FK.serif(size: 20, height: 1.5),
            ),
          ),
          const SizedBox(height: 36),
          Reveal(
            delayMs: 5000,
            durationMs: 1600,
            offsetY: 4,
            child: Text(
              'The key is yours.',
              textAlign: TextAlign.center,
              style: FK.serif(size: 20, height: 1.5, color: FK.gold),
            ),
          ),
          const SizedBox(height: 40),
          Reveal(
            delayMs: 6400,
            durationMs: 800,
            child: OutlinedButton(
              onPressed: onBegin,
              style: OutlinedButton.styleFrom(
                foregroundColor: FK.ink,
                side: const BorderSide(color: FK.mid, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                  horizontal: 44,
                ),
              ),
              child: Text(
                'Begin',
                style: FK.sans(
                  size: 14,
                  weight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  FLOW CONTROLLER
// ═══════════════════════════════════════════════════════════════
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int _screen = 0;
  int _hours = 5;

  void _go(int next) => setState(() => _screen = next);

  @override
  Widget build(BuildContext context) {
    final Widget current = switch (_screen) {
      0 => SplashScreen(key: const ValueKey(0), onDone: () => _go(1)),
      1 => QuestionScreen(
        key: const ValueKey(1),
        onNext: (h) {
          _hours = h;
          _go(2);
        },
      ),
      2 => TruthScreen(
        key: const ValueKey(2),
        hours: _hours,
        onNext: () => _go(3),
      ),
      _ => MessageScreen(
        key: const ValueKey(3),
        onBegin: () async {
          await StorageServices.instance.setCompletedOnboarding();
          Get.offAllNamed(Routes.login);
        },
      ),
    };

    return Scaffold(
      backgroundColor: FK.cream,
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: current,
        ),
      ),
    );
  }
}
