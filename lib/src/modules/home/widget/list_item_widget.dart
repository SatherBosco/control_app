import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';

class ListItemWidget extends StatelessWidget {
  final DateTime date;
  final String posto;
  final String odometro;
  final String litros;
  final String valor;
  final bool send;

  const ListItemWidget(
      {Key? key,
      required this.date,
      required this.odometro,
      required this.litros,
      required this.valor,
      required this.send,
      required this.posto})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2.0, 5.0, 2.0, 5.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          boxShadow: const <BoxShadow>[
            BoxShadow(
                color: Colors.black54,
                blurRadius: 1.0,
                offset: Offset(0.0, 0.0))
          ],
          color: const Color.fromRGBO(255, 255, 255, 1),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15.0, 7.0, 15.0, 7.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Data: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(233, 46, 0, 1),
                    ),
                  ),
                  Text("${date.day}/${date.month}/${date.year}"),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'Posto: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(233, 46, 0, 1),
                    ),
                  ),
                  Text(posto),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'Odômetro: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(233, 46, 0, 1),
                    ),
                  ),
                  Text(odometro),
                  const Text(' KM'),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'Litros: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(233, 46, 0, 1),
                    ),
                  ),
                  Text(litros),
                  const Text(' L'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Valor: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(233, 46, 0, 1),
                        ),
                      ),
                      Text(UtilBrasilFields.obterReal(
                          double.tryParse(valor) ?? 0)),
                    ],
                  ),
                  Icon(
                    send ? Icons.done_all : Icons.schedule,
                    color: send
                        ? const Color.fromARGB(255, 10, 168, 5)
                        : const Color.fromARGB(255, 247, 212, 18),
                    size: 17,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
