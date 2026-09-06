import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../widgets/banner_ad_widget.dart';

class AdHomeScreen extends StatelessWidget {
  const AdHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Expanded(child: HomeScreen()),
          const BannerAdWidget(),
        ],
      ),
    );
  }
}
