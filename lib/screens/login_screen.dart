import 'package:flutter/material.dart';
import 'package:hasior_flutter/models/user.dart';
import 'package:hasior_flutter/screens/home_screen.dart';
import 'package:hasior_flutter/screens/register_screen.dart';
import 'package:hasior_flutter/services/api_service.dart';

import '../class/globalSnackbar.dart';
import '../theme.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  TextStyle textStyle = const TextStyle(fontSize: 16);
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  User? user;

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
                        const Text("Studencka aPKa"),
                        Column(
                          children: [
                            Text("Wpisz swój adres e-mail", style: textStyle),
                            const SizedBox(height: 10),
                            TextFormField(
                              cursorColor: Colors.white,
                              keyboardType: TextInputType.emailAddress,
                              controller: emailController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Podaj e-mail";
                                }
                                // else if (!RegExp(
                                //         r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                //     .hasMatch(value)) {
                                //   return "Podaj poprawny e-mail";
                                // }
                                return null;
                              },
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "E-mail",
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                                // errorStyle: TextStyle(
                                //     color: Color.fromARGB(255, 228, 42, 92)),
                                // errorBorder: OutlineInputBorder(
                                //   borderSide: BorderSide(
                                //       color: Color.fromARGB(255, 228, 42, 92),
                                //       width: 0.0),
                                // ),
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
                          ],
                        ),
                        Column(
                          children: [
                            const SizedBox(height: 10),
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
                                            user = await ApiService().loginUser(
                                                emailController.text,
                                                passwordController.text);
                                            if (user != null &&
                                                context.mounted) {
                                              Navigator.pop(context);
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const Home(),
                                                ),
                                              );
                                            }
                                          } on FormatException catch (e) {
                                            GlobalSnackbar.errorSnackbar(
                                                context,
                                                "Błąd podczas logowania: ${e.message}");
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
                            const SizedBox(height: 10),
                            SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: const BorderSide(
                                          color: Colors.white)),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const Register(),
                                      ),
                                    );
                                  },
                                  child: const Text("Zarejestruj się"),
                                )),
                          ],
                        ),
                      ]),
                ),
              ))
        ]));
  }
}
