// lib/screens/calendar/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:planit/theme/colors.dart';
import 'package:planit/widgets/gradient_text.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // anchor month for PageView math
  final DateTime _anchor = DateTime.now();
  static const int _middlePage = 10000;
  late final PageController _pageController;

  DateTime _visibleMonth = DateTime.now();
  DateTime? _selected;
  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _middlePage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  DateTime _monthForPage(int page) {
    final offset = page - _middlePage;
    return DateTime(_anchor.year, _anchor.month + offset);
  }

  List<DateTime> _daysInMonthGrid(DateTime month) {
    final firstOfMonth = DateTime(month.year, month.month, 1);
    final lastOfMonth = DateTime(month.year, month.month + 1, 0);

    // Sunday = 0 .. Saturday = 6 (we remap Dart's Mon=1..Sun=7)
    final leading = (firstOfMonth.weekday % 7);
    final daysBefore = leading;
    final totalCells = daysBefore + lastOfMonth.day;
    final rows = (totalCells / 7).ceil();
    final total = rows * 7;
    final startDay = firstOfMonth.subtract(Duration(days: daysBefore));
    return List.generate(total, (i) => startDay.add(Duration(days: i)));
  }

  void _animateToDelta(int delta) {
    final next = _pageController.page?.round() ?? _middlePage;
    _pageController.animateToPage(
      next + delta,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final weekdayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Container(
            // smaller top margin so card starts closer to app bar
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: BoxDecoration(
              // <-- use colorScheme.surface so theme decides light/dark background
              color: cs.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  // subtle shadow; still uses black but with low opacity
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(
                // use the scheme outline for borders
                color: cs.outline.withOpacity(0.20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top controls row: left/right tappable zones (invisible) + month title
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _animateToDelta(-1),
                        behavior: HitTestBehavior.opaque,
                        child: const SizedBox(width: 44, height: 44),
                      ),
                      Expanded(
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _pageController,
                            builder: (context, _) {
                              final page = (_pageController.hasClients
                                      ? (_pageController.page ??
                                          _pageController.initialPage)
                                      : _middlePage)
                                  .round();

                              final month = _monthForPage(page);
                              final monthLabel =
                                  DateFormat.yMMMM().format(month);

                              return GradientText(
                                monthLabel,
                                gradient: AppColors.vibrantGradientBg,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Quicksand',
                                  // use onSurface for fallback readability
                                  color: cs.onSurface,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _animateToDelta(1),
                        behavior: HitTestBehavior.opaque,
                        child: const SizedBox(width: 44, height: 44),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Weekday labels row (single-color for Sun & Mon)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0),
                    child: Row(
                      children: weekdayLabels.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final w = entry.value;
                        final isSunOrMon = idx == 0 || idx == 1;
                        final isFriOrSat = idx == 5 || idx == 6;
                        return Expanded(
                          child: Center(
                            child: Text(
                              w.toUpperCase(),
                              style: TextStyle(
                                color: isSunOrMon
                                    ? AppColors.plannerEmeraldGreen
                                    : isFriOrSat
                                        ? AppColors.accentPink
                                        : cs.onSurface.withOpacity(0.68),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Calendar grid – height reduced a bit
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: 380,
                      minHeight: 280,
                    ),
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (page) {
                        final month = _monthForPage(page);
                        setState(() {
                          _visibleMonth = month;
                          if (_selected != null) {
                            if (!(_selected!.year == month.year &&
                                _selected!.month == month.month)) {
                              _selected = null;
                            }
                          }
                        });
                      },
                      itemBuilder: (context, page) {
                        final month = _monthForPage(page);
                        final days = _daysInMonthGrid(month);

                        final tiles = List<Widget>.generate(days.length, (i) {
                          final d = days[i];
                          final isThisMonth = d.month == month.month;
                          final isToday = _fmt(d) == _fmt(_today);
                          final isSelected =
                              _selected != null && _fmt(d) == _fmt(_selected!);

                          return GestureDetector(
                            onTap: isThisMonth
                                ? () => setState(() => _selected = d)
                                : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 260),
                              margin: const EdgeInsets.all(2),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.accentPurple.withOpacity(0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: isSelected
                                    ? Border.all(
                                        color: AppColors.accentPurple
                                            .withOpacity(0.9),
                                        width: 1.0,
                                      )
                                    : null,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (isToday && !isSelected)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentPink
                                            .withOpacity(0.14),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${d.day}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          height: 1.0,
                                          color: cs.onSurface,
                                        ),
                                      ),
                                    )
                                  else
                                    Text(
                                      '${d.day}',
                                      style: TextStyle(
                                        fontWeight: isThisMonth
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        fontSize: 13,
                                        height: 1.0,
                                        color: isThisMonth
                                            ? AppColors.steelBlue
                                            : cs.onSurface.withOpacity(0.62),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  const SizedBox(height: 2),
                                  // event dots removed as requested
                                ],
                              ),
                            ),
                          );
                        });

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            const childAspect = 0.8; // a bit less tall
                            return GridView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 4),
                              physics: const BouncingScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                childAspectRatio: childAspect,
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4,
                              ),
                              itemCount: tiles.length,
                              itemBuilder: (context, index) {
                                final startDelay = 120 + (index * 26);
                                return _BuildAnimatedTile(
                                  indexDelayMs: startDelay,
                                  child: tiles[index],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Bottom mini details bar — closer to the grid now
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      // use a subtle variant: surfaceVariant if you want more contrast,
                      // otherwise use surface with slight opacity
                      color: cs.surfaceVariant ?? cs.surface.withOpacity(0.98),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selected != null
                                ? DateFormat.yMMMMd().format(_selected!)
                                : 'Select a date',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        if (_selected != null)
                          TextButton(
                            onPressed: () {
                              // open create event (example)
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.accentPurple,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: const Text('Create'),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Smooth tile entrance — fade + subtle scale (keeps it minimal & smooth).
class _BuildAnimatedTile extends StatefulWidget {
  final Widget child;
  final int indexDelayMs;
  const _BuildAnimatedTile({
    required this.child,
    required this.indexDelayMs,
  });

  @override
  State<_BuildAnimatedTile> createState() => _BuildAnimatedTileState();
}

class _BuildAnimatedTileState extends State<_BuildAnimatedTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    _scale = Tween<double>(begin: 0.985, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack),
    );

    Future.delayed(Duration(milliseconds: widget.indexDelayMs), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
