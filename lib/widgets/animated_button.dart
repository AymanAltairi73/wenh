import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimatedButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final double borderRadius;

  const AnimatedButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
    this.borderRadius = 20,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SizedBox(
              width: widget.width ?? double.infinity,
              height: widget.height ?? 56,
              child: ElevatedButton(
                onPressed: null, // Handled by GestureDetector
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      widget.backgroundColor ?? Theme.of(context).primaryColor,
                  foregroundColor: widget.foregroundColor ?? Colors.white,
                  disabledBackgroundColor:
                      widget.backgroundColor ?? Theme.of(context).primaryColor,
                  disabledForegroundColor:
                      widget.foregroundColor ?? Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, size: 22),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            widget.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
