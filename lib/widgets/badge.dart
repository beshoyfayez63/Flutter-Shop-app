import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  final Widget child;
  final String value;
  final Color? color;

  const Badge({
    required this.child,
    required this.value,
    this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(10),
              shape: BoxShape.circle,
              color: color ?? Theme.of(context).colorScheme.secondary,
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        )
      ],
    );
  }
}
