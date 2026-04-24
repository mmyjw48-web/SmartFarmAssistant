/// Represents one slide in the onboarding PageView.
class OnboardingData {
  final String title;
  final List<String> bulletPoints;
  final String? bodyText;  // used on slide 3 (no bullets)
  final String imagePath;  // illustration asset

  const OnboardingData({
    required this.title,
    this.bulletPoints = const [],
    this.bodyText,
    required this.imagePath,
  });
}
