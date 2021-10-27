import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:projeto/helpers/firebase_helper.dart';

import 'home_widget.dart';

class AddLista extends StatefulWidget {
  @override
  _AddListaState createState() => _AddListaState();
}

class _AddListaState extends State<AddLista> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  FirebaseHelper _firebaseHelper = FirebaseHelper();
  bool isSwitched = true;

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;
    final uid = user.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Lista"),
      ),
      body: Column(
        children: [
          ListTile(
            title: TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name of lista",
              ),
            ),
          ),
          ListTile(
            title: TextField(
              maxLines: 3,
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: "Description",
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Make Lista private'),
              Switch(
                value: isSwitched,
                onChanged: (value) {
                  setState(() {
                    isSwitched = value;
                    print(isSwitched);
                  });
                },
                activeTrackColor: Colors.lightGreenAccent,
                activeColor: Colors.green,
              ),
            ],
          ),
          RaisedButton(
            onPressed: () {
              _firebaseHelper.addLista(
                  nameController.text,
                  descriptionController.text,
                  isSwitched,
                  uid);
              Navigator.of(context).push(new MaterialPageRoute(
                  builder: (BuildContext context) => new Home()));
            },
            child: Text('save'),
          ),
        ],
      ),
    );
  }
}
