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
    this.blur = 30,
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
    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: widget.isPrimary ? [
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: 0.2),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: 0.1),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ] : [
            BoxShadow(
              color: const Color(0xFF000000).withValues(alpha: 0.08),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: const Color(0xFFFFFFFF).withValues(alpha: 0.8),
              blurRadius: 1,
              spreadRadius: 0,
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
                splashColor: widget.isPrimary
                    ? const Color(0xFFFFFFFF).withValues(alpha: 0.2)
                    : const Color(0xFF000000).withValues(alpha: 0.05),
                highlightColor: widget.isPrimary
                    ? const Color(0xFFFFFFFF).withValues(alpha: 0.1)
                    : const Color(0xFF000000).withValues(alpha: 0.03),
                child: Container(
                  padding: widget.padding ?? const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFFFFFF).withValues(alpha: 0.95),
                        const Color(0xFFFFFFFF).withValues(alpha: 0.9),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    border: Border.all(
                      color: const Color(0xFFFFFFFF).withValues(alpha: 0.9),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        color: Color(0xFF1C1C1E),
                        fontSize: 16,
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
                        const Color(0xFFFFFFFF).withValues(alpha: 0.9),
                        const Color(0xFFFAFAFA).withValues(alpha: 0.85),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFFFFFFFF).withValues(alpha: 0.95),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      color: widget.color ?? const Color(0xFF1C1C1E),
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
