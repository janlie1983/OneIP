import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: 'Gói dịch vụ'),
      body: Center(
        child: Text('Quản lý gói dịch vụ - Sắp ra mắt'),
      ),
    );
  }
}
