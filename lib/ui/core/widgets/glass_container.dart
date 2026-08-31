import 'dart:ui';

import 'package:flutter/material.dart';

/// A reusable frosted-glass surface (glassmorphism).
///
/// Renders a translucent tinted panel with a soft white edge highlight, a
/// diagonal sheen and an optional real backdrop blur. It is designed to sit
/// over the app's dark gradient background (plus its floating arrows and
/// particles) so the frosted effect reads.
///
/// Performance note: [BackdropFilter] pushes a save layer and is comparatively
/// expensive. Keep [enableBlur] `true` only for the handful of large panels on
/// a screen. For many small, repeated elements — e.g. the 100-tile level grid —
/// pass `enableBlur: false`: the translucent fill, sheen and border still read
/// as glass without paying for a blur layer per tile.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.blurSigma = 20,
    this.radius = 16,
    this.padding,
    this.tint,
    this.opacity = 0.45,
    this.borderColor,
    this.borderWidth = 1.4,
    this.enableBlur = true,
    this.shadow = true,
    this.width,
    this.height,
    this.onTap,
  });

  /// Base surface color of the glass (defaults to the app surface #1E293B).
  static const Color _defaultTint = Color(0xFF1E293B);

  final Widget child;

  /// Gaussian blur radius applied to the content behind the panel.
  final double blurSigma;

  /// Corner radius of the panel.
  final double radius;

  final EdgeInsetsGeometry? padding;

  /// Base tint; the actual fill is this color at [opacity].
  final Color? tint;

  /// Opacity of the tint fill (0..1). Lower = more see-through.
  final double opacity;

  /// Edge highlight color (defaults to a faint white).
  final Color? borderColor;
  final double borderWidth;

  /// Whether to apply a real [BackdropFilter]. Disable for repeated tiles.
  final bool enableBlur;

  /// Whether to cast a soft drop shadow for depth.
  final bool shadow;

  final double? width;
  final double? height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    final baseTint = (tint ?? _defaultTint).withValues(alpha: opacity);

    // Fill + edge highlight. The diagonal white sheen is painted over the
    // fill (not the child) via [foregroundDecoration] at a low alpha so it
    // catches the top-left "light" without washing out content.
    Widget surface = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: baseTint,
        borderRadius: borderRadius,
        border: Border.all(
          color: borderColor ?? Colors.white.withValues(alpha: 0.24),
          width: borderWidth,
        ),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.18),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.6],
        ),
      ),
      child: child,
    );

    Widget clipped = ClipRRect(
      borderRadius: borderRadius,
      child: enableBlur
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: surface,
            )
          : surface,
    );

    if (shadow) {
      clipped = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: clipped,
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: clipped);
    }
    return clipped;
  }
}
