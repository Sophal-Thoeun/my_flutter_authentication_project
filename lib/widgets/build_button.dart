import 'package:flutter/material.dart';
import 'package:flutter_assignment_auth_maps/config/palette.dart';

class BuildButton extends StatelessWidget {
  final String text;
  final Function() onTap;
  final double width;
  final Color? color;
  final Color? textColor;

  const BuildButton({
    Key? key,
    this.text = 'text',
    required this.onTap,
    this.width = 100.0,
    this.color,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: InkWell(
          onTap: onTap,
          child: Container(
            width: width,
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: color,
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
