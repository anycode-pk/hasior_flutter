import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hasior_flutter/Auth/register_page.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginState();
}

class _LoginState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
            body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _operationName(),
              _space(),
              _emailField(),
              _passwordField(),
              _logInField(),
              _forgotPasswordButton(),
              _textRegisterButton()
            ],
          ),
        )));
  }

  Container _operationName() {
    return Container(
      child: const Text(
        "Login",
        style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
      ),
    );
  }

  Container _space() {
    return Container(
      child: const SizedBox(
        height: 60,
      ),
    );
  }

  Container _emailField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(90.0),
          ),
          labelText: 'Email',
        ),
      ),
    );
  }

  Container _passwordField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: TextField(
        obscureText: true,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(90.0),
          ),
          labelText: 'Password',
        ),
      ),
    );
  }

  Container _logInField() {
    return Container(
        height: 80,
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text('Log In'),
          onPressed: () {},
        ));
  }

  TextButton _forgotPasswordButton() {
    return TextButton(
      onPressed: () {},
      child: Text(
        'Forgot Password?',
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  RichText _textRegisterButton() {
    return RichText(
        text: TextSpan(
      text: "Do not have Account ? ",
      children: <TextSpan>[
        TextSpan(
          text: "Sign up !",
          style: TextStyle(color: Colors.blue[300]),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => RegisterView()));
            },
        ),
      ],
    ));
  }
}
