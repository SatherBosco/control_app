import 'package:brasil_fields/brasil_fields.dart';
import 'package:control_app/src/modules/auth/login_repository.dart';
import 'package:control_app/src/shared/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final _form = GlobalKey<FormState>();
  final _cpf = TextEditingController();
  final _password = TextEditingController();
  late LoginRepository loginRepository;

  login() async {
    _isLoading = true;
    if (_form.currentState!.validate()) {
      Map<dynamic, dynamic> response = await loginRepository.authenticate(
          UtilBrasilFields.removeCaracteres(_cpf.text), _password.text);

      if (response["status"]) {
        if (response["role"] != 4 || response["truck"] == "") {
          loginError("Usuário não autorizado.");
        } else {
          await saveInfos(response["token"], response["role"].toString(),
              response["cpf"], response["firstName"], response["truck"]);

          loginSucess();
        }
      } else {
        loginError(response["message"]);
      }
    }
    _isLoading = false;
  }

  saveInfos(String token, String role, String cpf, String firstName,
      String truck) async {
    await context
        .read<AppSettings>()
        .setLogin(token, role, cpf, firstName, truck);
  }

  loginSucess() {
    Navigator.pushReplacementNamed(context, '/');
  }

  loginError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    loginRepository = context.watch<LoginRepository>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        title: Image.asset(
          'assets/img/logo.png',
          height: 60,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _form,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Login',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25),
                ),
                const SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: _cpf,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'CPF',
                    prefixIcon: Icon(
                      Icons.badge,
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty || value.length < 14) {
                      return 'Informe o CPF';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CpfInputFormatter()
                  ],
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Senha',
                    prefixIcon: Icon(
                      Icons.password,
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty || value.length < 3) {
                      return 'Informe a senha';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(left: 50, right: 50),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : login,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.login),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Entrar',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )),
      ),
      extendBody: true,
    );
  }
}
