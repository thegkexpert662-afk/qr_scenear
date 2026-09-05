import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../services/rewarded_ad_service.dart';
import '../widgets/banner_ad_widget.dart';

class AdHomeScreen extends StatelessWidget {
  const AdHomeScreen({super.key});

  void _showRewardedAd(BuildContext context) {
    if (!rewardedAdService.isReady) {
      rewardedAdService.load();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rewarded ad is loading. Please try again in a moment.'),
        ),
      );
      return;
    }

    rewardedAdService.show(
      onRewardEarned: () {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reward earned!'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Expanded(child: HomeScreen()),
          const BannerAdWidget(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRewardedAd(context),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Watch Ad'),
      ),
    );
  }
}
