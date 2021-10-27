import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:projeto/authentication_service.dart';
import 'package:provider/provider.dart';
import 'package:projeto/globals.dart' as globals;

class PlaceholderWidget extends StatelessWidget {
  final Color color;

  PlaceholderWidget(this.color);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(children: [
          Container(
            child: SizedBox(height: 100),
          ),
          Container(
            child: Text(
              globals.user.email.toString(),
              style: TextStyle(fontSize: 20),
            ),
          ),
          Container(
            child: SizedBox(height: 20),
          ),
          Container(
            child: ElevatedButton(
              onPressed: () {
                context.read<AuthenticationService>().signOut();
              },
              child: Text("Sign out"),
            ),
          )
        ]),
      ),
    );
  }
}
