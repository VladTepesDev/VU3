import 'package:flutter/material.dart';
import '../services/sound_service.dart';

/// Wrapper that adds tap sound to any tappable widget
class TapSound extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const TapSound({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (onTap == null) {
      return child;
    }

    return GestureDetector(
      onTap: () {
        SoundService().playTapSound();
        onTap?.call();
      },
      child: child,
    );
  }
}

/// Extension to wrap any GestureDetector's onTap with sound
GestureDetector gestureDetectorWithSound({
  required VoidCallback? onTap,
  required Widget child,
  HitTestBehavior? behavior,
}) {
  return GestureDetector(
    onTap: onTap == null
        ? null
        : () {
            SoundService().playTapSound();
            onTap();
          },
    behavior: behavior,
    child: child,
  );
}
