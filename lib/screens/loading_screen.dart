import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  final bool shouldZoomOut;
  
  const LoadingScreen({super.key, this.shouldZoomOut = false});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _zoomController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _zoomAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    // Pulsing animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Zoom out animation - 0.8 seconds
    _zoomController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _zoomAnimation = Tween<double>(
      begin: 1.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _zoomController,
      curve: Curves.easeInCubic,
    ));

    // Opacity animation - fades out as it zooms
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _zoomController,
      curve: Curves.easeIn,
    ));
  }

  @override
  void didUpdateWidget(LoadingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldZoomOut && !oldWidget.shouldZoomOut) {
      _pulseController.stop();
      _zoomController.forward();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/app_background.png'),
          fit: BoxFit.cover,
          opacity: 0.6,
        ),
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_pulseAnimation, _zoomAnimation, _opacityAnimation]),
          builder: (context, child) {
            final scale = _pulseAnimation.value * _zoomAnimation.value;
            final opacity = _opacityAnimation.value;
            return Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Image.asset(
                  'assets/images/app_logo.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
