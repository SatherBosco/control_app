import 'package:control_app/src/shared/models/fuel_station_model.dart';
import 'package:control_app/src/shared/models/historic_model.dart';
import 'package:control_app/src/shared/models/truck_model.dart';
import 'package:control_app/src/shared/models/user_infos_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  late SharedPreferences _prefs;
  Map<String, String> loginInfos = {
    'token': '',
    'role': '',
    'cpf': '',
  };
  UserInfosModel userInfos = UserInfosModel();
  List<FuelStationModel> fuelStations = <FuelStationModel>[];
  List<TruckModel> trucks = <TruckModel>[];
  List<HistoricModel> historics = <HistoricModel>[];

  AppSettings();

  startSettings() async {
    await _startPreferences();
    await _readInfos();
  }

  Future<void> _startPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  _readInfos() async {
    final token = _prefs.getString('token') ?? '';
    final role = _prefs.getString('role') ?? '';
    final cpf = _prefs.getString('cpf') ?? '';
    final firstName = _prefs.getString('firstName') ?? '';
    final truck = _prefs.getString('truck') ?? '';
    loginInfos = {'token': token, 'role': role, 'cpf': cpf};
    userInfos.firstName = firstName;
    userInfos.truck = truck;
    notifyListeners();
  }

  setLogin(String token, String role, String cpf, String firstName,
      String truck) async {
    await _prefs.setString('token', token);
    await _prefs.setString('role', role);
    await _prefs.setString('cpf', cpf);
    await _prefs.setString('firstName', firstName);
    await _prefs.setString('truck', truck);

    await _readInfos();
  }

  setInfos(String average, String lastAverage, String kmTraveled,
      String award) async {
    userInfos.average = double.tryParse(average) ?? 0;
    userInfos.lastAverage = double.tryParse(lastAverage) ?? 0;
    userInfos.award = double.tryParse(award) ?? 0;
    userInfos.kmTraveled = int.tryParse(kmTraveled) ?? 0;
    await _readInfos();
  }

  setTrucks(List<TruckModel> trucksList) async {
    trucks = trucksList;
    await _readInfos();
  }

  setFuelStations(List<FuelStationModel> fuelStationsList) async {
    fuelStations = fuelStationsList;
    await _readInfos();
  }

  setOneTruck(int truckKm, String licensePlate) async {
    int truckIndex =
        trucks.indexWhere(((truck) => truck.licensePlate == licensePlate));
    trucks[truckIndex].odometer = truckKm;
    await _readInfos();
  }

  setHistorics(List<HistoricModel> historicsList) async {
    historics = historicsList;
    await _readInfos();
  }

  setOneHistoric(HistoricModel historic) async {
    historics.add(historic);
    await _readInfos();
  }

  disconnect() async {
    await _prefs.setString('token', "");
    await _prefs.setString('role', "");
    await _prefs.setString('cpf', "");
    await _prefs.setString('firstName', "");
    await _prefs.setString('truck', "");

    await _readInfos();
  }
}
