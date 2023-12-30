import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  Text('OFFLINE'),
                  SizedBox(width: 8.0),
                  SizedBox(
                    width: 12.0,
                    height: 12.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
