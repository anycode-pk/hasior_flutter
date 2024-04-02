import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:hasior_flutter/constants/language_constants.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/widgets/offline_widget.dart';

class CreateOrEditThred extends StatefulWidget {
  const CreateOrEditThred({super.key});

  @override
  State<CreateOrEditThred> createState() => _CreateOrEditThredState();
}

class _CreateOrEditThredState extends State<CreateOrEditThred> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  TextStyle textStyle = const TextStyle(fontSize: 16);
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var mainWidget = Scaffold(
      appBar:
          AppBar(title: Text(translation(context).create_thred.capitalize())),
      body: OfflineBuilder(
        connectivityBuilder: (
          BuildContext context,
          ConnectivityResult connectivity,
          Widget child,
        ) {
          if (connectivity == ConnectivityResult.none) {
            return OfflineWidget(
              child: child,
            );
          } else {
            return child;
          }
        },
        builder: (BuildContext context) {
          return CustomScrollView(
            slivers: [
              SliverFillRemaining(
                  hasScrollBody: true,
                  child: Form(
                      key: _formKey,
                      child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Stack(children: [
                            Positioned(child: _createForms()),
                            Positioned(
                                child: Align(
                                    alignment: FractionalOffset.bottomCenter,
                                    child: _createSaveButton()))
                          ]))))
            ],
          );
        },
      ),
    );

    return mainWidget;
  }

  Widget _createForms() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("${translation(context).name.capitalize()}*", style: textStyle),
      const SizedBox(height: 10),
      TextFormField(
        cursorColor: Colors.white,
        controller: nameController,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return translation(context).enter_event_name.capitalize();
          }
          return null;
        },
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: "${translation(context).name.capitalize()}*",
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
      const SizedBox(height: 15)
    ]);
  }

  Widget _createSaveButton() {
    return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          icon: _isLoading
              ? Container(
                  width: 24,
                  height: 24,
                  padding: const EdgeInsets.all(2.0),
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : Container(),
          onPressed: _isLoading ? null : () async {},
          label: _isLoading
              ? const Text("")
              : Text(translation(context).create_thred.capitalize()),
        ));
  }
}
