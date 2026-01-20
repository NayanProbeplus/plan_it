// lib/widgets/glass_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:planit/theme/colors.dart';
import 'package:planit/theme/glass.dart';

class GlassBottomNav extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final VoidCallback onCenterTap;

  const GlassBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.onCenterTap,
  });

  @override
  State<GlassBottomNav> createState() => _GlassBottomNavState();
}

class _GlassBottomNavState extends State<GlassBottomNav>
    with SingleTickerProviderStateMixin {
  late final AnimationController _centerCtrl;
  late final Animation<double> _centerScale;
  late final Animation<double> _centerRotation;

  @override
  void initState() {
    super.initState();
    _centerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _centerScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _centerCtrl, curve: Curves.easeOutBack),
    );

    _centerRotation = Tween<double>(begin: 0.0, end: 0.12).animate(
      CurvedAnimation(parent: _centerCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _centerCtrl.dispose();
    super.dispose();
  }

  void _handleCenterTap() async {
    try {
      await _centerCtrl.forward();
      await _centerCtrl.reverse();
    } finally {
      widget.onCenterTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final bottomInset = mq.viewPadding.bottom;

    const double navBarHeight = 64.0;
    const double horizontalPadding = 16.0;
    const double fabDiameter = 64.0;

    final icons = <IconData>[
      Symbols.home_rounded,
      Symbols.calendar_month_rounded,
      Icons.add,
      Symbols.bar_chart_rounded,
      Symbols.settings_rounded,
    ];

    final labels = <String>['Home', 'Calendar', 'Add', 'Stats', 'Theme'];

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: horizontalPadding,
            right: horizontalPadding,
            bottom: 8.0 + bottomInset * 0.0,
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
            children: [
              // Use GlassContainer to ensure identical glass attributes
              GlassContainer(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  height: navBarHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(5, (i) {
                      if (i == 2) return const SizedBox(width: fabDiameter);

                      final isSelected = widget.selectedIndex == i;
                      return Expanded(
                        child: InkWell(
                          onTap: () => widget.onItemTapped(i),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 6),
                            child: AnimatedColumnIcon(
                              icon: icons[i],
                              label: labels[i],
                              selected: isSelected,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              // center button sits slightly lower (embedded look)
              Positioned(
                top: -fabDiameter * 0.28,
                child: AnimatedBuilder(
                  animation: _centerCtrl,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _centerRotation.value,
                      child: Transform.scale(
                        scale: _centerScale.value,
                        child: child,
                      ),
                    );
                  },
                  child: GestureDetector(
                    onTap: _handleCenterTap,
                    child: SizedBox(
                      width: fabDiameter,
                      height: fabDiameter,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // ambient halo behind FAB (kept)
                          Container(
                            width: fabDiameter + 22,
                            height: fabDiameter + 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppColors.accentPink.withOpacity(0.06),
                                  Colors.transparent,
                                ],
                                center: const Alignment(-0.2, -0.2),
                                radius: 0.9,
                              ),
                            ),
                          ),

                          // Outer thin ring (use Glass border opacity for consistency)
                          Container(
                            width: fabDiameter + 6,
                            height: fabDiameter + 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Glass.borderColor(),
                                width: 1.2,
                              ),
                            ),
                          ),

                          // subtle colored rimlight behind the glass body for identity
                          // (small radial gradient to keep purple/pink rim without full gradient body)
                          Container(
                            width: fabDiameter + 10,
                            height: fabDiameter + 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                center: const Alignment(-0.2, -0.2),
                                radius: 0.85,
                                colors: [
                                  AppColors.accentPurple.withOpacity(0.06),
                                  AppColors.accentPink.withOpacity(0.04),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.45, 1.0],
                              ),
                            ),
                          ),

                          // --- GLASSMORPHIC MAIN BODY (ClipOval + BackdropFilter) ---
                          // MAIN FAB BODY — now uses your thumb gradient
                          ClipOval(
                            child: Container(
                              width: fabDiameter,
                              height: fabDiameter,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.accentPurple.withOpacity(0.95),
                                    AppColors.accentPink.withOpacity(0.95),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        AppColors.accentPink.withOpacity(0.18),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // glossy inner highlight (kept, slightly stronger to read over glass)
                          Container(
                            width: fabDiameter - 14,
                            height: fabDiameter - 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.14),
                                  Colors.white.withOpacity(0.02),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),

                          // twin thin ring for extra border feeling (kept)
                          Container(
                            width: fabDiameter - 8,
                            height: fabDiameter - 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Glass.borderColor(),
                                width: 0.8,
                              ),
                            ),
                          ),

                          // center icon (kept)
                          const Icon(
                            Icons.add,
                            size: 28,
                            color: AppColors.backgroundLight,
                          ),

                          // soft shadow 'notch' under the button (kept)
                          Positioned(
                            bottom: -4,
                            child: Container(
                              width: fabDiameter * 0.9,
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimatedColumnIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const AnimatedColumnIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accentPurple : AppColors.textSecondary;
    final double scale = selected ? 1.12 : 1.0;
    final double yOffset = selected ? -4.0 : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
      transform: Matrix4.identity()..translate(0.0, yOffset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 1.0, end: scale),
            duration: const Duration(milliseconds: 320),
            curve: Curves.elasticOut,
            builder: (context, s, child) {
              return Transform.scale(
                scale: s,
                child: Icon(icon, size: 20, color: color),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
