import 'package:chrono_quest/agenda/components/my_app_bar.dart';
import 'package:chrono_quest/authentication/components/my_elevated_button.dart';
import 'package:chrono_quest/authentication/components/my_outlined_text.dart';
import 'package:chrono_quest/authentication/components/my_text_field.dart';
import 'package:chrono_quest/common/constants/colors.dart';
import 'package:chrono_quest/common/constants/numbers.dart';
import 'package:chrono_quest/encryption/encryption_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EncryptionView extends StatefulWidget {
  const EncryptionView({super.key});

  @override
  State<EncryptionView> createState() => _EncryptionViewState();
}

class _EncryptionViewState extends State<EncryptionView> {
  String passphrase = '';

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: kPrimaryColor,
        appBar: const MyAppBar(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(kPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.enhanced_encryption,
                  size: 150,
                  color: kBlack,
                ),
                const SizedBox(height: 20),
                const MyOutlinedText(
                  text: 'Your data will be encrypted before being sent to the '
                      'backend using your passcode. Make it different from '
                      'your '
                      'login password.',
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  background: kBlack,
                  foreground: kTernaryColor,
                  strokeWidth: 3,
                ),
                const SizedBox(height: kPadding * 4),
                Container(
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
                        label: 'Enter your passcode',
                        onChanged: (value) {
                          passphrase = value;
                        },
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      MyElevatedButton(
                        backgroundColor: kQuaternaryColor,
                        label: 'Save Passcode',
                        onPressed: () async {
                          void afterConfirmation() {}

                          await context
                              .read<EncryptionRepository>()
                              .confirmPassphrase(passphrase);

                          afterConfirmation.call();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
