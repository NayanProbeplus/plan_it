// lib/providers/home_cards_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsCardModel {
  final String title;
  final String subtitle;
  final IconData icon;

  StatsCardModel({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

/// Provider that returns the 8 cards for the Home tab.
/// Replace this with a StateNotifier/AsyncNotifier if you fetch data.
final homeCardsProvider = Provider<List<StatsCardModel>>((ref) {
  return [
    StatsCardModel(
        title: 'Tasks', subtitle: '12 open', icon: Icons.check_circle),
    StatsCardModel(
        title: 'Meetings', subtitle: '3 today', icon: Icons.calendar_today),
    StatsCardModel(title: 'Projects', subtitle: '5 active', icon: Icons.folder),
    StatsCardModel(
        title: 'Notes', subtitle: '8 saved', icon: Icons.sticky_note_2),
    StatsCardModel(title: 'Goals', subtitle: '2 due', icon: Icons.flag),
    StatsCardModel(title: 'Habits', subtitle: '7 streak', icon: Icons.repeat),
    StatsCardModel(
        title: 'Payments', subtitle: '6 pending', icon: Icons.payment_rounded),
    StatsCardModel(
        title: 'Analytics', subtitle: 'View stats', icon: Icons.bar_chart),
  ];
});
