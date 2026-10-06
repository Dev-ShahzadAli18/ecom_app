
class WelcomeData {
  final String image;
  final String title;
  final String subtitle;

  WelcomeData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

WelcomeData welcomeData = WelcomeData(
  image: "https://images.unsplash.com/photo-1483985988355-763728e1935b",
  title: "Welcome to GemStore!",
  subtitle: "The home for a fashionista",
);
