import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final IconData iconData;
  final String title;
  final Color textColor, iconColor;
  final double iconSize, fontSize;
  final VoidCallback onPressed;

  const MenuItem({
    Key? key,
    required this.iconData,
    required this.title,
    required this.iconColor,
    required this.textColor,
    required this.onPressed,
    this.iconSize = 22.0,
    this.fontSize = 17.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextButton(
        onPressed: onPressed,
        child: Row(
          children: [
            Icon(
              iconData,
              color: iconColor,
              size: iconSize,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
