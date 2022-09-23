import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AddRepository extends ChangeNotifier {
  final Dio _client = Dio();

  Future postAbastecimento(
      String placa,
      DateTime data,
      int month,
      String cpf,
      String posto,
      String cnpj,
      odometro,
      litros,
      valor,
      File odometroImage,
      File notaImage,
      arlaLiters,
      arlaPrice,
      String token) async {
    try {
      var formData = FormData.fromMap({
        'truckLicensePlate': placa,
        'date': data,
        'month': month,
        'cpf': cpf,
        'fuelStationName': posto,
        'cnpj': cnpj,
        'currentOdometerValue': odometro,
        'liters': litros,
        'value': valor,
        'arlaLiters': arlaLiters,
        'arlaPrice': arlaPrice,
        'odometer': await MultipartFile.fromFile(odometroImage.path),
        'nota': await MultipartFile.fromFile(notaImage.path)
      });

      _client.options.headers["authorization"] = "Bearer $token";

      var response = await _client.post(
          'https://api-combustivel.sbgestor.app/historic/',
          data: formData);

      return {
        "status": true,
        "average": response.data["userInfos"]["average"],
        "lastAverage": response.data["userInfos"]["lastAverage"],
        "kmTraveled": response.data["userInfos"]["kmTraveled"],
        "award": response.data["userInfos"]["award"],
        "historic": response.data["historic"]
      };
    } on DioError catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response != null) {
        return {"status": false, "message": e.response?.data["message"]};
      } else {
        return {"status": false, "message": e.message};
      }
    }
  }
}
