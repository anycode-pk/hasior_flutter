import 'package:flutter/material.dart';
import 'package:hasior_flutter/services/api_service.dart';

import '../class/globalSnackbar.dart';
import '../theme.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = const TextStyle(fontSize: 16);
    TextEditingController userNameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController passwordRepeatController = TextEditingController();

    return Scaffold(
        backgroundColor: accentColor,
        appBar: AppBar(
          backgroundColor: accentColor,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: CustomScrollView(slivers: [
          SliverFillRemaining(
              hasScrollBody: false,
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Text("Studencka aPKa"),
                        Column(
                          children: [
                            Text("Wpisz swoją nazwę użytkownika",
                                style: textStyle),
                            const SizedBox(height: 10),
                            TextFormField(
                              cursorColor: Colors.white,
                              controller: userNameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Podaj nazwę użytkownika";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Nazwa użytkownika",
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text("Wpisz swój adres e-mail", style: textStyle),
                            const SizedBox(height: 10),
                            TextFormField(
                              cursorColor: Colors.white,
                              keyboardType: TextInputType.emailAddress,
                              controller: emailController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Podaj e-mail";
                                } else if (!RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(value)) {
                                  return "Podaj poprawny e-mail";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "E-mail",
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text("Wpisz hasło", style: textStyle),
                            const SizedBox(height: 10),
                            TextFormField(
                              cursorColor: Colors.white,
                              obscureText: true,
                              enableSuggestions: false,
                              autocorrect: false,
                              controller: passwordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Podaj hasło";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Hasło",
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text("Powtórz hasło", style: textStyle),
                            const SizedBox(height: 10),
                            TextFormField(
                              cursorColor: Colors.white,
                              obscureText: true,
                              enableSuggestions: false,
                              autocorrect: false,
                              controller: passwordRepeatController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Podaj hasło";
                                } else if (passwordController.text !=
                                    passwordRepeatController.text) {
                                  return "Podane hasła są różne";
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Hasło",
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    try {
                                      var response = await ApiService()
                                          .registerUser(
                                              userNameController.text,
                                              emailController.text,
                                              passwordController.text);
                                      if (response && context.mounted) {
                                        Navigator.pop(context);
                                        GlobalSnackbar.infoSnackbar(context,
                                            "Pomyślnie zarejestrowano");
                                      }
                                    } on FormatException catch (e) {
                                      GlobalSnackbar.errorSnackbar(context,
                                          "Błąd podczas rejestracji: ${e.message}");
                                    }
                                  }
                                },
                                child: const Text("Kontynuuj"),
                              ),
                            ),
                          ],
                        ),
                      ]),
                ),
              ))
        ]));
  }
}
