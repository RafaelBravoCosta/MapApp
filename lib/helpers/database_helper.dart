// import 'dart:async';
// import 'dart:io';
// import 'package:projeto/Models/Lista.dart';
// import 'package:projeto/Models/User.dart';
// import 'package:projeto/Models/Lugar.dart';
// import 'package:projeto/Models/ListaUser.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';
//
// class DatabaseHelper {
//   static DatabaseHelper _databaseHelper; //SINGLETON DBHELPER
//   static Database _database;
//
//   //Atributos User
//   String userTable = 'user';
//   String userId = 'id';
//   String userNome = 'nome';
//   String userDate = 'date';
//
//   //Atributos Lista
//   String listaTable = 'lista';
//   String listaId = 'id';
//   String listaNome = 'nome';
//   String listaDate = 'date';
//   String listaDescricao = 'descricao';
//
//   //Atributos Lugar
//   String lugarTable = 'lugar';
//   String lugarId = 'id';
//   String lugarNome = 'nome';
//   String lugarDescricao = 'descricao';
//   String lugarLat = 'lat';
//   String lugarLon = 'lon';
//
//   //atributos ListaUser
//   String listaUserTable = 'listaUser';
//   String listaUserId = 'id';
//   String listaUser_UserId = 'userId';
//   String listaUser_ListaId = 'listaId';
//
//   DatabaseHelper._createInstance(); //NAMED CONST TO CREATE INSTANCE OF THE DBHELPER
//
//   factory DatabaseHelper() {
//     if (_databaseHelper == null) {
//       _databaseHelper = DatabaseHelper._createInstance(); //EXEC ONLY ONCE
//     }
//     return _databaseHelper;
//   }
//
//   Future<Database> get database async {
//     if (_database == null) {
//       _database = await initializeDatabase();
//     }
//     return _database;
//   }
//
//   // this opens the database (and creates it if it doesn't exist)
//   Future<Database> initializeDatabase() async {
//     //GET THE PATH TO THE DIRECTORY FOR IOS AND ANDROID TO STORE DB
//     Directory directory = await getApplicationDocumentsDirectory();
//     String path = directory.path + 'mapapp.db';
//     //OPEN/CREATE THE DB AT A GIVEN PATH
//     var mapappDatabase = await openDatabase(path,
//         version: 1, onCreate: _createDb, onConfigure: _onConfigure);
//
//     return mapappDatabase;
//   }
//
//   Future _onConfigure(Database db) async {
//     await db.execute('PRAGMA foreign_keys = ON');
//   }
//
//   // SQL code to create the database table
//   void _createDb(Database db, int newVersion) async {
//     await db.execute(
//         'CREATE TABLE $userTable($userId INTEGER PRIMARY KEY AUTOINCREMENT, $userNome TEXT, $userDate DATE)');
//     await db.execute(
//         'CREATE TABLE $listaTable($listaId INTEGER PRIMARY KEY AUTOINCREMENT, $listaNome TEXT, $listaDate DATE, $listaDescricao TEXT)');
//     await db.execute(
//         'CREATE TABLE $lugarTable($lugarId INTEGER PRIMARY KEY AUTOINCREMENT, $lugarNome TEXT, $lugarDescricao TEXT, $lugarLat INTEGER, $lugarLon INTEGER)');
//     //await db.execute(
//     //'CREATE TABLE $listaUserTable($listaUser_UserId INTEGER FOREIGN KEY REFERENCES $userId, $listaUser_ListaId INTEGER FOREIGN KEY)');
//     await db.execute("""
//             CREATE TABLE $listaUserTable (
//               $listaUserId INTEGER PRIMARY KEY,
//               $listaUser_UserId INTEGER NOT NULL,
//               $listaUser_ListaId INTEGER NOT NULL,
//               FOREIGN KEY ($listaUser_ListaId) REFERENCES $listaTable ($listaId)
//                 ON DELETE NO ACTION ON UPDATE NO ACTION,
//               FOREIGN KEY ($listaUser_UserId) REFERENCES $userTable ($userId)
//                 ON DELETE NO ACTION ON UPDATE NO ACTION
//             )""");
//     // await db.execute("""
//     //         CREATE TABLE $listaUserTable (
//     //           $listaUserId INTEGER PRIMARY KEY,
//     //           $listaUser_UserId INTEGER NOT NULL REFERENCES $listaTable ($listaId),
//     //           $listaUser_ListaId INTEGER NOT NULL REFERENCES $userTable ($userId),
//     //         )""");
//   }
//
//   Future<int> insertUser(User user) async {
//     Database db = await this.database;
//     var resultado = await db.insert(userTable, user.toMap());
//
//     return resultado;
//   }
//
//   Future<int> insertLista(Lista lista) async {
//     Database db = await this.database;
//     var resultado = await db.insert(listaTable, lista.toMap());
//
//     return resultado;
//   }
//
//   Future<int> insertLugar(Lugar lugar) async {
//     Database db = await this.database;
//     var resultado = await db.insert(lugarTable, lugar.toMap());
//
//     return resultado;
//   }
//
//   Future<User> getUser(int id) async {
//     Database db = await this.database;
//     List<Map> maps = await db.query(userTable,
//         columns: [userId, userNome], where: "$userId = ?", whereArgs: [id]);
//
//     if (maps.length > 0) {
//       return User.fromMap(maps.first);
//     } else {
//       return null;
//     }
//   }
//
//   Future<Lista> getLista(int id) async {
//     Database db = await this.database;
//     List<Map> maps = await db.query(listaTable,
//         columns: [listaId, listaNome], where: "$listaId = ?", whereArgs: [id]);
//
//     if (maps.length > 0) {
//       return Lista.fromMap(maps.first);
//     } else {
//       return null;
//     }
//   }
//
//   Future<Lugar> getLugar(int id) async {
//     Database db = await this.database;
//     List<Map> maps = await db.query(lugarTable,
//         columns: [lugarId, lugarNome], where: "$lugarId = ?", whereArgs: [id]);
//
//     if (maps.length > 0) {
//       return Lugar.fromMap(maps.first);
//     } else {
//       return null;
//     }
//   }
//
//   Future<Lista> getListaByName(String string) async {
//     Database db = await this.database;
//     List<Map> maps = await db.rawQuery(
//         'SELECT $listaNome FROM $listaTable WHERE $listaNome LIKE $string');
//     if (maps.length > 0) {
//       List<Lista> listas;
//       maps.forEach((lista) {
//         listas.add(Lista.fromMap(lista));
//       });
//     } else
//       return null;
//   }
//
//   Future<List<Lista>> queryAllLists() async {
//     Database db = await this.database;
//     List<Map> maps = await db.query(listaTable);
//     List<Lista> listas = [];
//     if (maps.length > 0) {
//       maps.forEach((lista) => listas.add(Lista.fromMap(lista)));
//     } else
//       return null;
//
//     return listas;
//   }
//
//   Future<List<Map<String, dynamic>>> queryAllUsers() async {
//     Database db = await this.database;
//     return await db.query(userTable);
//   }
//
//   Future<List<Map<String, dynamic>>> queryAllLugars() async {
//     Database db = await this.database;
//     return await db.query(lugarTable);
//   }
//
//   Future<int> updateUser(User user) async {
//     var db = await this.database;
//
//     var resultado = await db.update(userTable, user.toMap(),
//         where: '$userId = ?', whereArgs: [user.id]);
//
//     return resultado;
//   }
//
//   Future<int> updateList(Lista lista) async {
//     var db = await this.database;
//
//     var resultado = await db.update(userTable, lista.toMap(),
//         where: '$listaId = ?', whereArgs: [lista.id]);
//
//     return resultado;
//   }
//
//   Future<int> updateLugar(Lugar lugar) async {
//     var db = await this.database;
//
//     var resultado = await db.update(lugarTable, lugar.toMap(),
//         where: '$lugarId = ?', whereArgs: [lugar.id]);
//
//     return resultado;
//   }
//
//   Future<int> deleteUser(int id) async {
//     var db = await this.database;
//
//     int resultado =
//         await db.delete(userTable, where: "$userId = ?", whereArgs: [id]);
//     return resultado;
//   }
//
//   Future<int> deleteAllUsers() async {
//     var db = await this.database;
//
//     return await db.delete(userTable);
//   }
//
//   Future<int> deleteAllListaUser() async {
//     var db = await this.database;
//
//     return await db.delete(listaUserTable);
//   }
//
//   Future<int> deleteLista(int id) async {
//     var db = await this.database;
//
//     int resultado =
//         await db.delete(listaTable, where: "$listaId = ?", whereArgs: [id]);
//     return resultado;
//   }
//
//   Future<int> deleteLugar(int id) async {
//     var db = await this.database;
//
//     int resultado =
//         await db.delete(lugarTable, where: "$lugarId = ?", whereArgs: [id]);
//     return resultado;
//   }
//
//   Future<int> getCountUser() async {
//     Database db = await this.database;
//     List<Map<String, dynamic>> x =
//         await db.rawQuery('SELECT COUNT (*) from $userTable');
//
//     int resultado = Sqflite.firstIntValue(x);
//     return resultado;
//   }
//
//   Future<int> getCountLista() async {
//     Database db = await this.database;
//     List<Map<String, dynamic>> x =
//         await db.rawQuery('SELECT COUNT (*) from $listaTable');
//
//     int resultado = Sqflite.firstIntValue(x);
//     return resultado;
//   }
//
//   Future<int> getCountListaUser() async {
//     Database db = await this.database;
//     List<Map<String, dynamic>> x =
//         await db.rawQuery('SELECT COUNT (*) from $listaUserTable');
//
//     int resultado = Sqflite.firstIntValue(x);
//     return resultado;
//   }
//
//   // Future<Lista> getListUser(int id) async {
//   //   Database db = await this.database;
//   //   List<Map> maps = await db.rawQuery(
//   //       'select user.nome, $listaNome from $userTable inner join $listaUserTable on $userId = $listaUser_UserId and $listaTable inner join $listaUserTable on $listaId = $listaUser_ListaId',);
//
//   //   if (maps.length > 0) {
//   //     return Lista.fromMap(maps.first);
//   //   } else {
//   //     return null;
//   //   }
//   // }
//
//   Future<Lista> addUserList(int id) async {
//     Database db = await this.database;
//     List<Map> maps = await db.rawQuery(
//       'select user.nome, $listaNome from $userTable inner join $listaUserTable on $userId = $listaUser_UserId and $listaTable inner join $listaUserTable on $listaId = $listaUser_ListaId',
//     );
//
//     if (maps.length > 0) {
//       return Lista.fromMap(maps.first);
//     } else {
//       return null;
//     }
//   }
//
//   Future<int> insertListaUser(ListaUser listaUser) async {
//     Database db = await this.database;
//     var resultado = await db.insert(listaUserTable, listaUser.toMap());
//     return resultado;
//   }
//
//   Future<List> queryAll() async {
//     Database db = await database;
//     List<Map> names = await db.rawQuery(
//         'select Name.name, count(Date.date) from Name left join Date using(id) group by Name.name');
//     if (names.length > 0) {
//       return names;
//     }
//     return null;
//   }
//
//   Future close() async {
//     Database db = await this.database;
//     db.close();
//   }
// }
