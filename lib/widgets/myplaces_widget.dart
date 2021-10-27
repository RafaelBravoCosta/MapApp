import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:projeto/Models/Lista.dart';
import 'package:projeto/Screens/AddLista.dart';
import 'package:projeto/Screens/AllPlaces.dart';
import 'package:projeto/authentication_service.dart';
import 'package:projeto/helpers/firebase_helper.dart';
import 'package:provider/provider.dart';

class MyPlaces extends StatefulWidget {
  @override
  _MyPlacesState createState() => _MyPlacesState();
}

class _MyPlacesState extends State<MyPlaces> {
  // final dbHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  List allData;
  // Contains the current text entered in the search bar
  String filterAllLists = '';

  var userName, listaName, userId, listaId;
  CollectionReference listas = FirebaseFirestore.instance.collection('listas');
  FirebaseHelper _firebaseHelper = new FirebaseHelper();
  int id;
  String nome;
  String docId;
  Lista _lista = Lista();

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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    // Watching FirebaseHelper Provider, so that we re-render (call setState) when notifyListeners() is called in the FirebaseHelper class
    context.watch<FirebaseHelper>();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
          appBar: AppBar(
            title: Text("My Places"),
            bottom: TabBar(
              tabs: [
                Tab(
                  child: Text(
                    "My Lists",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                Tab(
                  child: Text(
                    "All lists",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                Tab(
                  child: Text(
                    "Joined lists",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Tab(
                  child: Text(
                    "Requests",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                //Tab(text: "Favs"),
                // Tab(text: "BD Demo"),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Scaffold(
                floatingActionButton: FloatingActionButton(
                    child: Icon(Icons.add),
                    // Within the `FirstRoute` widget
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddLista()),
                      );
                    }),
                body: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('lista')
                      .where(
                        'adminUid',
                        isEqualTo: context
                            .read<AuthenticationService>()
                            .currentUserUid,
                      )
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
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
                            onTap: () {
                              Navigator.of(context).push(
                                new MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      new AllPlaces(
                                    docId: document.id,
                                  ),
                                ),
                              );
                            },
                            title: Text(document['nameOfLista']),
                            subtitle: Text(document['description']),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              Scaffold(
                body: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('lista')
                      .where('adminUid',
                          isNotEqualTo: context
                              .read<AuthenticationService>()
                              .currentUserUid)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return ListView(
                      children: snapshot.data.docs.map((document) {
                        // Has the user already joined the list
                        bool isAlreadyJoined = false;
                        // List of widgets to return in the end of this function
                        // Adding widgets in the renderData list based on conditions
                        final renderData = <Widget>[];

                        // If the current list being rendered is the first list,
                        // Add a search bar at the top of this list
                        if (document.id == snapshot.data.docs.first.id) {
                          renderData.add(
                            Container(
                              width: 0.95 * width,
                              height: 0.07 * height,
                              margin: EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color.fromRGBO(142, 142, 147, .15),
                              ),
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Theme(
                                    child: TextField(
                                      onChanged: (text) {
                                        setState(() {
                                          filterAllLists = text;
                                        });
                                      },
                                      style: TextStyle(color: Colors.black),
                                      decoration: InputDecoration(
                                        icon: Icon(Icons.search),
                                        border: InputBorder.none,
                                        hintText: '',
                                        hintStyle: TextStyle(
                                          color:
                                              Color.fromRGBO(142, 142, 147, 1),
                                        ),
                                      ),
                                    ),
                                    data: Theme.of(context).copyWith(
                                      primaryColor: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        final allJoinedLists =
                            context.read<FirebaseHelper>().allApprovedList;
                        for (var list in allJoinedLists) {
                          if (list['listaId'] == document.id) {
                            // if the user has already joined this list, we don't want to show it, so we render an Empty SizedBox
                            // And set isAlreadyJoined to true
                            renderData.add(
                              SizedBox(),
                            );
                            isAlreadyJoined = true;
                            break;
                          }
                        }

                        // This listTile Data stored in this variable, because it was referenced many times
                        final listData = Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.black),
                            ),
                          ),
                          child: ListTile(
                            onTap: () {
                              if (document['private'] == false) {
                                Navigator.of(context).push(
                                  new MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        new AllPlaces(
                                      docId: document.id,
                                    ),
                                  ),
                                );
                              }
                              return null;
                            },
                            title: Text(
                              document['nameOfLista'],
                            ),
                            subtitle: Text(document['description']),
                            trailing: document['private']
                                ? GestureDetector(
                                    onTap: () {
                                      final allWaitingList = context
                                          .read<FirebaseHelper>()
                                          .allWaitingList;

                                      for (var list in allWaitingList) {
                                        if (list['listaId'] == document.id) {
                                          // User has already sent a join request
                                          showAlertDialog(
                                            context: context,
                                            title:
                                                'You have already sent a request',
                                            message:
                                                'You have already sent a request to join this list',
                                          );
                                          return;
                                        }
                                      }
                                      print('Send Req!');
                                      _firebaseHelper.addUserToLista(
                                        context
                                            .read<AuthenticationService>()
                                            .currentUserUid,
                                        document['adminUid'],
                                        document.id,
                                        document['description'],
                                        document['nameOfLista'],
                                        "waiting",
                                      );

                                      Map<String, dynamic> newData = {
                                        "status": "waiting",
                                        "UserUid": context
                                            .read<AuthenticationService>()
                                            .currentUserUid,
                                        "AdminUid": document['adminUid'],
                                        "nameOfLista": document['nameOfLista'],
                                        "description": document['description'],
                                        "listaId": document.id,
                                      };

                                      context
                                          .read<FirebaseHelper>()
                                          .allWaitingList
                                          .add(newData);
                                      context
                                          .read<FirebaseHelper>()
                                          .allList
                                          .add(newData);
                                      context
                                          .read<FirebaseHelper>()
                                          .notifyAllListeners();
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.25,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.1,
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            offset: Offset(5, 5),
                                            blurRadius: 10,
                                          )
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Ask to Join',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      _firebaseHelper.addUserToLista(
                                        context
                                            .read<AuthenticationService>()
                                            .currentUserUid,
                                        document['adminUid'],
                                        document.id,
                                        document['description'],
                                        document['nameOfLista'],
                                        "approve",
                                      );
                                      Map<String, dynamic> newData = {
                                        "status": "approve",
                                        "UserUid": context
                                            .read<AuthenticationService>()
                                            .currentUserUid,
                                        "AdminUid": document['adminUid'],
                                        "nameOfLista": document['nameOfLista'],
                                        "description": document['description'],
                                        "listaId": document.id,
                                      };
                                      context
                                          .read<FirebaseHelper>()
                                          .allApprovedList
                                          .add(newData);
                                      context
                                          .read<FirebaseHelper>()
                                          .allList
                                          .add(newData);
                                      context
                                          .read<FirebaseHelper>()
                                          .notifyAllListeners();
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.25,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.1,
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            offset: Offset(5, 5),
                                            blurRadius: 10,
                                          )
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Join',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        );
                        // First check if the user has not joined for this list
                        // if the user has joined, don't show this list
                        if (!isAlreadyJoined) {
                          // Check for the filter on the search bar
                          if (filterAllLists.isNotEmpty) {
                            if ((document['nameOfLista'] as String)
                                .toLowerCase()
                                .contains(filterAllLists.toLowerCase())) {
                              // if there is a filter and the name of this list contains whatever the user entered in the search bar
                              // Then render this list
                              renderData.add(listData);
                            }
                          } else {
                            // If no filter (Nothing entered in the search bar) then just render this list as normal
                            renderData.add(listData);
                          }
                        }
                        // Return the renderData in this coulumn
                        return Column(
                          children: renderData,
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              Scaffold(
                body: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('userAccess')
                      .where('UserUid',
                          isEqualTo: context
                              .read<AuthenticationService>()
                              .currentUserUid)
                      .where('status', isEqualTo: 'approve')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return Column(
                      children: snapshot.data.docs.map((document) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.black),
                            ),
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.of(context).push(new MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      new AllPlaces(
                                        docId: document['listaId'],
                                      )));
                            },
                            title: Text(document['nameOfLista']),
                            subtitle: Text(document['description']),
                            trailing: Icon(Icons.arrow_forward_ios),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              Scaffold(
                body: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('userAccess')
                      .where('AdminUid',
                          isEqualTo: context
                              .read<AuthenticationService>()
                              .currentUserUid)
                      .where('status', isEqualTo: 'waiting')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return Column(
                      children: snapshot.data.docs.map((document) {
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.black),
                            ),
                          ),
                          child: ListTile(
                            onTap: () {
                              Navigator.of(context).push(new MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      new AllPlaces(
                                        docId: document['listaId'],
                                      )));
                            },
                            title: Text(
                              document['nameOfLista'],
                              style: TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(document['description'],
                                style: TextStyle(fontSize: 13)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _firebaseHelper.updateReqStatus(
                                        document.id, 'approve');
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.20,
                                    height: MediaQuery.of(context).size.width *
                                        0.085,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          offset: Offset(5, 5),
                                          blurRadius: 10,
                                        )
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Approve',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.02,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _firebaseHelper.updateReqStatus(
                                        document.id, 'decline');
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.20,
                                    height: MediaQuery.of(context).size.width *
                                        0.085,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          offset: Offset(5, 5),
                                          blurRadius: 10,
                                        )
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Decline',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              // Column(
              //   children: [
              //     Form(
              //       key: _formKey,
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: <Widget>[
              //           TextFormField(
              //             decoration: const InputDecoration(
              //               hintText: 'Enter user',
              //             ),
              //             validator: (value) {
              //               if (value.isEmpty) {
              //                 return 'Please enter some text';
              //               } else {
              //                 userName = value;
              //               }
              //               return null;
              //             },
              //           ),
              //           RaisedButton(
              //             child: Text(
              //               'Insert User',
              //               style: TextStyle(fontSize: 20),
              //             ),
              //             onPressed: () {
              //               print(userName);
              //               _insertUser(userName);
              //               //_queryUser();
              //             },
              //           ),
              //           TextFormField(
              //             decoration: const InputDecoration(
              //               hintText: 'Enter lista',
              //             ),
              //             validator: (value) {
              //               if (value.isEmpty) {
              //                 return 'Please enter some text';
              //               } else
              //                 listaName = value;
              //               return null;
              //             },
              //           ),
              //           RaisedButton(
              //             child: Text(
              //               'Insert User',
              //               style: TextStyle(fontSize: 20),
              //             ),
              //             onPressed: () {
              //               _insertLista(listaName, DateTime.now(), 'zucagay');
              //               //_queryUser();
              //             },
              //           ),
              //           TextFormField(
              //             decoration: const InputDecoration(
              //               hintText: 'Enter id',
              //             ),
              //             validator: (value) {
              //               if (value.isEmpty) {
              //                 return 'Please enter some text';
              //               } else
              //                 userId = int.parse(value);
              //               return null;
              //             },
              //           ),
              //           TextFormField(
              //             decoration: const InputDecoration(
              //               hintText: 'Enter list id',
              //             ),
              //             validator: (value) {
              //               if (value.isEmpty) {
              //                 return 'Please enter some text';
              //               } else
              //                 listaId = int.parse(value);
              //               return null;
              //             },
              //           ),
              //           Padding(
              //             padding: const EdgeInsets.symmetric(vertical: 16.0),
              //             child: ElevatedButton(
              //               onPressed: () {
              //                 _insertlistaUser(userId, listaId);
              //               },
              //               child: Text('Submit'),
              //             ),
              //           ),
              //           RaisedButton(
              //             child: Text(
              //               'queryUsers',
              //               style: TextStyle(fontSize: 20),
              //             ),
              //             onPressed: () {
              //               _query();
              //               //_queryUser();
              //             },
              //           ),
              //           RaisedButton(
              //             child: Text(
              //               'clearUsers',
              //               style: TextStyle(fontSize: 20),
              //             ),
              //             onPressed: () {
              //               _deleteAllListaUsers();
              //             },
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
            ],
          )),
    );
  }

// void _insertlistaUser(int userId, int listaId) async {
//   print("teste1");
//   ListaUser lu =
//       new ListaUser(await dbHelper.getCountListaUser(), userId, listaId);
//   dbHelper.insertListaUser(lu);
//   print('inserted lista: ' + lu.toString());
// }
//
// // MyChanges
// void _insertLista(String name, date, descricao) async {
//   var mili = date.millisecondsSinceEpoch;
//   // Lista u =
//   //     new Lista((await dbHelper.getCountLista()), name, mili, descricao);
//   // dbHelper.insertLista(u);
//   // print('inserted lista: ' + u.toString());
// }
//
// void _insertUser(String name) async {
//   User u = new User((await dbHelper.getCountUser()), name);
//   dbHelper.insertUser(u);
//   print('inserted user: ' + u.toString());
// }
//
// void _query() async {
//   final allLists = await dbHelper.queryAllLists();
//   print('Query all users:');
//   allLists
//       .forEach((lista) => DateTime.fromMillisecondsSinceEpoch(lista.date));
//   allLists.forEach((i) => print(i));
// }
//
// // void _queryUser() async {
// //   final allUsers = await dbHelper.getListUser(1);
// //   print('Query user 1:' + allUsers.toString());
// // }
//
// void _deleteAllListaUsers() async {
//   print("Deleted all listaUsers.");
//   dbHelper.deleteAllListaUser();
// }

// void _deleteAllUsers() async {
//   print("Delete all users.");
//   dbHelper.deleteAllUsers();
// }
// Future<void> addLista() {
//   // Call the user's CollectionReference to add a new user
//   return listas
//       .add({'id': 0, 'nome': 'teste1'})
//       .then((value) => print("Lista Adicionada"))
//       .catchError((error) => print("Failed to add lista: $error"));
// }
}
