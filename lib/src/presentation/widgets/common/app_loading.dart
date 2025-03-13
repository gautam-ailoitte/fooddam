import 'package:flutter/material.dart';

class AppLoading extends StatelessWidget {
  final String? message;
  final Color color;

  const AppLoading({
    super.key,
    this.message,
    this.color = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          if (message != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                message!,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
