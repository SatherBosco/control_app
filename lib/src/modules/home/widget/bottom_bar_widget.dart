import 'package:flutter/material.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({Key? key, required this.showList}) : super(key: key);
  final ValueChanged<bool> showList;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      color: Theme.of(context).colorScheme.primary,
      child: IconTheme(
        data: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  showList(true);
                },
                icon: const Icon(Icons.list),
              ),
              const SizedBox(
                width: 24,
              ),
              IconButton(
                onPressed: () {
                  showList(false);
                },
                icon: const Icon(Icons.person),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
