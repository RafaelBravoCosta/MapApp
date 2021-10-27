class Lugar {
  int id;
  String nome;
  String descricao;
  String lat;
  String lon;

  Lugar(this.id, this.nome, this.descricao, this.lat, this.lon);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'lat': lat,
      'lon': lon
    };
    return map;
  }

  Lugar.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    nome = map['nome'];
    descricao = map['descricao'];
    lat = map['lat'];
    lon = map['lon'];
  }

  @override
  String toString() {
    return "Lugar =>(id: $id, nome: $nome, descricao: $descricao, latitude: $lat, longitude: $lon)";
  }
}
