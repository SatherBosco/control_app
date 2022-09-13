import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ServerRepository extends ChangeNotifier {
  final Dio _client = Dio();

  Future getAccountInfos(String cpf, String token) async {
    try {
      _client.options.headers["authorization"] = "Bearer $token";

      var response = await _client
          .get('https://api-combustivel.sbgestor.app/user-infos/one/$cpf');

      if (response.data["userInfos"] == null) {
        return {
          "status": true,
          "average": 0,
          "lastAverage": 0,
          "kmTraveled": 0,
          "award": 0
        };
      } else {
        return {
          "status": true,
          "average": response.data["userInfos"]["average"],
          "lastAverage": response.data["userInfos"]["lastAverage"],
          "kmTraveled": response.data["userInfos"]["kmTraveled"],
          "award": response.data["userInfos"]["award"]
        };
      }
    } on DioError catch (e) {
      if (e.response != null) {
        return {"status": false, "message": e.response?.data["message"]};
      } else {
        return {"status": false, "message": e.message};
      }
    }
  }

  Future getTruck(String token) async {
    try {
      _client.options.headers["authorization"] = "Bearer $token";

      var response =
          await _client.get('https://api-combustivel.sbgestor.app/truck/');

      return {"status": true, "trucks": response.data["trucks"]};
    } on DioError catch (e) {
      if (e.response != null) {
        return {"status": false, "message": e.response?.data["message"]};
      } else {
        return {"status": false, "message": e.message};
      }
    }
  }

  Future getFuelStations(String token) async {
    try {
      _client.options.headers["authorization"] = "Bearer $token";

      var response = await _client
          .get('https://api-combustivel.sbgestor.app/fuel-station/');

      return {"status": true, "fuelStations": response.data["fuelStations"]};
    } on DioError catch (e) {
      if (e.response != null) {
        return {"status": false, "message": e.response?.data["message"]};
      } else {
        return {"status": false, "message": e.message};
      }
    }
  }

  Future getHistorics(String cpf, String token) async {
    try {
      _client.options.headers["authorization"] = "Bearer $token";

      DateTime initialDate =
          DateTime(DateTime.now().year, DateTime.now().month, 1).toUtc();
      DateTime finalDate = DateTime.now().toUtc();

      var response = await _client.get(
          'https://api-combustivel.sbgestor.app/historic/by-user/$initialDate&$finalDate&$cpf');

      return {"status": true, "historics": response.data["historics"]};
    } on DioError catch (e) {
      if (e.response != null) {
        return {"status": false, "message": e.response?.data["message"]};
      } else {
        return {"status": false, "message": e.message};
      }
    }
  }

  Future getPrice(String token) async {
    try {
      _client.options.headers["authorization"] = "Bearer $token";

      int month = DateTime.now().month;
      print(month);

      var response = await _client
          .get('https://api-combustivel.sbgestor.app/price/$month');
      print(response.data);
      return {"status": true, "price": response.data["price"]};
    } on DioError catch (e) {
      if (e.response != null) {
        return {"status": false, "message": e.response?.data["message"]};
      } else {
        return {"status": false, "message": e.message};
      }
    }
  }
}
