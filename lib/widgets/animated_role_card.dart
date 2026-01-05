import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Animated role selection card with glassmorphic design
class AnimatedRoleCard extends StatefulWidget {
  final String title;
  // final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Gradient gradient;
  final bool showBadge;
  final String? badgeText;
  final int animationDelay;

  const AnimatedRoleCard({
    super.key,
    required this.title,
    // required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.gradient,
    this.showBadge = false,
    this.badgeText,
    this.animationDelay = 0,
  });

  @override
  State<AnimatedRoleCard> createState() => _AnimatedRoleCardState();
}

class _AnimatedRoleCardState extends State<AnimatedRoleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isHovered = true),
        onTapUp: (_) {
          setState(() => _isHovered = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          transform: Matrix4.identity()
            ..scale(_isHovered ? 1.02 : 1.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.gradient.colors.first.withOpacity(_isHovered ? 0.4 : 0.2),
                  blurRadius: _isHovered ? 24 : 16,
                  offset: Offset(0, _isHovered ? 12 : 8),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.white.withOpacity(0.05),
                          Colors.white.withOpacity(0.02),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          widget.icon,
                          size: 32,
                          color: Colors.white,
                        ),
                      )
                          .animate(
                            onPlay: (controller) => controller.repeat(reverse: true),
                          )
                          .shimmer(
                            duration: 2000.ms,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                      if (widget.showBadge && widget.badgeText != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.badgeText!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // const SizedBox(height: 8),
                  // Text(
                  //   widget.subtitle,
                  //   style: TextStyle(
                  //     fontSize: 14,
                  //     color: Colors.white.withOpacity(0.9),
                  //     height: 1.5,
                  //   ),
                  // ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'ابدأ الآن',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_back,
                        size: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: widget.animationDelay))
        .fadeIn(duration: 600.ms, curve: Curves.easeOut)
        .slideY(begin: 0.3, end: 0, duration: 600.ms, curve: Curves.easeOut);
  }
}
