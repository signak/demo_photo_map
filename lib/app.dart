import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'presentation/theme/app_theme.dart';
import 'route/router_provider.dart';

// TODO [低] 全体的に例外対応をもうちょっとまともにやる
// TODO [低] オプション画面を作ってタイル切り替えできるようにする

class MyApp extends HookConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const String title = 'Photo Sharing Web App [DEMO]';
    final router = ref.read(myRouterProvider);

    return ScreenUtilInit(
      // designSize: const Size(390, 844), // iPhone 13
      // designSize: const Size(360, 512), // Xperia XZ Premium
      // designSize: const Size(601, 794), // MediaPad M5 lite
      designSize: const Size(672, 906), // yoga tab
      builder: (context, child) => MaterialApp.router(
        title: title,
        theme: AppTheme.defaultTheme(context),
        darkTheme: AppTheme.darkTheme(context),
        routerConfig: router,
        // useInheritedMediaQuery: true,
        scrollBehavior: MyCustomScrollBehavior(),
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
