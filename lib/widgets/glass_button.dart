import 'dart:ui';
import 'package:flutter/material.dart';

class GlassButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? color;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final bool isPrimary;

  const GlassButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.color,
    this.blur = 20,
    this.padding,
    this.isPrimary = false,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isPrimary 
        ? const Color(0xFF1A1A1A)
        : (widget.color ?? Colors.white);

    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.9),
              blurRadius: 2,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                splashColor: baseColor.withValues(alpha: 0.2),
                highlightColor: baseColor.withValues(alpha: 0.1),
                child: Container(
                  padding: widget.padding ?? const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: widget.isPrimary ? [
                        baseColor.withValues(alpha: 0.9),
                        baseColor.withValues(alpha: 0.8),
                      ] : [
                        baseColor.withValues(alpha: 0.25),
                        baseColor.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(
                      color: widget.isPrimary 
                          ? Colors.white.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: widget.isPrimary ? Colors.white : const Color(0xFF1A1A1A),
                        fontWeight: FontWeight.w600,
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GlassIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final double size;
  final Color? color;

  const GlassIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = 50,
    this.color,
  });

  @override
  State<GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<GlassIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.9 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                onTapDown: (_) => setState(() => _isPressed = true),
                onTapUp: (_) => setState(() => _isPressed = false),
                onTapCancel: () => setState(() => _isPressed = false),
                customBorder: const CircleBorder(),
                splashColor: Colors.white.withValues(alpha: 0.3),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.25),
                        Colors.white.withValues(alpha: 0.15),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      color: widget.color ?? const Color(0xFF1A1A1A),
                      size: widget.size * 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
