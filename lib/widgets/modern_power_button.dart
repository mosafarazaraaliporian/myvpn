import 'package:flutter/material.dart';
import 'dart:math' as math;

class ModernPowerButton extends StatefulWidget {
  final bool isConnected;
  final bool isLoading;
  final VoidCallback onTap;
  final double size;

  const ModernPowerButton({
    Key? key,
    required this.isConnected,
    required this.isLoading,
    required this.onTap,
    this.size = 140,
  }) : super(key: key);

  @override
  State<ModernPowerButton> createState() => _ModernPowerButtonState();
}

class _ModernPowerButtonState extends State<ModernPowerButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isConnected
                  ? [
                      const Color(0xFF4CAF50),
                      const Color(0xFF45a049),
                    ]
                  : [
                      const Color(0xFF6B7280),
                      const Color(0xFF4B5563),
                    ],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isConnected
                    ? const Color(0xFF4CAF50).withOpacity(0.4)
                    : Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: widget.isLoading
              ? Padding(
                  padding: const EdgeInsets.all(30),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withOpacity(0.8),
                    ),
                  ),
                )
              : Icon(
                  Icons.power_settings_new_rounded,
                  size: widget.size * 0.5,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}
