import 'package:flutter/material.dart';

class ImageThredWidget extends StatelessWidget {
  final String imagePath;
  final String? text;

  const ImageThredWidget({
    Key? key,
    required this.imagePath,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            imagePath,
            fit: BoxFit.fitHeight,
          ),
          if (text != null) 
            ListTile(
              title: Text(
                text!,
                style: const TextStyle(
                  fontSize: 16
                ),
              ),
            ),
          const ButtonBar(
            alignment: MainAxisAlignment.start,
            children: <Widget>[
              // IconButton(
              //   icon: Icon(Icons.comment),
              //   onPressed: () {
              //     // Handle comment button press
              //   },
              // ),
              // IconButton(
              //   icon: Icon(Icons.favorite),
              //   onPressed: () {
              //     // Handle favorite button press
              //   },
              // ),
            ],
          ),
        ],
      ),
    );
  }
}
