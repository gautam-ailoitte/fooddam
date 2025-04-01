import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../config/ailoitte_component_injector.dart';
import '../../../core/util/app_color.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColor.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
      child: component.scaffold(
        backgroundColor: AppColor.white,
        child: SizedBox.shrink(),
      ),
    );
  }
}
