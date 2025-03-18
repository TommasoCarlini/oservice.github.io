import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SquaredButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;

  const SquaredButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.icon,
  });

  @override
  State<SquaredButton> createState() => _SquaredButtonState();
}

class _SquaredButtonState extends State<SquaredButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 42.0),
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.orange),
          shape: WidgetStateProperty.all(ContinuousRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(60)))),
          elevation: WidgetStatePropertyAll(16),
          overlayColor: WidgetStatePropertyAll(Colors.deepOrange),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              Icon(
                widget.icon,
                size: 44,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                widget.text,
                style: TextStyle(fontSize: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
