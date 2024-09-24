import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool _acceptTerms = false;
  bool _receiveNewsletter = false;
  final double _userAge = 18;
  String _selectedGender = 'Male';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController(); // Controller para o campo de data

  @override
  void dispose() {
    _dateController.dispose(); // Libera o controlador da memória quando a tela é fechada
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked); // Formata a data no campo
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Registration")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Register',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Repeat Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Gender Selection using RadioButtons
                  const Text('Gender', style: TextStyle(fontSize: 18)),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Male'),
                          value: 'Male',
                          groupValue: _selectedGender,
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Female'),
                          value: 'Female',
                          groupValue: _selectedGender,
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Date of Birth Input with Calendar Picker
                  const Text('Date of Birth', style: TextStyle(fontSize: 18)),
                  TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      border: OutlineInputBorder(),
                      hintText: 'YYYY-MM-DD',
                    ),
                    readOnly: true, // O campo é somente leitura para abrir o calendário ao tocar
                    onTap: () => _selectDate(context), // Abre o calendário ao tocar no campo
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your date of birth';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Receive newsletter switch
                  SwitchListTile(
                    title: const Text('Receive Newsletter'),
                    value: _receiveNewsletter,
                    onChanged: (bool value) {
                      setState(() {
                        _receiveNewsletter = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Accept terms checkbox
                  CheckboxListTile(
                    title: const Text('I accept the terms and conditions'),
                    value: _acceptTerms,
                    onChanged: (bool? value) {
                      setState(() {
                        _acceptTerms = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Register Button
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (_acceptTerms) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Registration Successful!'),
                            ),
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Terms Not Accepted'),
                                content: const Text(
                                    'You must accept the terms and conditions to register.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    },
                    child: const Text('Register'),
                  ),
                  const SizedBox(height: 20),

                  // Login button
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Já tem uma conta? Faça login aqui',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: RegistrationScreen(),
    routes: {
      '/register': (context) => RegistrationScreen(),
    },
  ));
}
