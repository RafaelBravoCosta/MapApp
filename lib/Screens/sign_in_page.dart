import 'package:flutter/material.dart';
import 'package:projeto/Screens/forgot_password.dart';
import 'package:projeto/Screens/sign_up_page.dart';
import 'package:projeto/authentication_service.dart';
import 'package:provider/provider.dart';
import 'package:projeto/globals.dart' as globals;

class SignInPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              // Keyboard will show the '@' sign, easier to enter email
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
              ),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Password",
              ),
              obscureText: true,
            ),
            SizedBox(height: 12.0),
            MaterialButton(
              color: Colors.grey[400],
              padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 34.0),
              onPressed: () {
                context.read<AuthenticationService>().signIn(
                      email: emailController.text.trim(),
                      password: passwordController.text.trim(),
                    );
              },
              child: Text("Sign in"),
            ),
            InkWell(
              child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.height / 18,
                  margin: EdgeInsets.only(top: 25),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black),
                  child: Center(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        height: 30.0,
                        width: 30.0,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/google_logo.png'),
                              fit: BoxFit.cover),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Text(
                        'Sign in with Google',
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ],
                  ))),
              onTap: () async {
                globals.user = await context
                    .read<AuthenticationService>()
                    .signInWithGoogle();
              },
            ),
            // New button for reset password
            SizedBox(height: 15.0),
            MaterialButton(
              onPressed: () {
                // Push to reset password screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                );
              },
              child: Text('Forgot your password? Reset it'),
            ),
            SizedBox(height: 3.0),
            MaterialButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignUpPage()),
                );
              },
              // Also fixed this spelling mistake, it previously was Dont't
              // Changed it to Don't
              child: Text('Don\'t have an account? Signup'),
            ),
          ],
        ),
      ),
    );
  }
}
