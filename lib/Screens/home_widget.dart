import 'package:flutter/material.dart';
import 'package:projeto/authentication_service.dart';
import 'package:projeto/helpers/firebase_helper.dart';
import 'package:provider/provider.dart';

import '../widgets/map_widget.dart';
import '../widgets/myplaces_widget.dart';
import '../widgets/placeholder_widget.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  bool isLoading = true;

  final List<Widget> _children = [
    Map(),
    //PlaceholderWidget(Colors.blue),
    //FlappySearchBar(),
    MyPlaces(),
    PlaceholderWidget(Colors.green),
  ];

  @override
  void initState() {
    super.initState();
    context.read<FirebaseHelper>()
      ..changeBottomNavBarIndex = onTabTapped
      ..getCurrentUserData(
        context.read<AuthenticationService>().currentUserUid,
      ).then((value) {
        setState(() {
          isLoading = false;
        });
      });
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    return Scaffold(
      body: IndexedStack(
        children: _children,
        index: _currentIndex,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.list),
            label: 'My Places',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          )
        ],
      ),
    );
  }
}
