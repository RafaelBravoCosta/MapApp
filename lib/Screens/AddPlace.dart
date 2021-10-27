import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projeto/helpers/firebase_helper.dart';
import 'package:provider/provider.dart';

import '../authentication_service.dart';
import 'home_widget.dart';

class AddPlace extends StatefulWidget {
  String latitude;
  String longitude;

  AddPlace({Key key, @required this.latitude, this.longitude});

  @override
  _AddPlaceState createState() => _AddPlaceState();
}

class _AddPlaceState extends State<AddPlace> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  FirebaseHelper _firebaseHelper = FirebaseHelper();
  String carMakeModel;

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User user = auth.currentUser;

    final uid = user.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text("Add My Places"),
      ),
      body: Column(
        children: [
          ListTile(
            title: TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name of Place",
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
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('lista')
                .where('adminUid',
                    isEqualTo:
                        context.read<AuthenticationService>().currentUserUid)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              return Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Choose lista in which you want to add the place')
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropdownButton(
                        isExpanded: false,
                        value: carMakeModel,
                        items: snapshot.data.docs.map((value) {
                          return DropdownMenuItem(
                            value: value.get('nameOfLista'),
                            child: Text('${value.get('nameOfLista')}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(
                            () {
                              debugPrint('make selected: $value');
                              carMakeModel = value;
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          RaisedButton(
            onPressed: () {
              _firebaseHelper.addPlace(
                  nameController.text,
                  widget.latitude,
                  widget.longitude,
                  carMakeModel,
                  context.read<AuthenticationService>().currentUserUid);
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
