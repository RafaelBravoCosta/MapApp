import 'package:flutter/material.dart';
import 'package:projeto/Screens/sign_in_page.dart';
import 'package:projeto/authentication_service.dart';
import 'package:provider/src/provider.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void validate() {
    if (_formKey.currentState.validate()) {
      context.read<AuthenticationService>().signUp(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: emailController,
                  // Keyboard will show the '@' sign, easier to enter email
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    hintText: 'Enter your email here',
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter an E-mail!';
                    }
                  },
                ),
                SizedBox(height: 12.0),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    hintText: 'Enter your password here',
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter a password!!';
                    }
                    if (RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value)) {
                      return 'Please enter a valid email address!';
                    }
                  },
                ),
                SizedBox(height: 12.0),
                MaterialButton(
                  color: Colors.grey[400],
                  padding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 34.0),
                  onPressed: () {
                    validate();
                  },
                  child: Text("Sign up"),
                ),
                SizedBox(height: 12.0),
                MaterialButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignInPage()),
                    );
                  },
                  child: Text('Already have an account? Login here'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
