import 'package:control_app/src/shared/models/user_infos_model.dart';
import 'package:flutter/material.dart';
import 'package:control_app/src/modules/home/widget/person_card_widget.dart';
import 'package:provider/provider.dart';
import '../../../shared/app_settings.dart';

class PersonPage extends StatefulWidget {
  const PersonPage({Key? key}) : super(key: key);

  @override
  State<PersonPage> createState() => _PersonPageState();
}

class _PersonPageState extends State<PersonPage> {
  late UserInfosModel userInfos;

  readInfos() {
    userInfos = context.watch<AppSettings>().userInfos;
  }

  @override
  Widget build(BuildContext context) {
    readInfos();

    return ListView(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Text(
              "Olá ${userInfos.firstName}",
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
          ),
        ),
        PersonCardWidget(
          description: 'Premiação acumulada em:',
          value: 'R\$ ${(userInfos.award).toStringAsFixed(2)}',
          icon: Icons.attach_money,
        ),
        PersonCardWidget(
            description: 'Caminhão principal:',
            value: userInfos.truck,
            icon: Icons.local_shipping),
        PersonCardWidget(
          description: 'KMs percorridos:',
          value: '${userInfos.kmTraveled} KM',
          icon: Icons.add_road,
        ),
        PersonCardWidget(
          description: 'Média acumulada:',
          value: '${(userInfos.average).toStringAsFixed(2)} KM/L',
          icon: Icons.local_gas_station,
        ),
        PersonCardWidget(
          description: 'Média do último abastecimento:',
          value: '${(userInfos.lastAverage).toStringAsFixed(2)} KM/L',
          icon: Icons.local_gas_station,
        ),
        const SizedBox(
          height: 20,
        )
      ],
    );
  }
}
