import 'package:ailoitte_components/ailoitte_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:guardian_bubble/config/injection_container.dart' as di;
import 'package:guardian_bubble/config/router/router.dart';
import 'package:guardian_bubble/core/util/app_constant.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

Future<void> main() async {
  // Load environment variables
  await dotenv.load(fileName: ".env/.env.dev");

  /// To initiazile Firebase Notication
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // await FirebaseApi().initNotification();

  /// Initializing Hive
  await Hive.initFlutter();
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  ); // To turn off landscape mode

  /// App Bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  await di.init();

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: AppConstant.appName,
      supportedLocales: const [
        Locale('en'),
      ],
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AiloitteMyLocalizationsDelegate(),
      ],
    );
  }
}
