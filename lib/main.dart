import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodam/core/bloc/bloc_observer.dart';
import 'package:foodam/core/route/app_router.dart';
import 'package:foodam/core/service/logger_service.dart';

// Make sure this is created

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize logger first for early debugging
  final logger = LoggerService();
  logger.setMinimumLogLevel(kDebugMode ? LogLevel.verbose : LogLevel.error);
  logger.i('Starting application initialization', tag: 'APP');
  
  try {
    // Initialize dependencies
   
    
    // Setup Bloc observer for debugging
    Bloc.observer = AppBlocObserver();
    
    logger.i('Application initialized successfully', tag: 'APP');
  } catch (e, stackTrace) {
    logger.e('Error during initialization', error: e, stackTrace: stackTrace, tag: 'APP');
  }
  
  // Run the app
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  final _routeObserver = RouteObserver<PageRoute>();

  MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        ],
      child: MaterialApp(
        title: 'Meal Subscription',
        theme: ThemeData(primarySwatch: Colors.orange),
        onGenerateRoute: 
        navigatorObservers: [_routeObserver], // Register route observer
        debugShowCheckedModeBanner: false,
        home: AppStartPage(), // Set the home page
      ),
    );
  }
}

class AppStartPage extends StatelessWidget {
  const AppStartPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }


}