import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/home_screen.dart';
import 'widgets/banner_ad_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Google Mobile Ads is supported on Android/iOS, not Flutter Web.
  // Keep the Home screen banner ad, but remove the Watch Ad button.
  if (!kIsWeb) {
    await MobileAds.instance.initialize();
  }

  runApp(const QRApplication());
}

class QRApplication extends StatelessWidget {
  const QRApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'QR Application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Column(
          children: [
            const Expanded(child: HomeScreen()),
            if (!kIsWeb) const BannerAdWidget(),
          ],
        ),
      ),
    );
  }
}
