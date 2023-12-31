import 'package:flutter/material.dart';
import 'package:hasior_flutter/constants/language_constants.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';

class OfflineWidget extends StatefulWidget {
  final Widget child;
  const OfflineWidget({super.key, required this.child});

  @override
  State<OfflineWidget> createState() => _OfflineWidgetState();
}

class _OfflineWidgetState extends State<OfflineWidget> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned(
          height: 32.0,
          left: 0.0,
          right: 0.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            color: Colors.red,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: Text(translation(context).you_are_offline.capitalize()),
            ),
          ),
        ),
      ],
    );
  }
}
