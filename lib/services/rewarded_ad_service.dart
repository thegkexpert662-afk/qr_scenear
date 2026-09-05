import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdService {
  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  static const String _testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  void load() {
    if (_rewardedAd != null || _isLoading) return;

    _isLoading = true;

    RewardedAd.load(
      adUnitId: _testRewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoading = false;
          _rewardedAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _rewardedAd = null;
              load();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _rewardedAd = null;
              load();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          _rewardedAd = null;
        },
      ),
    );
  }

  bool get isReady => _rewardedAd != null;

  void show({required void Function() onRewardEarned}) {
    final ad = _rewardedAd;
    if (ad == null) {
      load();
      return;
    }

    _rewardedAd = null;

    ad.show(
      onUserEarnedReward: (ad, reward) {
        onRewardEarned();
      },
    );
  }

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
