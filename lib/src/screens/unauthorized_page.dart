import 'package:flutter/material.dart';

class UnauthorizedPage extends StatelessWidget {
  const UnauthorizedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Access Denied',
          style: TextStyle(fontSize: 24, color: Colors.red),
        ),
      ),
    );
  }
}
