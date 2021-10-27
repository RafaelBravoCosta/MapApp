import 'package:flutter/material.dart';
import 'package:projeto/authentication_service.dart';
import 'package:provider/src/provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  ForgotPasswordPage({Key key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void validate() {
    if (_formKey.currentState.validate()) {
      // Call the reset function
      context
          .read<AuthenticationService>()
          .resetPassword(
            emailController.text.trim(),
          )
          .then((res) {
        // res is the response from the resetPassword function
        // if res is 'ok' this means that the reset succeeded
        // otherwise there is an error

        // showAlerDialog function used to show an alert dialog to the user
        if (res != 'ok') {
          showAlertDialog(context: context, title: 'Error', message: res);
        } else {
          showAlertDialog(
            context: context,
            title: 'Success',
            message: 'Check your email for the password reset link',
          );
        }
      });
    }
  }

  void showAlertDialog({
    @required BuildContext context,
    @required String title,
    @required String message,
  }) {
    // set up the button
    Widget okButton = TextButton(
      child: Text('OK'),
      onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  // this is a fraction of the height of the screen so that it adapts to different screen heights,
                  // 0.15 means 15% of the screen height
                  height: 0.15 * height,
                ),
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
                MaterialButton(
                  color: Colors.grey[400],
                  padding:
                      EdgeInsets.symmetric(vertical: 12.0, horizontal: 34.0),
                  onPressed: () {
                    validate();
                  },
                  child: Text("Send Reset Email"),
                ),
                SizedBox(height: 12.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
