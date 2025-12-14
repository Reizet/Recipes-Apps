import 'package:flutter/material.dart';

class InputCard extends StatelessWidget {
  final Widget child;

  const InputCard({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Color(0x11000000), blurRadius: 18, offset: Offset(0,8))],
      ),
      child: child,
    );
  }
}

