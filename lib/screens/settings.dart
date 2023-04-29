import 'package:flutter/material.dart';
import 'package:hasior_flutter/classes/language.dart';
import 'package:hasior_flutter/classes/language_constants.dart';
import 'package:hasior_flutter/extensions/string_capitalize.dart';
import 'package:hasior_flutter/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../classes/globalSnackbar.dart';
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
      GlobalSnackbar.errorSnackbar(
          context, translation(context).error_while_loading.capitalize());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(translation(context).settings.capitalize()),
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
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              translation(context).language.capitalize(),
                              style: const TextStyle(fontSize: 20),
                            )),
                        const SizedBox(height: 20),
                        DropdownButtonFormField(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            value: Language.languageList()
                                .firstWhere((language) =>
                                    language.languageCode ==
                                    AppLocalizations.of(context)!.localeName)
                                .languageCode,
                            items: Language.languageList()
                                .map((item) => DropdownMenuItem<String>(
                                    value: item.languageCode,
                                    child: Text(item.name)))
                                .toList(),
                            onChanged: (String? language) async {
                              if (language != null) {
                                Locale? locale = await setLocale(language);
                                MyApp.setLocale(context, locale);
                              }
                            }),
                        const SizedBox(height: 20),
                        const Divider(
                          color: Color.fromRGBO(105, 105, 105, 1),
                        ),
                        const SizedBox(height: 20),
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              translation(context).api_address,
                              style: const TextStyle(fontSize: 20),
                            )),
                        const SizedBox(height: 20),
                        TextFormField(
                          cursorColor: Colors.white,
                          controller: apiAddress,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: translation(context).api_address,
                            focusedBorder: const OutlineInputBorder(
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
                                              context,
                                              translation(context)
                                                  .settings_saved
                                                  .capitalize());
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        }
                                      } on FormatException catch (e) {
                                        GlobalSnackbar.errorSnackbar(context,
                                            "${translation(context).error_while_saving_settings.capitalize()}: ${e.message}");
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      }
                                    }
                                  },
                            label: _isLoading
                                ? const Text("")
                                : Text(translation(context).save.capitalize()),
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
                            child:
                                Text(translation(context).reload.capitalize()),
                          ),
                        ),
                      ]))),
            )
          ]),
        ));
  }
}
