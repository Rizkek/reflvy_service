import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../../controller/auth_controller.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final isFilled = ValueNotifier<bool>(false);
    final passwordVisible = ValueNotifier<bool>(false);

    void checkFields() {
      isFilled.value =
          usernameController.text.isNotEmpty &&
          passwordController.text.isNotEmpty;
    }

    usernameController.addListener(checkFields);
    passwordController.addListener(checkFields);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Login'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<bool>(
                  valueListenable: passwordVisible,
                  builder: (context, isVisible, child) {
                    return TextField(
                      controller: passwordController,
                      obscureText: !isVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            passwordVisible.value = !isVisible;
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                ValueListenableBuilder<bool>(
                  valueListenable: isFilled,
                  builder: (context, value, child) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: value ? Colors.blue : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: value
                          ? () async {
                              final username = usernameController.text;
                              final password = passwordController.text;
                              final success = await AuthController.login(
                                username,
                                password,
                              );
                              if (success) {
                                Get.offAllNamed('/home');
                              } else {
                                Get.snackbar(
                                  'Login Failed',
                                  'Invalid username or password',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            }
                          : null,
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Get.toNamed('/register');
                  },
                  child: const Text(
                    'Don\'t have an account? Register',
                    style: TextStyle(color: Colors.blue),
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
