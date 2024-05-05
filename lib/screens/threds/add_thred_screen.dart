import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hasior_flutter/classes/global_snackbar.dart';
import 'package:hasior_flutter/constants/language_constants.dart';
import 'package:hasior_flutter/enums/groups.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/models/thred.dart';
import 'package:hasior_flutter/services/api_service.dart';
import 'package:hasior_flutter/theme.dart';
import 'package:image_picker/image_picker.dart';

class AddThred extends StatefulWidget {
  const AddThred({super.key, required this.groupToAdd});

  final Groups groupToAdd;

  @override
  State<AddThred> createState() => _AddThredState();
}

class _AddThredState extends State<AddThred> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _image;
  Image? image;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        image = Image.file(_image!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return translation(context).enter_name.capitalize();
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: "${translation(context).name.capitalize()}*",
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 5,
                  controller: _textController,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: translation(context).description.capitalize(),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      )),
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
                      child:
                          Text(translation(context).add_picture.capitalize()),
                    )),
                displayAddedImage(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: Text(translation(context).cancel.capitalize()),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: primarycolor),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await createNewthred();
                          if (mounted) {
                            GlobalSnackbar.successSnackbar(
                                context,
                                translation(context)
                                    .thred_successfully_added
                                    .capitalize());
                            Navigator.of(context).pop(true);
                          }
                        }
                      },
                      child: Text(translation(context).save.capitalize()),
                    ),
                  ],
                ),
              ],
            ),
          )),
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
    if (!responseImage && mounted) {
      GlobalSnackbar.errorSnackbar(
          context,
          translation(context)
              .error_occurred_during_uploading_photo
              .capitalize());
      return false;
    }

    return true;
  }

  Future<bool> createNewthred() async {
    Thred? response = await ApiService().createThred(
        _titleController.text.isNotEmpty ? _titleController.text : null,
        _textController.text.isNotEmpty ? _textController.text : null,
        widget.groupToAdd);
    if (response == null && mounted) {
      GlobalSnackbar.errorSnackbar(
          context,
          translation(context)
              .error_occurred_during_creating_thred
              .capitalize());
      return false;
    }

    var imageResponse = await uploadImage(response!.id!);
    return imageResponse;
  }
}
