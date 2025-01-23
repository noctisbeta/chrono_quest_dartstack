import 'package:chrono_quest/authentication/components/my_elevated_button.dart';
import 'package:chrono_quest/authentication/components/my_outlined_text.dart';
import 'package:chrono_quest/authentication/components/my_text_field.dart';
import 'package:chrono_quest/common/constants/colors.dart';
import 'package:chrono_quest/common/constants/numbers.dart';
import 'package:chrono_quest/common/util/screen_type.dart';
import 'package:chrono_quest/common/util/unfocus_on_tap.dart';
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

  void _loginWithEmail() {}

  void _registerWithEmail() {}

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final ScreenType screenType = switch (constraints.maxWidth) {
            < 600.0 => ScreenType.mobile,
            >= 600.0 && < 1200.0 => ScreenType.tablet,
            >= 1200.0 => ScreenType.desktop,
            _ => ScreenType.mobile,
          };
          return Scaffold(
            backgroundColor: kPrimaryColor,
            body: UnfocusOnTap(
              child: SafeArea(
                child: Center(
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: kPadding * 2),
                    child: Column(
                      children: [
                        const Spacer(),
                        const MyOutlinedText(
                          text: 'Welcome',
                          fontWeight: FontWeight.w600,
                          fontsize: 32,
                          strokeWidth: 2,
                          foreground: kQuaternaryColor,
                          background: kBlack,
                        ),
                        const MyOutlinedText(
                          text: 'Sign in or register',
                          fontWeight: FontWeight.w400,
                          fontsize: 16,
                          strokeWidth: 1,
                          foreground: kQuaternaryColor,
                          background: kBlack,
                        ),
                        const SizedBox(height: kPadding * 2),
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: switch (screenType) {
                              ScreenType.mobile => 300.0,
                              ScreenType.tablet => 400.0,
                              ScreenType.desktop => 400.0,
                            },
                          ),
                          padding: const EdgeInsets.all(kPadding),
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius: BorderRadius.circular(kBorderRadius),
                            border: Border.all(
                              color: kQuaternaryColor,
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              MyTextField(
                                onChanged: (value) {},
                                keyboardType: TextInputType.emailAddress,
                                label: 'Email',
                              ),
                              const SizedBox(height: kPadding),
                              MyTextField(
                                onChanged: (value) {},
                                label: 'Password',
                                obscureText: true,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  MyElevatedButton(
                                    label: 'Login',
                                    backgroundColor: kSecondaryColor,
                                    onPressed: _loginWithEmail,
                                  ),
                                  MyElevatedButton(
                                    label: 'Register',
                                    backgroundColor: kQuaternaryColor,
                                    onPressed: _registerWithEmail,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
