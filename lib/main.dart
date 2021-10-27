import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:projeto/Screens/sign_in_page.dart';
import 'package:projeto/authentication_service.dart';
import 'package:projeto/screens/home_widget.dart';
import 'package:provider/provider.dart';
import 'package:projeto/globals.dart' as globals;
import 'helpers/firebase_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}

// class App extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'MapApp',
//       home: Home(),
//     );
//   }
// }

//WORKING FIREBASE SETUP
class App extends StatelessWidget {
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthenticationService>(
            create: (_) => AuthenticationService(FirebaseAuth.instance),
          ),
          ChangeNotifierProvider<FirebaseHelper>(
            create: (_) => FirebaseHelper(),
          ),
          StreamProvider(
            create: (context) =>
                context.read<AuthenticationService>().authStateChanges,
            initialData: null,
          )
        ],
        child: MaterialApp(
            title: 'MapApp',
            debugShowCheckedModeBanner: false,
            home: FutureBuilder(
                future: _fbApp,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    print('You have an error! ${snapshot.error.toString()}');
                    return Text('Something went wrong!');
                  } else if (snapshot.hasData) {
                    return MaterialApp(
                      title: 'MapApp',
                      home: AuthenticationWrapper(),
                      debugShowCheckedModeBanner: false,
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  /*return MaterialApp(
                    title: 'MapApp',
                    home: AuthenticationWrapper(),
                  );*/
                })));
  }
}

class AuthenticationWrapper extends StatelessWidget {
  /*@override
  Widget build(BuildContext context) {
    return Container();*/
  const AuthenticationWrapper({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();
    // Watching the AuthenticationService class so that we can know when we call notifyListeners and re-render this build function
    final authSerivce = context.watch<AuthenticationService>();

    if (firebaseUser != null) {
      globals.user = firebaseUser;
      authSerivce.currentUserUid = firebaseUser.uid;
      return Home();
    }

    return SignInPage();
  }
}
