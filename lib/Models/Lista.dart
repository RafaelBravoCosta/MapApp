class Lista {
  String nameOfLista;
  String adminUid;
  String description;
  bool private;

  Lista({this.nameOfLista, this.adminUid, this.description, this.private});

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{
      'nameOfLista': nameOfLista,
      'adminUid': adminUid,
      'description': description,
      'private': private
    };
    return map;
  }

  Lista.fromJson(Map<String, dynamic> map) {
    nameOfLista = map['nameOfLista'];
    adminUid = map['adminUid'];
    description = map['description'];
    private = map['private'];
  }

  @override
  String toString() {
    return "lista =>(name: $nameOfLista, adminUid: $adminUid, desc: $description, private: $private)";
  }
}
