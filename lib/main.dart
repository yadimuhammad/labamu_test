import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:labamu_test/features/product/presentation/bloc/product_bloc.dart';
import 'core/injection/app_injection.dart' as di;
import 'core/routes/app_router.dart';
import 'observer.dart';

void main() async {
  await Hive.initFlutter();

  await di.init();

  Bloc.observer = MyObserver();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => di.sl<ProductBloc>())],
      child: MaterialApp.router(
        title: 'Labamu Test',
        theme: ThemeData(primarySwatch: Colors.blue),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
