import 'package:flutter/material.dart';

class ThredCardWidget extends StatefulWidget {
  const ThredCardWidget(
      {super.key,
      required this.text,
      required this.owner});

  final String text;
  final String owner;

  @override
  State<ThredCardWidget> createState() => _ThredCardWidgetState();
}

class _ThredCardWidgetState extends State<ThredCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text(widget.owner)
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.text,
            ),
          ),
        ],
      ),
    );
  }
}
