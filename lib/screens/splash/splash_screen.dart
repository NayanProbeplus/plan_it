import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:planit/core/router.dart';
import 'package:planit/data/splash_texts.dart';
import 'package:planit/providers/splash_provider.dart';
import 'package:planit/screens/splash/center_quotes_card.dart';
import 'package:planit/utils/utilities.dart';
import 'package:planit/widgets/slide_to_confirm_button.dart';
import 'package:planit/theme/colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  // animation controller for the center quote card
  late final AnimationController _centerCtrl;
  late final Animation<Offset> _centerOffset;
  late final Animation<double> _centerOpacity;

  // keepDuration must match provider's keep duration so forward/reverse timing aligns
  final Duration _centerKeepDuration = const Duration(seconds: 5);

  // local convenience
  List<String> get centerQuotes => SplashTexts.centerQuotes;
  List<String> get loadingTexts => SplashTexts.messages;

  // prevents overlapping concurrent animations
  bool _animating = false;

  @override
  void initState() {
    super.initState();

    _centerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _centerOffset = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _centerCtrl, curve: Curves.easeOut));
    _centerOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _centerCtrl, curve: Curves.easeIn),
    );

    // start the provider sequence after init
    Future.microtask(() async {
      final show = await shouldShowSplashToday();
      if (!show) {
        // navigate straight to home after first frame so context is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // If you prefer replace instead of push:
          context.pushReplacement(Routes.home);
        });
        return;
      }

      // otherwise start the provider sequence as before
      ref.read(splashProvider.notifier).startSequence();
    });
  }

  Future<void> _playCenterAnimation() async {
    if (_animating) return;
    _animating = true;
    try {
      await _centerCtrl.forward(from: 0);
      // keep visible for provider's keepDuration
      await Future.delayed(_centerKeepDuration);
      if (mounted) await _centerCtrl.reverse();
    } catch (_) {
      // ignore if controller disposed or other minor issues
    } finally {
      _animating = false;
    }
  }

  @override
  void dispose() {
    _centerCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SplashState>(splashProvider, (previous, next) {
      final prevIndex = previous?.currentCenterIndex;
      final nextIndex = next.currentCenterIndex;

      final prevShow = previous?.showGetStarted ?? false;
      final nextShow = next.showGetStarted;

      if ((nextShow && !prevShow) || (nextShow && prevIndex != nextIndex)) {
        _playCenterAnimation();
      }
    });

    final state = ref.watch(splashProvider);
    final width = MediaQuery.of(context).size.width;

    final Shader messageShader = const LinearGradient(
      colors: AppColors.messageBlueGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, width * 0.7, 80));

    final messageStyle = TextStyle(
      fontFamily: 'Quicksand',
      fontSize: 32,
      fontWeight: FontWeight.w600,
      height: 1.02,
      letterSpacing: 0.2,
      foreground: Paint()..shader = messageShader,
    );

    const appNameStyle = TextStyle(
      fontFamily: 'Fredoka',
      fontSize: 54,
      fontWeight: FontWeight.w900,
      height: 1.0,
      letterSpacing: 1.6,
      color: AppColors.plannerEmeraldGreen,
    );

    final centerQuoteStyle = TextStyle(
      fontFamily: 'Quicksand',
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.45,
      letterSpacing: 0.25,
      foreground: Paint()..shader = messageShader,
    );

    // safe accessors so empty lists don't crash
    final message = loadingTexts.isNotEmpty
        ? loadingTexts[state.messageIndex % loadingTexts.length]
        : '';
    final centerQuote = centerQuotes.isNotEmpty
        ? centerQuotes[state.currentCenterIndex % centerQuotes.length]
        : '';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: const Alignment(0, -0.25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 0),
                  SizedBox(
                    height: 140,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Loading messages
                        AnimatedOpacity(
                          opacity:
                              (!state.showAppName && state.visible) ? 1 : 0,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              message,
                              style: messageStyle,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                        // App name
                        if (state.showAppName && !state.showGetStarted)
                          const Align(
                            alignment: Alignment.bottomCenter,
                            child: SizedBox(
                              height: 140,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.bottomCenter,
                                child: Text('planIt', style: appNameStyle),
                              ),
                            ),
                          ),

                        // Quote card
                        if (state.showGetStarted)
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: CenterQuoteCard(
                              position: _centerOffset,
                              opacity: _centerOpacity,
                              quote: centerQuote,
                              textStyle: centerQuoteStyle,
                              width: 340,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Get Started button
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SlideToConfirmButton(
                visible: state.showGetStarted,
                title: 'Get Started',
                onConfirmed: () async {
                  // tell provider to stop center loop immediately and hide the button
                  ref.read(splashProvider.notifier).onConfirmed();
                  await markSplashShownToday();
                  context.go(Routes.home);
                  return true;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
