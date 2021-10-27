import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

typedef void FocusMap(double latitude, double longitude);
typedef void ChangeIndex(int index);

class FirebaseHelper with ChangeNotifier {
  List allList = [];
  List allApprovedList = [];
  List allWaitingList = [];

  FocusMap focusMap;
  ChangeIndex changeBottomNavBarIndex;

  // Used to show toast messages for success/errors warnings
  static void showToast(String msg) async {
    await Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<String> addUser(email, uid) async {
    try {
      Map<String, dynamic> demoData = {"email": email, "uid": uid};
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection('user');
      collectionReference.add(demoData);
      return "user Added";
    } catch (e) {
      return e.message;
    }
  }

  // Used to get the currently logged in users data from Firestore
  Future<void> getCurrentUserData(String currUserID) async {
    final currUsersJoinedLists = await FirebaseFirestore.instance
        .collection('userAccess')
        // I am using a .where() query to find the data of the current users userAccess documents using the user ID
        .where('UserUid', isEqualTo: currUserID)
        .get();

    // I am iterating over all the documents of the current user saved in the userAccess collection and
    // Splitting them into 2 different lists allApprovedList list & allWaitingList list
    // allApprovedList contains the documents data for which the user has been approved and joined that list
    // allWaitingList contains the documents data for which the user is currently waiting to be approved

    // I use the data from these lists later to decide if the current user has already joined a list
    // Or if the current user is waiting to join the list so don't send the request to join the list again
    currUsersJoinedLists.docs.forEach((list) {
      print(list.data());
      allList.add(list.data());
      if (list.data()['status'] == 'approve') {
        allApprovedList.add(list.data());
      }
      if (list.data()['status'] == 'waiting') {
        allWaitingList.add(list.data());
      }
    });
  }

  Future<String> addLista(name, description, isSwitched, uid) async {
    try {
      Map<String, dynamic> demoData = {
        "nameOfLista": name,
        "description": description,
        "adminUid": uid,
        "private": isSwitched,
      };
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection('lista');
      collectionReference.add(demoData);
      return "Lista Added";
    } catch (e) {
      return e.message;
    }
  }

  Future<String> addPlace(
      name, latitude, longitude, selectedLista, userUID) async {
    String docId;
    try {
      Map<String, dynamic> demoData = {
        "name of Place": name,
        "latitude": latitude,
        "longitude": longitude,
      };

      final getIdOfLista = FirebaseFirestore.instance
          .collection('lista')
          .where('nameOfLista', isEqualTo: selectedLista)
          .where('adminUid', isEqualTo: userUID)
          .get()
          .then((snapshot) async {
        docId = snapshot.docs.first.id;

        final collectionReference = FirebaseFirestore.instance
            .collection('lista')
            .doc(docId)
            .collection('places');
        collectionReference.add(demoData);
      });

      return "Place Added";
    } catch (e) {
      return e.message;
    }
  }

  // This method is used to call setState (Re-Render) all the Stateful Widgets which are listening to this Providers Data
  // Using context.watch<FirebaseHelper>()
  void notifyAllListeners() {
    notifyListeners();
  }

  Future<String> addUserToLista(
      uid, AdminUid, listaId, description, nameOfLista, status) async {
    try {
      Map<String, dynamic> demoData = {
        "status": status,
        "UserUid": uid,
        "AdminUid": AdminUid,
        "nameOfLista": nameOfLista,
        "description": description,
        "listaId": listaId,
      };
      CollectionReference collectionReference =
          await FirebaseFirestore.instance.collection('userAccess');
      collectionReference.add(demoData);
      return "Added";
    } catch (e) {
      return e.message;
    }
  }

  Future<String> updateReqStatus(docId, status) async {
    try {
      Map<String, dynamic> demoData = {
        "status": status,
      };
      DocumentReference collectionReference =
          await FirebaseFirestore.instance.collection('userAccess').doc(docId);
      collectionReference.update(demoData);
      return "updated";
    } catch (e) {
      return e.message;
    }
  }
}
