import 'package:flutter/material.dart';

class CalcButton extends StatefulWidget {
  final String buttonText;
  final Size size;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final Color borderColor;
  final Color textColor;
  final Color color;
  final double textSize;
  final EdgeInsets margin;

  const CalcButton({
    super.key,
    required this.buttonText,
    required this.size,
    required this.onPressed,
    this.onLongPress,
    this.borderColor = Colors.transparent,
    this.textColor = Colors.white,
    this.color = Colors.black,
    this.textSize = 1.0,
    this.margin = EdgeInsets.zero,
  });

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton> {
  bool _isPressed = false;

  bool _tapHandled = false;

  void _tapDown(TapDownDetails details) {
    if (_tapHandled) return;
    _tapHandled = true;
    setState(() => _isPressed = true);
  }

  void _tapUp(TapUpDetails details) async {
    await Future.delayed(const Duration(milliseconds: 120));
    if (mounted) setState(() => _isPressed = false);
    _tapHandled = false;
  }

  void _tapCancel() {
    if (mounted) setState(() => _isPressed = false);
    _tapHandled = false;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.linearToEaseOut,
      margin: widget.margin,
      width: widget.size.width,
      height: widget.size.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: _isPressed
            ? []
            : [
                const BoxShadow(
                  color: Colors.black,
                  offset: Offset(8, 8),
                  blurRadius: 0,
                  spreadRadius: 0,
                )
              ],
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _tapDown,      
        onTapUp: _tapUp,          
        onTapCancel: _tapCancel,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            overlayColor: Colors.transparent,
            backgroundColor: widget.color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: BorderSide(color: widget.borderColor, width: 2),
            padding: EdgeInsets.zero,
          ),
          onPressed: widget.onPressed,
          onLongPress: widget.onLongPress,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.buttonText,
                style: TextStyle(
                  fontSize: widget.textSize,
                  color: widget.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
