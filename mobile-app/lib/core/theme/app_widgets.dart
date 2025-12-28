import 'package:flutter/material.dart';
import 'design_system.dart';

/// Small helpers to ensure consistent use of cards and headings.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.margin = const EdgeInsets.symmetric(vertical: 8)});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: DesignSystem.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: DesignSystem.border, width: 1),
      ),
      elevation: DesignSystem.elevationLow,
      margin: margin,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class AppHeading extends StatelessWidget {
  final String title;
  const AppHeading(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).textTheme.titleLarge?.color ?? DesignSystem.textDark;
    return Text(
      title,
      style: TextStyle(
        color: color,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
