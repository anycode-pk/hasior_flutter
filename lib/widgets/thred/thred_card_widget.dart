import 'package:flutter/material.dart';
import 'package:hasior_flutter/widgets/thred/thred_card_comment_input_widget.dart';
import 'package:hasior_flutter/widgets/thred/thred_card_comment_widget.dart';

class ThredCardWidget extends StatefulWidget {
  const ThredCardWidget({super.key, required this.text});

  final String text;

  @override
  State<ThredCardWidget> createState() => _ThredCardWidgetState();
}

class _ThredCardWidgetState extends State<ThredCardWidget> {
  Row _buildHeader(BuildContext context) {
    return const Row(children: <Widget>[
      Text(
        "Cards Title 2",
        style: TextStyle(
          fontSize: 24,
          // color: Colors.grey[800],
        ),
      ),
      const Spacer(),
      Text(
        "Samorząd studedzki",
        style: TextStyle(
          fontSize: 18,
          // color: Colors.grey[800],
        ),
      ),
    ]);
  }

  Row _buildFutter(BuildContext context) {
    return Row(
      children: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.transparent,
          ),
          child: const Text(
            "I Like it",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {},
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.transparent,
          ),
          child: const Text(
            "I do not Like it",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {},
        ),
        const Spacer(),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.transparent,
          ),
          child: const Text(
            "Comment",
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            showModalBottomSheet<void>(
              isScrollControlled: true,
              context: context,
              builder: (BuildContext context) {
                return SingleChildScrollView(
                    child: Column(children: [
                  Column(
                      children: [ThredCommentWidget(), ThredCommentWidget()]),
                  Container(height: 10),
                  ThredCommentInputWidget(
                    controller: TextEditingController(),
                    onImageRemoved: () {
                      //on image removed
                    },
                    onSend: () {
                      //on send button pressed
                    },
                  ),
                ]));
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      // Set the shape of the card using a rounded rectangle border with a 8 pixel radius
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      // Set the clip behavior of the card
      clipBehavior: Clip.antiAliasWithSaveLayer,
      // Define the child widgets of the card
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Display an image at the top of the card that fills the width of the card and has a height of 160 pixels
          Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/logo.png"),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.25),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 4),
                )
              ])),
          // Add a container with padding that contains the card's title, text, and buttons
          Container(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildHeader(context),
                Container(height: 10),
                Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 15,
                    // color: Colors.grey[700],
                  ),
                ),
                Container(height: 10),
                _buildFutter(context)
              ],
            ),
          ),
          Container(height: 5),
        ],
      ),
    );
  }
}
