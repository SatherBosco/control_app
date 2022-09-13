import 'package:flutter/material.dart';

class PersonCardWidget extends StatelessWidget {
  final String description;
  final String value;
  final IconData icon;

  const PersonCardWidget(
      {Key? key,
      required this.description,
      required this.value,
      required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          boxShadow: const <BoxShadow>[
            BoxShadow(
                color: Colors.black54,
                blurRadius: 0.5,
                offset: Offset(0.0, 0.0))
          ],
          color: const Color.fromRGBO(255, 255, 255, 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                child: Icon(
                  icon,
                  color: const Color.fromRGBO(233, 46, 0, 1),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(233, 46, 0, 1),
                      ),
                    ),
                    Text(value),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
