import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 16, 16, 16),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 16, 16, 16),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.bolt,
                    size: 60,
                    color: Color.fromARGB(255, 0, 230, 118),
                  ),
                ),
                const SizedBox(height: 40),

                // Card de Login
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(180, 28, 28, 28),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 24,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          'PAWAKINI',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 255, 200),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Conversão Cinética → Elétrica',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 127, 170, 255),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Campo Email
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(255, 24, 24, 24),
                            labelText: 'Email',
                            labelStyle: const TextStyle(
                              color: Color.fromARGB(200, 200, 200, 200),
                            ),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Color.fromARGB(255, 0, 200, 255),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(80, 255, 255, 255),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 0, 255, 200),
                                width: 1.5,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor insira o email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Campo Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(255, 24, 24, 24),
                            labelText: 'Password',
                            labelStyle: const TextStyle(
                              color: Color.fromARGB(200, 200, 200, 200),
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color.fromARGB(255, 0, 200, 255),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(80, 255, 255, 255),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 0, 255, 200),
                                width: 1.5,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor insira a password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),

                        // Botão Login (verde-água brilhante)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DashboardScreen(),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 0, 255, 200),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 6,
                            ),
                            child: const Text(
                              'ENTRAR',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 16, 16, 16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'POWERED BY WATERBERRY',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromARGB(179, 255, 255, 255),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
