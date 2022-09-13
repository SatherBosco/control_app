import 'dart:io';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:camera_camera/camera_camera.dart';
import 'package:control_app/src/modules/add/preview_page.dart';
import 'package:control_app/src/shared/models/fuel_station_model.dart';
import 'package:control_app/src/shared/models/historic_model.dart';
import 'package:control_app/src/shared/models/truck_model.dart';
import 'package:control_app/src/shared/models/user_infos_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../shared/app_settings.dart';
import '../../utils/convert.dart';
import 'add_repository.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  bool _isLoading = false;
  final _form = GlobalKey<FormState>();
  final _odometer = TextEditingController();
  final _liters = TextEditingController();
  final _value = TextEditingController();
  String _truck = "";
  String _fuelStation = "";
  File? odometro;
  File? nota;
  final picker = ImagePicker();

  late AddRepository addRepository;
  late Map<String, String> loginInfos;
  late UserInfosModel userInfos;
  List<TruckModel> trucks = [];
  List<FuelStationModel> fuelStations = [];
  double price = 7;
  DateTime date = DateTime.now();

  readInfos() {
    loginInfos = context.watch<AppSettings>().loginInfos;
    userInfos = context.watch<AppSettings>().userInfos;
    price = context.watch<AppSettings>().price;
    if (trucks.isEmpty) {
      trucks = context.watch<AppSettings>().trucks;
      _truck = userInfos.truck;
    }
    if (fuelStations.isEmpty) {
      fuelStations = context.watch<AppSettings>().fuelStations;
      _fuelStation = fuelStations[0].name;
    }
  }

  showPreviewNota(file) async {
    Navigator.pop(context);
    file = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewPage(file: file),
      ),
    );
    FocusManager.instance.primaryFocus?.unfocus();

    if (file != null) {
      setState(() {
        nota = File(file.path);
      });
    } else {
      goToNotaCamera();
    }
  }

  showPreviewOdometro(file) async {
    Navigator.pop(context);
    file = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewPage(file: file),
      ),
    );
    FocusManager.instance.primaryFocus?.unfocus();

    if (file != null) {
      setState(() {
        odometro = File(file.path);
      });
    } else {
      goToOdometroCamera();
    }
  }

  goToNotaCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              CameraCamera(onFile: (file) => showPreviewNota(file))),
    );
  }

  goToOdometroCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              CameraCamera(onFile: (file) => showPreviewOdometro(file))),
    );
  }

  Future getFileFromGalleryNota() async {
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        nota = File(file.path);
      });
    }
  }

  Future getFileFromGalleryOdometro() async {
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        odometro = File(file.path);
      });
    }
  }

  saveAbastecimento() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isLoading = true;
    });
    if (_form.currentState!.validate() &&
        nota != null &&
        odometro != null &&
        _truck != "" &&
        _fuelStation != "") {
      var postoCnpj = fuelStations
          .firstWhere((element) => element.name == _fuelStation)
          .cnpj;
      Map<dynamic, dynamic> response = await addRepository.postAbastecimento(
          _truck,
          date.toUtc(),
          date.month,
          loginInfos["cpf"] ?? "",
          _fuelStation,
          postoCnpj,
          int.tryParse(UtilBrasilFields.removeCaracteres(_odometer.text)) ?? 0,
          double.tryParse(
                  _liters.text.replaceAll(".", "").replaceAll(",", ".")) ??
              0,
          double.tryParse(
                  _value.text.replaceAll(".", "").replaceAll(",", ".")) ??
              0,
          odometro!,
          nota!,
          loginInfos["token"] ?? "");

      if (response["status"]) {
        await setInfos(response["average"], response["lastAverage"],
            response["kmTraveled"], response["award"]);

        await setHistoric(
            response["historic"]["_id"],
            DateTime.parse(response["historic"]["date"]),
            response["historic"]["fuelStationName"],
            response["historic"]["currentOdometer"],
            response["historic"]["liters"] * 1.0,
            response["historic"]["value"] * 1.0);

        loginSucess();
      } else {
        loginError(response["message"]);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  setInfos(media, lastMedia, km, premio) async {
    await context.read<AppSettings>().setInfos(media.toString(),
        lastMedia.toString(), km.toString(), premio.toString());
    await setPersonalTruck();
  }

  setPersonalTruck() async {
    int odometerKm =
        int.tryParse(UtilBrasilFields.removeCaracteres(_odometer.text)) ?? 0;
    await context.read<AppSettings>().setOneTruck(odometerKm, _truck);
  }

  setHistoric(String id, DateTime date, String fuelStattion, int odometer,
      double liters, double value) async {
    HistoricModel historic =
        HistoricModel(id, date, fuelStattion, odometer, liters, value);
    await context.read<AppSettings>().setOneHistoric(historic);
  }

  loginSucess() {
    Navigator.pop(context);
  }

  loginError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    addRepository = context.watch<AddRepository>();
    // historico = Provider.of<HistoricRepository>(context, listen: false); 123456789
    readInfos();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Adicionar Abastecimento',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 20.0),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 70, vertical: 0),
                  child: DropdownButtonFormField(
                    iconSize: 20,
                    icon: const Icon(Icons.local_shipping),
                    decoration: InputDecoration(
                      label: const Text('Caminhão'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    isExpanded: false,
                    value: _truck,
                    items: trucks
                        .map<DropdownMenuItem<String>>((TruckModel truck) {
                      return DropdownMenuItem<String>(
                        value: truck.licensePlate,
                        child: Center(child: Text(truck.licensePlate)),
                      );
                    }).toList(),
                    onChanged: _isLoading
                        ? null
                        : (String? value) {
                            _truck = value ?? "";
                          },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 70, vertical: 20),
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              DateTime? newDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(DateTime.now().year,
                                      DateTime.now().month, 1),
                                  lastDate: DateTime.now());

                              if (newDate == null) return;

                              setState(() => date = newDate);
                            },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_month),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${date.day}/${date.month}/${date.year}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Form(
                  key: _form,
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 7),
                      child: TextFormField(
                        enabled: !_isLoading,
                        controller: _odometer,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Odômetro',
                          prefixIcon: Icon(
                            Icons.onetwothree,
                          ),
                          suffix: Text(
                            'KMs',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Informe o odometro';
                          }
                          TruckModel truckAux = trucks.firstWhere(
                              ((truck) => truck.licensePlate == _truck));
                          int km = truckAux.odometer;
                          int valor = int.tryParse(
                                  UtilBrasilFields.removeCaracteres(value)) ??
                              0;
                          int valorMax =
                              ((truckAux.average) * (truckAux.capacity) * 1.5)
                                  .round();
                          if (valor == 0) {
                            return 'Informe o odometro';
                          }
                          if (km >= valor || valor > km + valorMax) {
                            return 'Odometro incorreto';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          RealInputFormatter()
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 7),
                      child: TextFormField(
                        enabled: !_isLoading,
                        controller: _liters,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Litros',
                          prefixIcon: Icon(
                            Icons.oil_barrel,
                          ),
                          suffix: Text(
                            'Litros',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Informe os litros';
                          }
                          double valor = double.tryParse(value
                                  .replaceAll(".", "")
                                  .replaceAll(",", ".")) ??
                              0;
                          TruckModel truckAux = trucks.firstWhere(
                              ((truck) => truck.licensePlate == _truck));
                          int valorMax = truckAux.capacity;
                          if (valor == 0) {
                            return 'Informe os litros';
                          }
                          if (valor > valorMax) {
                            return 'Litros incorreto';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LitrosInputFormatter(casasDecimais: 2)
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 7),
                      child: TextFormField(
                        enabled: !_isLoading,
                        controller: _value,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Valor',
                          prefixIcon: Icon(
                            Icons.paid,
                          ),
                          suffix: Text(
                            'Reais',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        validator: (value) {
                          if (_liters.text == "" || value!.isEmpty) {
                            return 'Informe os valores';
                          }
                          if (value.isEmpty) {
                            return 'Informe o valor';
                          }
                          double valor = double.tryParse(value
                                  .replaceAll(".", "")
                                  .replaceAll(",", ".")) ??
                              0;
                          double litros = double.tryParse(_liters.text
                                  .replaceAll(".", "")
                                  .replaceAll(",", ".")) ??
                              0;
                          if (valor == 0 || litros == 0) {
                            return 'Informe o valor';
                          }
                          if (valor > litros * (price * 1.5) ||
                              valor < litros * (price * 0.5)) {
                            return 'Valor incorreto';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CentavosInputFormatter()
                        ],
                      ),
                    ),
                  ]),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 7),
                  child: DropdownButtonFormField(
                    iconSize: 20,
                    icon: const Icon(Icons.local_gas_station),
                    decoration: InputDecoration(
                      label: const Text('Posto'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    isExpanded: false,
                    value: fuelStations[0].name,
                    items: fuelStations.map<DropdownMenuItem<String>>(
                        (FuelStationModel fuelStation) {
                      return DropdownMenuItem<String>(
                        value: fuelStation.name,
                        child: Center(child: Text(fuelStation.name)),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      _fuelStation = value ?? "";
                    },
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(15, 10, 15, 5),
                  child: Text(
                    'Foto da nota fiscal:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: nota == null
                              ? const Color.fromARGB(136, 240, 1, 1)
                              : const Color.fromARGB(255, 0, 255, 42),
                          blurRadius: 0.5,
                          offset: const Offset(0.0, 0.0))
                    ],
                    color: nota == null
                        ? const Color.fromARGB(255, 255, 209, 209)
                        : const Color.fromARGB(255, 213, 255, 209),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.photo_camera,
                          size: 20,
                        ),
                        onPressed: _isLoading ? null : goToNotaCamera,
                        label: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Câmera'),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        'ou',
                        style: TextStyle(fontWeight: FontWeight.w200),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.collections,
                          size: 20,
                        ),
                        onPressed: _isLoading ? null : getFileFromGalleryNota,
                        label: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Galeria'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(15, 10, 15, 5),
                  child: Text(
                    'Foto do odômetro:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: odometro == null
                              ? const Color.fromARGB(136, 240, 1, 1)
                              : const Color.fromARGB(255, 0, 255, 42),
                          blurRadius: 0.5,
                          offset: const Offset(0.0, 0.0))
                    ],
                    color: odometro == null
                        ? const Color.fromARGB(255, 255, 209, 209)
                        : const Color.fromARGB(255, 213, 255, 209),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.photo_camera,
                          size: 20,
                        ),
                        onPressed: _isLoading ? null : goToOdometroCamera,
                        label: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Câmera'),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        'ou',
                        style: TextStyle(fontWeight: FontWeight.w200),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(
                          Icons.collections,
                          size: 20,
                        ),
                        onPressed:
                            _isLoading ? null : getFileFromGalleryOdometro,
                        label: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Galeria'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 0),
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : saveAbastecimento,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _isLoading ? Container() : const Icon(Icons.check),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              _isLoading ? 'Salvando...' : 'Salvar',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
