import 'package:control_app/src/shared/models/fuel_station_model.dart';
import 'package:control_app/src/shared/models/historic_model.dart';
import 'package:control_app/src/shared/models/truck_model.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import '../../repositories/server_repository.dart';
import '../../shared/app_settings.dart';

class PreLoadPage extends StatefulWidget {
  const PreLoadPage({Key? key}) : super(key: key);

  @override
  State<PreLoadPage> createState() => _PreLoadPageState();
}

class _PreLoadPageState extends State<PreLoadPage> {
  late Map<String, String> loginInfos;
  late ServerRepository serverRepository;

  credentialsCheck() async {
    await context.read<AppSettings>().startSettings();
    await Future.delayed(const Duration(seconds: 1));
    check();
  }

  check() async {
    loginInfos = context.read<AppSettings>().loginInfos;

    bool hasIntenet = await InternetConnectionChecker().hasConnection;
    if (hasIntenet == true) {
      if (loginInfos["token"] == "" || loginInfos["cpf"] == "") {
        loginError();
      } else {
        if (await getUserInfos()) {
          if (await getTrucks()) {
            if (await getFuelStations()) {
              if (await getHistorics()) {
                if (await getPrice()) {
                  loginSucess();
                } else {
                  loginError();
                }
              } else {
                loginError();
              }
            } else {
              loginError();
            }
          } else {
            loginError();
          }
        } else {
          loginError();
        }
      }
    } else {
      loginErrorInternet();
    }
  }

  getUserInfos() async {
    Map<dynamic, dynamic> response = await serverRepository.getAccountInfos(
        loginInfos["cpf"]!, loginInfos["token"]!);
    if (response["status"]) {
      await setInfos(response["average"], response["lastAverage"],
          response["kmTraveled"], response["award"]);

      return true;
    } else {
      return false;
    }
  }

  getTrucks() async {
    Map<dynamic, dynamic> response =
        await serverRepository.getTruck(loginInfos["token"] ?? "");
    if (response["status"]) {
      List<TruckModel> truckList = <TruckModel>[];
      for (var truck in response["trucks"]) {
        truckList.add(TruckModel(
          truck["licensePlate"],
          truck["odometer"],
          truck["capacity"],
          truck["average"],
        ));
      }
      truckList.sort((a, b) => a.licensePlate.compareTo(b.licensePlate));
      await setTrucks(truckList);

      return true;
    } else {
      return false;
    }
  }

  getFuelStations() async {
    Map<dynamic, dynamic> response =
        await serverRepository.getFuelStations(loginInfos["token"] ?? "");
    if (response["status"]) {
      List<FuelStationModel> fuelStationList = <FuelStationModel>[];
      for (var fuelStation in response["fuelStations"]) {
        fuelStationList
            .add(FuelStationModel(fuelStation["name"], fuelStation["cnpj"]));
      }
      await setFuelStations(fuelStationList);

      return true;
    } else {
      return false;
    }
  }

  getHistorics() async {
    Map<dynamic, dynamic> response = await serverRepository.getHistorics(
        loginInfos["cpf"] ?? "", loginInfos["token"] ?? "");
    if (response["status"]) {
      List<HistoricModel> historicList = <HistoricModel>[];
      for (var historic in response["historics"]) {
        historicList.add(HistoricModel(
            historic["_id"],
            DateTime.parse(historic["date"]),
            historic["fuelStationName"],
            historic["currentOdometer"],
            historic["liters"] * 1.0,
            historic["value"] * 1.0));
      }
      await setHistorics(historicList);

      return true;
    } else {
      return false;
    }
  }

  getPrice() async {
    Map<dynamic, dynamic> response =
        await serverRepository.getPrice(loginInfos["token"] ?? "");
    if (response["status"]) {
      await setPrice(response["price"]["price"]);

      return true;
    } else {
      return false;
    }
  }

  setInfos(average, lastAverage, kmTraveled, award) async {
    await context.read<AppSettings>().setInfos(average.toString(),
        lastAverage.toString(), kmTraveled.toString(), award.toString());
  }

  setTrucks(List<TruckModel> trucks) async {
    await context.read<AppSettings>().setTrucks(trucks);
  }

  setFuelStations(List<FuelStationModel> fuelStations) async {
    await context.read<AppSettings>().setFuelStations(fuelStations);
  }

  setHistorics(List<HistoricModel> historics) async {
    await context.read<AppSettings>().setHistorics(historics);
  }

  setPrice(double price) async {
    await context.read<AppSettings>().setPrice(price);
  }

  loginSucess() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  loginError() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  loginErrorInternet() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sem conexão com a Internet.")),
    );

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    serverRepository = context.watch<ServerRepository>();
    credentialsCheck();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: Image.asset('assets/img/logo.png')),
      ),
      extendBody: true,
    );
  }
}
