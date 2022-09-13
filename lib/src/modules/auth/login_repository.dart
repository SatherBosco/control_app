import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class LoginRepository extends ChangeNotifier {
  final Dio _client = Dio();

  Future authenticate(String cpf, String password) async {
    try {
      var response = await _client.post(
          'https://api-combustivel.sbgestor.app/auth/authenticate',
          data: {'cpf': cpf, 'password': password});

      return {
        "status": true,
        "token": response.data["token"],
        "role": response.data["user"]["role"],
        "cpf": cpf,
        "firstName": response.data["user"]["firstName"],
        "truck": response.data["user"]["truckLicensePlate"]
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
