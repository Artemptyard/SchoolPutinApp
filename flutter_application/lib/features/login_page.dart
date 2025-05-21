import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final key_form = GlobalKey<FormState>();
  String login = '';
  String password = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(25),
              color: const Color.fromARGB(255, 121, 166, 203),
            ),
            width: 300,
            height: 300,
            child: Form(
              key: key_form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Логин', border: OutlineInputBorder()),
                      onSaved: (newValue) => login = newValue ?? '',
                      validator: (value) {
                        if (value == '' || value == null){
                          return 'Введите логин';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20,),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Пароль', border: OutlineInputBorder()),
                      onSaved: (newValue) => password = newValue ?? '',
                      validator: (value) {
                        if (value == '' || value == null){
                          return 'Введите пароль';
                        }
                        return null;
                      },
                    ),
                    Spacer(),
                    ElevatedButton(onPressed: () {
                      if (key_form.currentState!.validate()) {
                        key_form.currentState!.save();
                        print('Логин успешен!');
                        _redirectAfterLogin(context);
                      }
                    }, 
                    child: const Text('Войти'))
                  ],
              )
            ),
          ),
        ),
      ),
    );
  }

   void _redirectAfterLogin(BuildContext context) {
    final role = login;
    switch (role) {
      case 'teacher':
        GoRouter.of(context).go('/teacher');
        break;
      case 'student':
        GoRouter.of(context).go('/student');
        break;
      case 'parent':
        GoRouter.of(context).go('/parent');
        break;
      default:
        GoRouter.of(context).go('/login');
    }
  }

}