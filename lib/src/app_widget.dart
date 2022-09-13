// import 'package:control_app/src/repositories/historic_repository.dart'; 123456789
import 'package:control_app/src/repositories/reset_password_repository.dart';
import 'package:control_app/src/repositories/server_repository.dart';
import 'package:flutter/material.dart';
import 'package:control_app/src/modules/auth/login_repository.dart';
import 'package:control_app/src/shared/app_settings.dart';
import 'package:provider/provider.dart';
import 'modules/add/add_page.dart';
import 'modules/add/add_repository.dart';
import 'modules/auth/login_page.dart';
import 'modules/home/home_page.dart';
import 'modules/load/pre_load_page.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppSettings()),
        // ChangeNotifierProvider(create: (context) => HistoricRepository()), 123456789
        ChangeNotifierProvider(create: (context) => ServerRepository()),
        ChangeNotifierProvider(create: (context) => LoginRepository()),
        ChangeNotifierProvider(create: (context) => AddRepository()),
        ChangeNotifierProvider(create: (context) => ResetPasswordRepository()),
      ],
      child: MaterialApp(
        title: 'SB Gestor de Combustível',
        theme: ThemeData(
          primarySwatch: Colors.red,
          brightness: Brightness.light,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const PreLoadPage(),
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HomePage(),
          '/add': (context) => const AddPage(),
        },
      ),
    );
  }
}
