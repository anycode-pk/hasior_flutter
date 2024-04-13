import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hasior_flutter/classes/global_snackbar.dart';
import 'package:hasior_flutter/constants/language_constants.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/models/thred.dart';
import 'package:hasior_flutter/services/api_service.dart';
import 'package:hasior_flutter/theme.dart';
import 'package:image_picker/image_picker.dart';

class AddThred extends StatefulWidget {
  @override
  _AddThredState createState() => _AddThredState();
}

class _AddThredState extends State<AddThred> {
  TextEditingController _textController = TextEditingController();
  String _generatedCode = '';
  File? _image;
  Image? image;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } 
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (_image != null) Image.file(_image!),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 5,
              controller: _textController,
              decoration: InputDecoration(labelText: translation(context).description.capitalize()),
            ),
            const SizedBox(height: 20),
            SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white)),
                  onPressed: () => _getImage(),
                  child: Text(translation(context).add_picture.capitalize()),
                )),
            displayAddedImage(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: () async {
                    await createNewthred();
                    Navigator.of(context).pop(true);
                  },
                  child: Text(translation(context).save.capitalize()),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(translation(context).cancel.capitalize()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget displayAddedImage() {
    if (image == null) {
      return Container();
    }

    return SizedBox(
        height: 120,
        width: 120,
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: image!.image,
                  fit: BoxFit.cover,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.25),
                    spreadRadius: 5,
                    blurRadius: 7,
                  ),
                ],
              ),
              height: 100,
              width: 100,
              child: null,
            ),
            Align(
              alignment: const Alignment(1.5, -1),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    image = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: scaffoldBackgroundColor,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(10),
                ),
                child: const Icon(
                  Icons.clear,
                  color: primarycolor,
                ),
              ),
            )
          ],
        ));
  }

  Future<bool> uploadImage(int id) async {
    if (_image == null && image == null) {
      return true;
    }

    bool responseImage = await ApiService().postImageToThred(id, _image!);
    if (!responseImage) {
      return false;
    }

    return true;
  }

  Future<bool> createNewthred() async {
    Thred? response = await ApiService().createThred(_textController.text, 2);
    if (response == null) {
      GlobalSnackbar.errorSnackbar(
          context, translation(context).an_error_occurred_during_creating_event.capitalize());
      return false;
    }

    var imageResponse = await uploadImage(response.id!);
    return imageResponse;
  }
}
