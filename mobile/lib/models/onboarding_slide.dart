class OnboardingSlide {
  final String title;
  final String description;
  final String image;
  final List<OnboardingFeature> features;

  const OnboardingSlide({
    required this.title,
    required this.description,
    required this.image,
    required this.features,
  });
}

class OnboardingFeature {
  final String icon;
  final String title;
  final String description;

  const OnboardingFeature({
    required this.icon,
    required this.title,
    required this.description,
  });
} 