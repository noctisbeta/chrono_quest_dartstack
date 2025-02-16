import 'package:chrono_quest/authentication/components/authentication_form.dart';
import 'package:chrono_quest/authentication/controllers/auth_bloc.dart';
import 'package:chrono_quest/authentication/models/auth_state.dart';
import 'package:chrono_quest/common/components/my_outlined_text.dart';
import 'package:chrono_quest/common/constants/colors.dart';
import 'package:chrono_quest/common/constants/numbers.dart';
import 'package:chrono_quest/common/util/responsive_layout_builder.dart';
import 'package:chrono_quest/common/util/screen_type.dart';
import 'package:chrono_quest/common/util/unfocus_on_tap.dart';
import 'package:chrono_quest/router/router_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AuthenticationView extends StatelessWidget {
  const AuthenticationView({super.key});

  @override
  Widget build(BuildContext context) => ResponsiveLayoutBuilder(
    builder:
        (context, screenType) => BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthStateAuthenticated) {
              context.goNamed(RouterPath.agenda.name);
            }

            _maybeShowSnackbar(context, state);
          },
          builder: (context, state) {
            final bool isLoading = state is AuthStateLoading;

            return Scaffold(
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
                            fontSize: 48,
                            strokeWidth: 2,
                            foreground: kQuaternaryColor,
                            background: kBlack,
                          ),
                          const MyOutlinedText(
                            text: 'Sign in or register',
                            fontWeight: FontWeight.w400,
                            fontSize: 24,
                            strokeWidth: 1,
                            foreground: kQuaternaryColor,
                            background: kBlack,
                          ),
                          const SizedBox(height: kPadding * 2),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: switch (screenType) {
                                ScreenType.mobile => 300.0,
                                ScreenType.tablet => 400.0,
                                ScreenType.desktop => 400.0,
                              },
                            ),
                            child: AuthenticationForm(isLoading: isLoading),
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
        ),
  );

  void _maybeShowSnackbar(BuildContext context, AuthState state) {
    final String? snackbarMessage = switch (state) {
      AuthStateUnauthenticated() => null,
      AuthStateAuthenticated() => null,
      AuthStateLoading() => null,
      AuthStateErrorUsernameAlreadyExists() => 'Username already exists',
      AuthStateErrorUnknown() => 'An unknown error occurred',
      AuthStateErrorWrongPassword() => 'Wrong password',
      AuthStateErrorUserNotFound() => 'User not found',
    };

    if (snackbarMessage == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        width: 300,
        elevation: 1,
        content: Center(
          child: Text(snackbarMessage, style: const TextStyle(color: kWhite)),
        ),
        backgroundColor: kQuaternaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadius * 6),
        ),
      ),
    );
  }
}
