import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hasior_flutter/Auth/login_page.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterState();
}

class _RegisterState extends State<RegisterView> {
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
              _nameField(),
              _emailField(),
              _passwordField(),
              _logInField(),
              _forgotPasswordButton(),
              _textLoginButton()
            ],
          ),
        )));
  }

  Container _operationName() {
    return Container(
      child: Text(
        "Register",
        style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
      ),
    );
  }

  Container _space() {
    return Container(
      child: SizedBox(
        height: 60,
      ),
    );
  }

  Container _nameField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(90.0),
          ),
          labelText: 'Name',
        ),
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

  RichText _textLoginButton() {
    return RichText(
        text: TextSpan(
      text: "Have account ? ",
      children: <TextSpan>[
        TextSpan(
          text: "Sign in !",
          style: TextStyle(color: Colors.blue[300]),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginView()));
            },
        ),
      ],
    ));
  }
}
