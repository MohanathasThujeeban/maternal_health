import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Custom loading widget with animated logo and heartbeat effect
/// Displays a circular logo with pulsing animation and optional message
class CustomLoading extends StatefulWidget {
  // Optional message to display below the loading animation
  final String? message;

  // Size of the loading logo (default: 120.0)
  final double size;

  // Background color of the loading screen
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
  // Controller for heartbeat animation (simulates real heartbeat pattern)
  late AnimationController _heartbeatController;

  // Controller for glow/pulse effect around logo
  late AnimationController _pulseController;

  // Controller for fade animation on loading dots
  late AnimationController _fadeController;

  // Animation for heartbeat scale effect
  late Animation<double> _heartbeatAnimation;

  // Animation for pulsing glow
  late Animation<double> _pulseAnimation;

  // Animation for fading loading dots
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize heartbeat animation controller
    // Creates a realistic heartbeat pattern with two beats (lub-dub)
    _heartbeatController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    // Create heartbeat animation sequence with 5 phases
    _heartbeatAnimation = TweenSequence<double>([
      // Phase 1: First beat expansion ("lub")
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.25,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      // Phase 2: First beat contraction
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.25,
          end: 0.95,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      // Phase 3: Second beat expansion ("dub")
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.95,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 10,
      ),
      // Phase 4: Second beat contraction
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 10,
      ),
      // Phase 5: Rest period before next heartbeat
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.linear)),
        weight: 50,
      ),
    ]).animate(_heartbeatController);

    // Initialize pulse controller for glow effect
    // Creates a gentle pulsing animation for the shadow/glow
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    // Pulse animation oscillates between 0.8 and 1.2
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Initialize fade controller for loading dots animation
    // Creates a smooth fade in/out effect
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    // Fade animation oscillates between 0.6 and 1.0 opacity
    _fadeAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start all animations
    _heartbeatController.repeat(); // Continuous heartbeat loop
    _pulseController.repeat(reverse: true); // Bidirectional pulse
    _fadeController.repeat(reverse: true); // Bidirectional fade
  }

  @override
  void dispose() {
    // Clean up animation controllers to prevent memory leaks
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
            // Main animated logo with heartbeat effect and glow
            // Combines multiple animations for realistic effect
            AnimatedBuilder(
              // Merge all animations to rebuild when any changes
              animation: Listenable.merge([
                _heartbeatAnimation,
                _pulseAnimation,
                _fadeAnimation,
              ]),
              builder: (context, child) {
                return Transform.scale(
                  // Apply heartbeat scaling effect
                  scale: _heartbeatAnimation.value,
                  child: Opacity(
                    // Apply fade effect
                    opacity: _fadeAnimation.value,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // Apply dual-color glow shadows
                        boxShadow: [
                          // Primary glow (teal color, pulse-synced)
                          BoxShadow(
                            color: const Color(
                              0xFF4FC3A1,
                            ).withValues(alpha: 0.4 * _pulseAnimation.value),
                            blurRadius: 25 * _pulseAnimation.value,
                            spreadRadius: 8 * _pulseAnimation.value,
                          ),
                          // Secondary glow (pink color, heartbeat-synced)
                          BoxShadow(
                            color: const Color(0xFFFF6B9D).withValues(
                              alpha: 0.2 * _heartbeatAnimation.value,
                            ),
                            blurRadius: 15 * _heartbeatAnimation.value,
                            spreadRadius: 3 * _heartbeatAnimation.value,
                          ),
                        ],
                      ),
                      // Clip image into circular shape
                      child: ClipOval(
                        child: Image.asset(
                          'assets/load.png',
                          width: widget.size,
                          height: widget.size,
                          fit: BoxFit.cover,
                          // Handle image loading states
                          frameBuilder:
                              (context, child, frame, wasSynchronouslyLoaded) {
                                if (frame == null) {
                                  // Show placeholder while image is loading
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

                                // Log successful image load in debug mode
                                if (kDebugMode) {
                                  print(
                                    '✅ Successfully loaded assets/load.png',
                                  );
                                }
                                return child;
                              },
                          // Handle image loading errors
                          errorBuilder: (context, error, stackTrace) {
                            // Print detailed error information for debugging
                            if (kDebugMode) {
                              print('❌ Error loading assets/load.png: $error');
                              print('📍 Stack trace: $stackTrace');
                            }

                            // Fallback UI: Show heart icon if image fails to load
                            // Heart icon fits the maternal health theme
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

            // Three animated loading dots below logo
            // Each dot has different fade timing for wave effect
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _fadeController,
                  builder: (context, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Opacity(
                        // Create staggered fade effect across dots
                        // Dot 0 & 2: fade with animation, Dot 1: fade inversely
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

            // Optional custom message (if provided)
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

            // Application name display
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

/// Compact loading indicator for inline use
/// Uses same heartbeat animation but in smaller format
class MiniLoading extends StatefulWidget {
  // Size of the mini loading indicator (default: 40.0)
  final double size;

  // Optional custom color for the indicator
  final Color? color;

  const MiniLoading({super.key, this.size = 40.0, this.color});

  @override
  State<MiniLoading> createState() => _MiniLoadingState();
}

class _MiniLoadingState extends State<MiniLoading>
    with SingleTickerProviderStateMixin {
  // Single controller for mini loading animation
  late AnimationController _controller;

  // Heartbeat animation for mini indicator
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller with 1 second duration
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Create simplified heartbeat animation sequence for mini version
    _animation = TweenSequence<double>([
      // First beat expansion
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.2,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      // First beat contraction
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.2,
          end: 0.9,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      // Second beat expansion
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.9,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      // Second beat contraction
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.1,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      // Rest period
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.linear)),
        weight: 30,
      ),
    ]).animate(_controller);

    // Start repeating animation
    _controller.repeat();
  }

  @override
  void dispose() {
    // Clean up controller to prevent memory leaks
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          // Apply heartbeat scaling
          scale: _animation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Add animated glow effect
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
            // Display logo image
            child: Image.asset(
              'assets/load.png',
              width: widget.size,
              height: widget.size,
              fit: BoxFit.cover,
              // Fallback if image fails to load
              errorBuilder: (context, error, stackTrace) {
                // Show heart icon as fallback
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
