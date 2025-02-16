import 'package:chrono_quest/authentication/controllers/auth_bloc.dart';
import 'package:chrono_quest/authentication/models/auth_event.dart';
import 'package:chrono_quest/common/components/my_elevated_button.dart';
import 'package:chrono_quest/common/components/my_loading_indicator.dart';
import 'package:chrono_quest/common/components/my_text_field.dart';
import 'package:chrono_quest/common/constants/colors.dart';
import 'package:chrono_quest/common/constants/numbers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthenticationForm extends StatefulWidget {
  const AuthenticationForm({required this.isLoading, super.key});

  final bool isLoading;

  @override
  State<AuthenticationForm> createState() => AuthenticationFormState();
}

class AuthenticationFormState extends State<AuthenticationForm> {
  final TextEditingController usernameCtl = TextEditingController();
  final TextEditingController passwordCtl = TextEditingController();

  @override
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: widget.isLoading,
    child: Container(
      padding: const EdgeInsets.all(kPadding),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(kBorderRadius),
        border: Border.all(color: kQuaternaryColor, width: 2),
      ),
      child: Column(
        children: [
          MyTextField(
            controller: usernameCtl,
            textInputAction: TextInputAction.next,
            label: 'Username',
          ),
          const SizedBox(height: kPadding),
          MyTextField(
            textInputAction: TextInputAction.done,
            controller: passwordCtl,
            label: 'Password',
            obscureText: true,
          ),
          const SizedBox(height: 16),
          switch (widget.isLoading) {
            true => const MyLoadingIndicator(),
            false => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                MyElevatedButton(
                  label: 'Login',
                  backgroundColor: kSecondaryColor,
                  onPressed: () => login(context),
                ),
                MyElevatedButton(
                  label: 'Register',
                  backgroundColor: kQuaternaryColor,
                  onPressed: () => register(context),
                ),
              ],
            ),
          },
        ],
      ),
    ),
  );

  void login(BuildContext context) {
    final String username = usernameCtl.text;
    final String password = passwordCtl.text;

    context.read<AuthBloc>().add(
      AuthEventLogin(username: username, password: password),
    );
  }

  void register(BuildContext context) {
    final String username = usernameCtl.text;
    final String password = passwordCtl.text;

    context.read<AuthBloc>().add(
      AuthEventRegister(username: username, password: password),
    );
  }
}
