import 'package:chrono_quest/authentication/components/title_banner.dart';
import 'package:chrono_quest/common/constants/colors.dart';
import 'package:chrono_quest/common/constants/numbers.dart';
import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationView extends StatefulWidget {
  const AuthenticationView({super.key});

  @override
  State<AuthenticationView> createState() => _AuthenticationViewState();
}

class _AuthenticationViewState extends State<AuthenticationView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // final GoogleSignIn _googleSignIn = GoogleSignIn();

  void _loginWithEmail() {
    // Implement login with email and password
  }

  void _registerWithEmail() {
    // Implement registration with email and password
  }

  // void _loginWithGoogle() async {
  //   try {
  //     await _googleSignIn.signIn();
  //     // Implement login with Google
  //   } catch (error) {
  //     print(error);
  //   }
  // }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kQuaternaryColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(kPadding),
            child: Column(
              children: [
                const TitleBanner(),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _loginWithEmail,
                      child: const Text('Login'),
                    ),
                    ElevatedButton(
                      onPressed: _registerWithEmail,
                      child: const Text('Register'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in with Google'),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
