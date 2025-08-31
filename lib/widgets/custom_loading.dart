import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomLoading extends StatefulWidget {
  final String? message;
  final double size;
  final Color? backgroundColor;

  const CustomLoading({
    super.key,
    this.message,
    this.size = 120.0,
    this.backgroundColor,
  });

  @override
  State<CustomLoading> createState() => _CustomLoadingState();
}

class _CustomLoadingState extends State<CustomLoading>
    with TickerProviderStateMixin {
  late AnimationController _heartbeatController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  late Animation<double> _heartbeatAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Heartbeat animation - like a real heartbeat with two beats
    _heartbeatController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _heartbeatAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.25,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.25,
          end: 0.95,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.95,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.linear)),
        weight: 50,
      ),
    ]).animate(_heartbeatController);

    // Gentle pulse for the glow effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Fade animation for loading dots
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start animations
    _heartbeatController.repeat();
    _pulseController.repeat(reverse: true);
    _fadeController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor ?? const Color(0xFFF0F9F7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo with Heartbeat Effect
            AnimatedBuilder(
              animation: Listenable.merge([
                _heartbeatAnimation,
                _pulseAnimation,
                _fadeAnimation,
              ]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _heartbeatAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF4FC3A1,
                            ).withValues(alpha: 0.4 * _pulseAnimation.value),
                            blurRadius: 25 * _pulseAnimation.value,
                            spreadRadius: 8 * _pulseAnimation.value,
                          ),
                          BoxShadow(
                            color: const Color(0xFFFF6B9D).withValues(
                              alpha: 0.2 * _heartbeatAnimation.value,
                            ),
                            blurRadius: 15 * _heartbeatAnimation.value,
                            spreadRadius: 3 * _heartbeatAnimation.value,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/load.png',
                          width: widget.size,
                          height: widget.size,
                          fit: BoxFit.cover,
                          frameBuilder:
                              (context, child, frame, wasSynchronouslyLoaded) {
                                if (frame == null) {
                                  // Still loading
                                  return Container(
                                    width: widget.size,
                                    height: widget.size,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey.withValues(alpha: 0.3),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF4FC3A1),
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                }

                                if (kDebugMode) {
                                  print(
                                    '✅ Successfully loaded assets/load.png',
                                  );
                                }
                                return child;
                              },
                          errorBuilder: (context, error, stackTrace) {
                            // Debug: Print detailed error information
                            if (kDebugMode) {
                              print('❌ Error loading assets/load.png: $error');
                              print('📍 Stack trace: $stackTrace');
                            }

                            // Fallback if logo doesn't load - heart icon for maternal theme
                            return Container(
                              width: widget.size,
                              height: widget.size,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF4FC3A1),
                                    Color(0xFF2E7D5A),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                size: 60,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // Loading dots animation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _fadeController,
                  builder: (context, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Opacity(
                        opacity: (index == 0)
                            ? _fadeAnimation.value
                            : (index == 1)
                            ? (1 - _fadeAnimation.value)
                            : _fadeAnimation.value,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF4FC3A1),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: 20),

            // Loading message
            if (widget.message != null) ...[
              Text(
                widget.message!,
                style: const TextStyle(
                  fontFamily: 'CircularStd',
                  fontSize: 16,
                  color: Color(0xFF2E7D5A),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
            ],

            // App name
            const Text(
              'Maternal Health',
              style: TextStyle(
                fontFamily: 'CircularStd',
                fontSize: 20,
                color: Color(0xFF4FC3A1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple version for small loading indicators
class MiniLoading extends StatefulWidget {
  final double size;
  final Color? color;

  const MiniLoading({super.key, this.size = 40.0, this.color});

  @override
  State<MiniLoading> createState() => _MiniLoadingState();
}

class _MiniLoadingState extends State<MiniLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Heartbeat-style animation for mini loading too
    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.2,
          end: 0.9,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.9,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.1,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.linear)),
        weight: 30,
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (widget.color ?? const Color(0xFF4FC3A1)).withValues(
                    alpha: 0.3 * _animation.value,
                  ),
                  blurRadius: 10 * _animation.value,
                  spreadRadius: 2 * _animation.value,
                ),
              ],
            ),
            child: Image.asset(
              'assets/load.png',
              width: widget.size,
              height: widget.size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color ?? const Color(0xFF4FC3A1),
                  ),
                  child: Icon(
                    Icons.favorite_rounded,
                    size: widget.size * 0.6,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
