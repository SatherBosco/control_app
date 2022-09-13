import 'package:control_app/src/modules/home/widget/list_page.dart';
import 'package:control_app/src/modules/home/widget/person_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../repositories/reset_password_repository.dart';
import '../../shared/app_settings.dart';
import 'widget/bottom_bar_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showList = false;
  late Map<String, String> loginInfos;

  readInfos() {
    loginInfos = context.watch<AppSettings>().loginInfos;
  }

  void showList(bool show) {
    setState(() => _showList = show);
  }

  changePassword() {
    return PopupMenuButton(
      icon: const Icon(Icons.settings, color: Colors.red),
      itemBuilder: (context) => [
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(
              Icons.swap_vert,
              color: Colors.red,
            ),
            title: const Text('Trocar senha'),
            onTap: () {
              Navigator.pop(context);
              resetPassword();
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text('Desconectar'),
            onTap: () {
              Navigator.pop(context);
              disconnect();
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    readInfos();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        title: Image.asset(
          'assets/img/logo.png',
          height: 60,
        ),
        centerTitle: true,
        actions: [
          changePassword(),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: _showList ? const ListPage() : const PersonPage(),
        ),
      ),
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/add');
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomBar(showList: showList),
    );
  }

  resetPassword() async {
    final form = GlobalKey<FormState>();
    final newPassword = TextEditingController();
    final resetarSenha = context.read<ResetPasswordRepository>();

    AlertDialog dialog = AlertDialog(
      title: const Text('Trocar a senha'),
      content: Form(
        key: form,
        child: TextFormField(
          controller: newPassword,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value!.isEmpty || value.length < 6) return 'Informe uma senha.';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR')),
        TextButton(
          onPressed: () async {
            if (form.currentState!.validate()) {
              var response = await resetarSenha.change(
                  newPassword.text, loginInfos["token"]!, loginInfos["cpf"]!);
              if (response["status"]) {
                loginSucess();
              } else {
                loginError(response["message"]);
              }
            }
          },
          child: const Text('SALVAR'),
        ),
      ],
    );

    showDialog(context: context, builder: (context) => dialog);
  }

  disconnect() async {
    await context.read<AppSettings>().disconnect();

    disconnectSucess();
  }

  loginSucess() {
    Navigator.pop(context);
  }

  loginError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  disconnectSucess() {
    Navigator.pushReplacementNamed(context, "/");
  }
}
