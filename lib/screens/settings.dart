import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../class/globalSnackbar.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController apiAddress = TextEditingController();
  bool _isLoading = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future _getData() async {
    try {
      apiAddress.text = await ApiService().getApiAddress() ?? "";
      setState(() {
        _isLoaded = true;
      });
    } catch (e) {
      GlobalSnackbar.errorSnackbar(context, "Błąd podczas ładowania");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Ustawienia"),
          centerTitle: true,
        ),
        body: Visibility(
          visible: _isLoaded,
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
                      child: Column(children: [
                        const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Adres API",
                              style: TextStyle(fontSize: 20),
                            )),
                        const SizedBox(height: 20),
                        TextFormField(
                          cursorColor: Colors.white,
                          controller: apiAddress,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Adres API",
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(20),
                                textStyle: const TextStyle(fontSize: 15)),
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
                                    if (_formKey.currentState!.validate()) {
                                      try {
                                        setState(() {
                                          _isLoading = true;
                                        });
                                        SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                        prefs.setString(
                                            "apiAddress", apiAddress.text);
                                        if (context.mounted) {
                                          GlobalSnackbar.infoSnackbar(
                                              context, "Zapisano ustawienia");
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        }
                                      } on FormatException catch (e) {
                                        GlobalSnackbar.errorSnackbar(context,
                                            "Błąd podczas zapisu: ${e.message}");
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    }
                                  },
                            label: _isLoading
                                ? const Text("")
                                : const Text("Zapisz"),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(20),
                                textStyle: const TextStyle(fontSize: 15)),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Home(),
                                ),
                              );
                            },
                            child: const Text("Przeładuj"),
                          ),
                        ),
                      ]))),
            )
          ]),
        ));
  }
}
