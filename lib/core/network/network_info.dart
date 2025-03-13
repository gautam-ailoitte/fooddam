import 'package:internet_connection_checker/internet_connection_checker.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}



 class NetworkInfoImpl implements NetworkInfo {
  final InternetConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected async {
    // For mock purposes, always return true to simulate connectivity
    // In a real app, this would check actual connectivity
    return true;
    // To use actual network checking, uncomment this line:
    // return await connectionChecker.hasConnection;
  }
}