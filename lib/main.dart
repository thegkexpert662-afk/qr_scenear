import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Google Mobile Ads is supported on Android/iOS, not Flutter Web.
  // The Home screen no longer displays the Watch Ad section.
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
      home: const HomeScreen(),
    );
  }
}
