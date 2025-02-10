import 'package:chrono_quest/authentication/controllers/auth_bloc.dart';
import 'package:chrono_quest/authentication/models/auth_event.dart';
import 'package:chrono_quest/common/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({
    this.leading,
    super.key,
  });

  final Widget? leading;

  @override
  Widget build(BuildContext context) => AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: kPrimaryColor,
        title: const Text('ChronoQuest'),
        leading: leading,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthEventLogout());
            },
          ),
        ],
      );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
