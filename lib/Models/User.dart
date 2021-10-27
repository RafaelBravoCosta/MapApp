class User {
  int id;
  String nome;

  User(this.id, this.nome);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{'id': id, 'nome': nome};
    return map;
  }

  User.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    nome = map['nome'];
  }

  @override
  String toString() {
    return "User =>(id: $id, nome: $nome)";
  }
}
