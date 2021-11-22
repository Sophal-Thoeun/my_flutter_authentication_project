import 'package:flutter/material.dart';

class CircleButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final Function()? onPressed;
  final Color? color;
  final Color? backgroundColor;

  const CircleButton({
    Key? key,
    required this.icon,
    required this.iconSize,
    this.onPressed,
    this.color,
    this.backgroundColor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        margin: const EdgeInsets.only(right: 5.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(icon),
          iconSize: iconSize,
          color: color,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
