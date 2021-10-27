import 'package:flutter/material.dart';

class ListaUser {
  int id, userId, listaId;

  ListaUser(this.id, this.userId, this.listaId);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{'id': id, 'userId': userId, 'listaId': listaId};
    return map;
  }

  ListaUser.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    userId = map['userId'];
    listaId = map['listaId'];
  }

  @override
  String toString() {
    return "ListaUser =>(id: $id, userId: $userId, listaId: $listaId)";
  }
}
