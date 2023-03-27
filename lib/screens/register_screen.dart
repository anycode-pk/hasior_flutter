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
  bool _isLoading = false;
  TextStyle textStyle = const TextStyle(fontSize: 16);
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordRepeatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                        FractionallySizedBox(
                          widthFactor: 0.3,
                          child: Image.asset("assets/logo.png"),
                        ),
                        Column(
                          children: [
                            const SizedBox(height: 10),
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
                            const SizedBox(height: 15),
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
                            const SizedBox(height: 15),
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
                            const SizedBox(height: 15),
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
                            const SizedBox(height: 15),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black),
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
                                            var response = await ApiService()
                                                .registerUser(
                                                    userNameController.text,
                                                    emailController.text,
                                                    passwordController.text);
                                            if (response && context.mounted) {
                                              Navigator.pop(context);
                                              GlobalSnackbar.infoSnackbar(
                                                  context,
                                                  "Pomyślnie zarejestrowano");
                                            }
                                          } on FormatException catch (e) {
                                            GlobalSnackbar.errorSnackbar(
                                                context,
                                                "Błąd podczas rejestracji: ${e.message}");
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          }
                                        }
                                      },
                                label: _isLoading
                                    ? const Text("")
                                    : const Text("Kontynuuj"),
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
