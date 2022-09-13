import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ResetPasswordRepository extends ChangeNotifier {
  final Dio _client = Dio();

  change(String newPassword, String token, String cpf) async {
    try {
      _client.options.headers["authorization"] = "Bearer $token";

      await _client.post(
          'https://api-combustivel.sbgestor.app/auth/change-password',
          data: {'cpf': cpf, 'newPassword': newPassword});

      return {"status": true};
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
