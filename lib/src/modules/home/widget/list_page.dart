import 'package:control_app/src/modules/home/widget/list_item_widget.dart';
import 'package:control_app/src/shared/models/historic_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/app_settings.dart';

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late List<HistoricModel> historics;

  readInfos() {
    historics = context.watch<AppSettings>().historics;
  }

  @override
  Widget build(BuildContext context) {
    readInfos();

    return Column(
      children: [
        const Center(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(
              'Histórico',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: historics.length,
            itemBuilder: (context, index) {
              return ListItemWidget(
                date: historics[historics.length - 1 - index].date.toLocal(),
                posto: historics[historics.length - 1 - index].fuelStation,
                odometro:
                    historics[historics.length - 1 - index].odometer.toString(),
                litros:
                    historics[historics.length - 1 - index].liters.toString(),
                valor: historics[historics.length - 1 - index].value.toString(),
                send: true,
              );
            },
          ),
        ),
        const SizedBox(
          height: 25,
        )
      ],
    );
  }
}
