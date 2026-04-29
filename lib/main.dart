// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:operationcore2/component/appcolor.dart';
import 'package:operationcore2/firebase_options.dart';
// import 'package:operationcore2/firebase_options.dart';
import 'package:operationcore2/navigation.dart';
import 'package:operationcore2/page/login.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await clearFirestoreCache();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // 3. Inisialisasi Window Manager
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    minimumSize: Size(1300, 800),
    center: true,
    title: "Operations Core",
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: MyApp()));
}

// Future<void> clearFirestoreCache() async {
//   try {
//     await FirebaseFirestore.instance.clearPersistence();
//     print("Firestore cache cleared successfully.");
//   } catch (e) {
//     print("Failed to clear Firestore cache: $e");
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      color: AppColors.primary,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/home', page: () => Navigation()),
        GetPage(name: '/login', page: () => Login()),
        // GetPage(name: '/navigation', page: () => Navigation()),
      ],
    );
    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   title: 'Flutter Demo',
    //   color: AppColors.primary,
    //   theme: ThemeData(
    //     colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    //   ),
    //   home: Login(),
    //   // home: Navigation(),
    // );
  }
}
