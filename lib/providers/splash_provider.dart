import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:planit/data/splash_texts.dart';
import 'package:flutter/foundation.dart'; // for @immutable

@immutable
class SplashState {
  final int messageIndex;
  final bool visible;
  final bool showAppName;
  final bool showGetStarted;
  final int currentCenterIndex;

  const SplashState({
    this.messageIndex = 0,
    this.visible = false,
    this.showAppName = false,
    this.showGetStarted = false,
    this.currentCenterIndex = 0,
  });

  SplashState copyWith({
    int? messageIndex,
    bool? visible,
    bool? showAppName,
    bool? showGetStarted,
    int? currentCenterIndex,
  }) {
    return SplashState(
      messageIndex: messageIndex ?? this.messageIndex,
      visible: visible ?? this.visible,
      showAppName: showAppName ?? this.showAppName,
      showGetStarted: showGetStarted ?? this.showGetStarted,
      currentCenterIndex: currentCenterIndex ?? this.currentCenterIndex,
    );
  }
}

class SplashNotifier extends StateNotifier<SplashState> {
  SplashNotifier() : super(const SplashState());

  Timer? _centerTimer;
  bool _stopCenter = false;

  // timings (kept near original)
  final Duration _fadeIn = const Duration(milliseconds: 400);
  final Duration _hold = const Duration(milliseconds: 900);
  final Duration _fadeOut = const Duration(milliseconds: 300);
  final Duration _centeredHold = const Duration(seconds: 2);
  final Duration _centerKeepDuration = const Duration(seconds: 5);
  final Duration _centerPause = const Duration(milliseconds: 500);

  // This padding covers the animation forward+reverse time in the widget.
  // Your widget's controller uses 600ms forward + 600ms reverse => 1200ms.
  // Keep this in sync with the widget's animation durations.
  final Duration _animationPadding = const Duration(milliseconds: 1200);

  List<String> get loadingTexts => SplashTexts.messages;
  List<String> get centerQuotes => SplashTexts.centerQuotes;

  /// Start the entire sequence (messages -> app name -> get started -> center loop)
  Future<void> startSequence() async {
    try {
      // show up to first 3 loading messages
      final showCount = loadingTexts.length < 3 ? loadingTexts.length : 3;
      await Future.delayed(const Duration(milliseconds: 200));

      for (var i = 0; i < showCount; i++) {
        if (!mounted) return;
        state = state.copyWith(messageIndex: i, visible: true);
        await Future.delayed(_fadeIn + _hold);
        if (!mounted) return;
        state = state.copyWith(visible: false);
        await Future.delayed(_fadeOut);
      }

      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 120));
      state = state.copyWith(showAppName: true);
      await Future.delayed(_centeredHold);
      if (!mounted) return;

      // Start center loop: emit first index BEFORE flipping showGetStarted
      // so the UI has a consistent first quote to animate to.
      if (centerQuotes.isNotEmpty) {
        _emitCenterIndex(0);
      }

      // Now show Get Started and start the repeating loop.
      state = state.copyWith(
        showAppName: false,
        showGetStarted: true,
        // currentCenterIndex already emitted above
      );

      _stopCenter = false;
      _startCenterLoop();
    } catch (e, st) {
      // defensive: log and fallback to show the button so UI isn't blank
      debugPrint('SplashNotifier.startSequence error: $e\n$st');
      if (mounted) {
        state = state.copyWith(showGetStarted: true);
      }
    }
  }

  /// internal: update center index loop asynchronously
  void _startCenterLoop() {
    // Cancel if already running
    _centerTimer?.cancel();

    if (!mounted || centerQuotes.isEmpty) return;

    int i = 1; // we already emitted index 0 when starting sequence
    // period must include the widget animation time to avoid overlap
    final period = _centerKeepDuration + _centerPause + _animationPadding;

    _centerTimer = Timer.periodic(period, (Timer timer) {
      if (!mounted || _stopCenter) {
        timer.cancel();
        return;
      }
      _emitCenterIndex(i);
      i++;
    });
  }

  void _emitCenterIndex(int i) {
    if (!mounted || centerQuotes.isEmpty) return;
    final idx = i % centerQuotes.length;
    state = state.copyWith(currentCenterIndex: idx);
  }

  /// Stop the center loop (call when navigating away or confirmed)
  Future<void> stopCenterLoop() async {
    _stopCenter = true;
    _centerTimer?.cancel();
    _centerTimer = null;
  }

  /// Called when user confirms Get Started
  Future<void> onConfirmed() async {
    await stopCenterLoop();
    // hide the button if needed
    state = state.copyWith(showGetStarted: false);
  }

  @override
  void dispose() {
    _centerTimer?.cancel();
    super.dispose();
  }
}

/// Provider
final splashProvider =
    StateNotifierProvider<SplashNotifier, SplashState>((ref) {
  return SplashNotifier();
});
