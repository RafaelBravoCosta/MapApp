import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projeto/helpers/firebase_helper.dart';
import 'package:provider/provider.dart';

class AllPlaces extends StatefulWidget {
  String docId;
  AllPlaces({this.docId});
  @override
  _AllPlacesState createState() => _AllPlacesState();
}

class _AllPlacesState extends State<AllPlaces> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Places'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('lista')
            .doc(widget.docId)
            .collection('places')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            children: snapshot.data.docs.map((document) {
              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black),
                  ),
                ),
                child: ListTile(
                  title: Text(document['name of Place']),
                  onTap: () {
                    Navigator.of(context).pop();
                    context.read<FirebaseHelper>()
                      ..changeBottomNavBarIndex(0)
                      ..focusMap(
                        double.parse(document['latitude']),
                        double.parse(document['longitude']),
                      );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
