import 'package:flutter/material.dart';
import 'package:hwenti_flutter/screens/auth/login_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginScreen(initialIsSignup: true);
  }
}
