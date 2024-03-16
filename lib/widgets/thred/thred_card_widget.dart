import 'package:flutter/material.dart';
import 'package:hasior_flutter/widgets/thred/thred_card_comment_input_widget.dart';
import 'package:hasior_flutter/widgets/thred/thred_card_comment_widget.dart';

class ThredCardWidget extends StatefulWidget {
  const ThredCardWidget({
    super.key, 
    required this.text, 
    required this.imageLink,
    required this.owner});

  final String text;
  final String imageLink;
  final String owner;

  @override
  State<ThredCardWidget> createState() => _ThredCardWidgetState();
}

class _ThredCardWidgetState extends State<ThredCardWidget> {
  Row _buildHeader(BuildContext context) {
    return const Row(children: <Widget>[
      Text(
        "Samorząd studedzki",
        style: TextStyle(
          fontSize: 16,
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
          Image.asset('assets/logo.png'),
          Container(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildHeader(context),
                Container(height: 10),
                const Text(
                  "W naszej restauracji Akacjowa, 𝐰𝐣𝐞𝐜𝐡𝐚ł𝐚 𝐤𝐨𝐥𝐞𝐣𝐧𝐚 𝐧𝐨𝐰𝐨ść ‼ Miło nam ogłosić, że przez najbliższy tydzień królować będzie pizza w  pysznej, nieco innej formie, czyli 𝐂𝐀𝐋𝐙𝐎𝐍𝐄",
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
