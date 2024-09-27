import 'package:flutter/material.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificação de E-mail'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Um e-mail de verificação foi enviado para o seu endereço de e-mail. Por favor, verifique sua caixa de entrada e confirme seu e-mail para continuar.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Opcional: Redirecionar para a tela de login
                  Navigator.pop(context);
                },
                child: const Text('Voltar ao Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
