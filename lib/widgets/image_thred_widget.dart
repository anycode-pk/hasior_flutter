import 'package:flutter/material.dart';
import 'package:hasior_flutter/classes/global_snackbar.dart';
import 'package:hasior_flutter/classes/logo.dart';
import 'package:hasior_flutter/constants/language_constants.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/models/thred.dart';
import 'package:hasior_flutter/services/api_service.dart';

class ImageThredWidget extends StatefulWidget {
  final Thred thred;
  static const grayColor = Color.fromRGBO(105, 105, 105, 1);
  const ImageThredWidget({super.key, required this.thred});

  @override
  State<ImageThredWidget> createState() => _ImageThredWidgetState();
}

class _ImageThredWidgetState extends State<ImageThredWidget> {
  void handleClick(String value, BuildContext context, Thred thred) {
    if (value == translation(context).delete.capitalize()) {
      showAlertDialog(context, thred);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => {
        showModalBottomSheet<void>(
            context: context,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            builder: (BuildContext context) {
              return generateModal(context);
            })
      },
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (widget.thred.images != null && widget.thred.images!.isNotEmpty)
              Image.network(
                widget.thred.images![0].path,
                fit: BoxFit.fitHeight,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return const CircularProgressIndicator();
                },
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(Logo().getPath());
                },
              ),
            if (widget.thred.title != null)
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.thred.title!,
                        style: const TextStyle(fontSize: 21),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: PopupMenuButton<String>(
                        onSelected: (value) =>
                            handleClick(value, context, widget.thred),
                        itemBuilder: (BuildContext context) {
                          return {translation(context).delete.capitalize()}
                              .map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            if (widget.thred.text != null)
              const Divider(
                thickness: 0.1,
                indent: 18,
                endIndent: 18,
              ),
            if (widget.thred.text != null)
              ListTile(
                title: Text(
                  widget.thred.text!,
                  style: const TextStyle(fontSize: 16),
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
      ),
    );
  }

  Widget generateModal(BuildContext context) {
    return SizedBox(
        height: 200,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 6.0, bottom: 2.0, left: 20.0),
              alignment: Alignment.centerLeft,
              child: Text(
                translation(context).manage_thred.capitalize(),
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const Divider(
              color: ImageThredWidget.grayColor,
              thickness: 0.1,
              indent: 18,
              endIndent: 18,
            ),
            // ListTile(
            //   leading: const Icon(Icons.edit),
            //   title: Text(translation(context).edit.capitalize()),
            //   onTap: () {
            //     // Navigator.push(
            //     //   context,
            //     //   MaterialPageRoute(
            //     //       builder: (context) =>
            //     //           CreateOrEditEvent(
            //     //               event: event)),
            //     // );
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: Text(translation(context).delete.capitalize()),
              onTap: () async {
                await showAlertDialog(context, widget.thred);
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ));
  }

  Future<void> showAlertDialog(BuildContext context, Thred thred) async {
    Widget cancelButton = TextButton(
      child: Text(translation(context).cancel.capitalize()),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = ElevatedButton(
        onPressed: () async {
          try {
            await ApiService().deleteThred(thred.id!).then((value) {
              GlobalSnackbar.infoSnackbar(context,
                  translation(context).thred_successfully_deleted.capitalize());
              Navigator.pop(context);
            });
          } catch (e) {
            Navigator.pop(context);
            GlobalSnackbar.errorSnackbar(context,
                translation(context).error_while_deleting_thred.capitalize());
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: Text(translation(context).delete.capitalize()));
    AlertDialog alert = AlertDialog(
      title: Text(translation(context).delete_thred_question.capitalize()),
      content: Text(translation(context).confirm_deletion_thred.capitalize()),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
