import 'package:flutter/material.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حول التطبيق')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_shipping, size: 80, color: Colors.teal),
            SizedBox(height: 16),
            Text('تطبيق التوصيل', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('الإصدار 1.0.0'),
            SizedBox(height: 24),
            Text('جميع الحقوق محفوظة © 2024'),
          ],
        ),
      ),
    );
  }
}
