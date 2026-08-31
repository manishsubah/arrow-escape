import 'package:flutter/material.dart';

import 'package:arrow_puzzle/ui/core/skeuo.dart';

/// A chunky, glossy, pressable 3D button — the core skeuomorphic control.
///
/// Renders a candy-colored face sitting on a darker base "lip" so the button
/// looks physically raised. Pressing sinks the face down onto the base for a
/// satisfying tactile feel. Big, rounded and colorful for young players.
///
/// Disabled buttons are not simply faded: the face is drained toward
/// [Skeuo.muted], the gloss is removed and the drop shadow is dropped, so they
/// read as grey plastic that was never lit rather than as a translucent ghost.
class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    super.key,
    required this.child,
    required this.color,
    this.onTap,
    this.radius = 22,
    this.lipDepth = 7,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    this.width,
    this.height,
    this.enabled = true,
    this.foregroundColor = Skeuo.onCandy,
  });

  final Widget child;

  /// Face color of the button; the base lip and top gloss are derived from it.
  final Color color;
  final VoidCallback? onTap;
  final double radius;

  /// Height of the visible 3D base under the face.
  final double lipDepth;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final bool enabled;

  /// Color for text and icons on the face. Pass [Skeuo.ink] on pale faces
  /// (yellow, cream) where white would not have enough contrast.
  final Color foregroundColor;

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _pressed = false;

  bool get _active => widget.enabled && widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    final base = _active ? widget.color : Skeuo.desaturate(widget.color, 0.45);
    final lip = Skeuo.lipOf(base);
    final radius = BorderRadius.circular(widget.radius);
    final pressed = _pressed && _active;
    final foreground = _active
        ? widget.foregroundColor
        : widget.foregroundColor.withValues(alpha: 0.6);

    // Constant footprint: total vertical padding always equals lipDepth, so the
    // face simply slides down onto the base when pressed (no layout jump).
    final facePadding = pressed
        ? EdgeInsets.only(top: widget.lipDepth)
        : EdgeInsets.only(bottom: widget.lipDepth);

    Widget face = Container(
      height: widget.height,
      padding: widget.padding,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Skeuo.faceOf(base), base],
        ),
      ),
      // Glossy top sheen — flattened out while disabled so the face looks dull.
      foregroundDecoration: BoxDecoration(
        borderRadius: radius,
        gradient: Skeuo.gloss(alpha: _active ? 0.45 : 0.12),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: foreground,
          shadows: _active ? Skeuo.embossedText : null,
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: foreground),
          child: widget.child,
        ),
      ),
    );

    Widget button = Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: lip,
        borderRadius: radius,
        boxShadow: _active ? Skeuo.lift() : null,
      ),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        padding: facePadding,
        child: face,
      ),
    );

    return GestureDetector(
      onTapDown: _active ? (_) => setState(() => _pressed = true) : null,
      onTapUp: _active ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: _active ? () => setState(() => _pressed = false) : null,
      onTap: _active ? widget.onTap : null,
      child: button,
    );
  }
}
