import 'package:chrono_quest/authentication/components/my_elevated_button.dart';
import 'package:chrono_quest/authentication/components/my_loading_indicator.dart';
import 'package:chrono_quest/authentication/components/my_outlined_text.dart';
import 'package:chrono_quest/authentication/components/my_text_field.dart';
import 'package:chrono_quest/authentication/controllers/auth_bloc.dart';
import 'package:chrono_quest/authentication/models/auth_event.dart';
import 'package:chrono_quest/authentication/models/auth_state.dart';
import 'package:chrono_quest/common/constants/colors.dart';
import 'package:chrono_quest/common/constants/numbers.dart';
import 'package:chrono_quest/common/util/screen_type.dart';
import 'package:chrono_quest/common/util/unfocus_on_tap.dart';
import 'package:chrono_quest/router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationView extends StatefulWidget {
  const AuthenticationView({super.key});

  @override
  State<AuthenticationView> createState() => _AuthenticationViewState();
}

class _AuthenticationViewState extends State<AuthenticationView> {
  final TextEditingController usernameCtl = TextEditingController();
  final TextEditingController passwordCtl = TextEditingController();

  void login(BuildContext context) {
    final String username = usernameCtl.text;
    final String password = passwordCtl.text;

    context.read<AuthBloc>().add(
          AuthEventLogin(
            username: username,
            password: password,
          ),
        );
  }

  void register(BuildContext context) {
    final String username = usernameCtl.text;
    final String password = passwordCtl.text;

    context.read<AuthBloc>().add(
          AuthEventRegister(
            username: username,
            password: password,
          ),
        );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final ScreenType screenType = switch (constraints.maxWidth) {
            < 600.0 => ScreenType.mobile,
            >= 600.0 && < 1200.0 => ScreenType.tablet,
            >= 1200.0 => ScreenType.desktop,
            _ => ScreenType.mobile,
          };
          return BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              String? snackbarMessage;

              switch (state) {
                case AuthStateUnauthenticated():
                case AuthStateLoading():
                  break;
                case AuthStateAuthenticated():
                  snackbarMessage = 'Authenticated ${state.user.username}';

                  context.read<MyRouter>().router.go('/agenda');

                case AuthStateErrorUsernameAlreadyExists():
                  snackbarMessage = state.message;
                case AuthStateErrorUnknown():
                  snackbarMessage = state.message;
                case AuthStateErrorWrongPassword():
                  snackbarMessage = state.message;
                case AuthStateErrorUserNotFound():
                  snackbarMessage = state.message;
              }

              if (snackbarMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    width: 300,
                    elevation: 1,
                    content: Center(
                      child: Text(
                        snackbarMessage,
                        style: const TextStyle(color: kWhite),
                      ),
                    ),
                    backgroundColor: kQuaternaryColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kBorderRadius * 6),
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              final bool shouldIgnorePointer =
                  state is AuthStateLoading || state is AuthStateAuthenticated;

              return IgnorePointer(
                ignoring: shouldIgnorePointer,
                child: Scaffold(
                  backgroundColor: kPrimaryColor,
                  body: UnfocusOnTap(
                    child: SafeArea(
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: kPadding * 2,
                          ),
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
                                  borderRadius:
                                      BorderRadius.circular(kBorderRadius),
                                  border: Border.all(
                                    color: kQuaternaryColor,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    MyTextField(
                                      controller: usernameCtl,
                                      onChanged: (value) {},
                                      label: 'Username',
                                    ),
                                    const SizedBox(height: kPadding),
                                    MyTextField(
                                      controller: passwordCtl,
                                      onChanged: (value) {},
                                      label: 'Password',
                                      obscureText: true,
                                    ),
                                    const SizedBox(height: 16),
                                    switch (shouldIgnorePointer) {
                                      true => const MyLoadingIndicator(),
                                      false => Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            MyElevatedButton(
                                              label: 'Login',
                                              backgroundColor: kSecondaryColor,
                                              onPressed: () => login(context),
                                            ),
                                            MyElevatedButton(
                                              label: 'Register',
                                              backgroundColor: kQuaternaryColor,
                                              onPressed: () =>
                                                  register(context),
                                            ),
                                          ],
                                        ),
                                    },
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
                ),
              );
            },
          );
        },
      );
}
