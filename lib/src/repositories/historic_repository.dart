// import 'package:flutter/cupertino.dart';
// import 'package:sqflite/sqflite.dart';
// import '../database/db.dart';
// import '../models/historic.dart';

// class HistoricRepository extends ChangeNotifier {
//   late Database db;
//   List<Historic> _historic = [];

//   List<Historic> get historic => _historic;

//   HistoricRepository() {
//     _initRepository();
//   }

//   _initRepository() async {
//     await _getHistoric();
//   }

//   _getHistoric() async {
//     _historic = [];
//     db = await DB.instance.database;
//     List historic = await db.query('historicoTable');
//     for (var hist in historic) {
//       _historic.add(Historic(
//           caminhao: hist['caminhao'],
//           data: hist['data'],
//           litros: hist['litros'],
//           odometro: hist['odometro'],
//           posto: hist['posto'],
//           valor: hist['valor']));
//     }
//     notifyListeners();
//   }

//   setHistoric(String data, String caminhao, String posto, int odometro,
//       String litros, String valor) async {
//     db = await DB.instance.database;
//     await db.transaction((txn) async {
//       await txn.insert('historicoTable', {
//         'data': data,
//         'caminhao': caminhao,
//         'posto': posto,
//         'odometro': odometro,
//         'litros': litros,
//         'valor': valor
//       });
//     });

//     await _initRepository();
//     notifyListeners();
//   }
// }
