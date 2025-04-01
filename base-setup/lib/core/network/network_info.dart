import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Abstract class to check if internet exists or not
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

/// Class to detect if internet connection exists
class NetworkInfoImpl implements NetworkInfo {
  final InternetConnection connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected => connectionChecker.hasInternetAccess;
}
