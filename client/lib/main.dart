import 'package:chrono_quest/router/my_router.dart';
import 'package:chrono_quest/url_strategy/url_strategy_import.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  dummyFunctionForUrlPathStrategy();

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routerConfig: context.read<MyRouter>().router,
        title: 'Chrono Quest',
      );
}
