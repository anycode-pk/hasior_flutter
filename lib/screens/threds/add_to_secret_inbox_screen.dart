import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:hasior_flutter/classes/global_snackbar.dart';
import 'package:hasior_flutter/constants/language_constants.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/models/thred.dart';
import 'package:hasior_flutter/services/api_service.dart';
import 'package:hasior_flutter/widgets/offline_widget.dart';

class AddToSecretInbox extends StatefulWidget {
  const AddToSecretInbox({super.key});

  @override
  State<AddToSecretInbox> createState() => _AddToSecretInboxState();
}

class _AddToSecretInboxState extends State<AddToSecretInbox> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  TextStyle textStyle = const TextStyle(fontSize: 16);
  TextEditingController _textController = TextEditingController();
  TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<bool> createNewthred() async {
    Thred? response = await ApiService()
        .createSecretInBoxThred(_titleController.text, _textController.text);
    if (response == null) {
      GlobalSnackbar.errorSnackbar(
          context,
          translation(context)
              .an_error_occurred_during_creating_thred
              .capitalize());
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(translation(context).secret_inbox_add.capitalize()),
          centerTitle: true),
      body: OfflineBuilder(connectivityBuilder: (
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
      }, builder: (BuildContext context) {
        return Visibility(
            visible: !_isLoading,
            replacement: const Center(
              child: CircularProgressIndicator(),
            ),
            child: CustomScrollView(slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Form(
                    key: _formKey,
                    child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${translation(context).name.capitalize()}*",
                                style: textStyle),
                            TextFormField(
                              cursorColor: Colors.white,
                              controller: _titleController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return translation(context)
                                      .enter_title
                                      .capitalize();
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText:
                                    translation(context).name.capitalize(),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                                "${translation(context).description.capitalize()}*",
                                style: textStyle),
                            TextFormField(
                              cursorColor: Colors.white,
                              controller: _textController,
                              maxLines: 5,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return translation(context)
                                      .enter_description
                                      .capitalize();
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                hintText: translation(context)
                                    .description
                                    .capitalize(),
                                focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            SizedBox(
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
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        if (!_formKey.currentState!
                                            .validate()) {
                                          return;
                                        }

                                        await createNewthred();
                                        GlobalSnackbar.successSnackbar(context, translation(context).secret_message_successfully_added.capitalize());
                                        Navigator.pop(context);
                                      },
                                label: _isLoading
                                    ? const Text("")
                                    : Text(
                                        translation(context).send.capitalize()),
                              ),
                            )
                          ],
                        ))),
              )
            ]));
      }),
    );
  }
}
