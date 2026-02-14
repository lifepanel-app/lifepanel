import 'package:flutter/material.dart';

/// The 6 core life areas tracked by LifePanel.
enum LifeArea {
  money(
    label: 'Money',
    icon: Icons.account_balance_wallet,
    color: Color(0xFF4CAF50),
    subAreas: [
      'expense', 'income', 'transfer', 'budget', 'investment', 'account',
    ],
  ),
  fuel(
    label: 'Fuel',
    icon: Icons.restaurant,
    color: Color(0xFFFF9800),
    subAreas: [
      'meal', 'liquid', 'supplement', 'recipe', 'grocery', 'meal_prep', 'diet',
    ],
  ),
  work(
    label: 'Work',
    icon: Icons.work,
    color: Color(0xFF2196F3),
    subAreas: [
      'task', 'clock', 'alarm', 'calendar_event', 'career',
    ],
  ),
  mind(
    label: 'Mind',
    icon: Icons.psychology,
    color: Color(0xFF9C27B0),
    subAreas: [
      'mood', 'journal', 'social', 'stress',
    ],
  ),
  body(
    label: 'Body',
    icon: Icons.fitness_center,
    color: Color(0xFFF44336),
    subAreas: [
      'sleep', 'workout', 'menstrual', 'skin_hair', 'health_record',
    ],
  ),
  home(
    label: 'Home',
    icon: Icons.home,
    color: Color(0xFF795548),
    subAreas: [
      'car', 'garden', 'pet', 'cleaning', 'home_inventory',
    ],
  );

  const LifeArea({
    required this.label,
    required this.icon,
    required this.color,
    required this.subAreas,
  });

  final String label;
  final IconData icon;
  final Color color;
  final List<String> subAreas;
}
