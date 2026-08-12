/// Data model representing a single PlayStation game currently on sale.
class GameDeal {
  final String id;
  final String title;
  final double originalPrice;
  final double discountedPrice;
  final int discountPercentage;
  final String imageUrl;
  final String platform; // e.g. "PS5", "PS4"
  final bool isPsPlusBonus;
  final String description;

  const GameDeal({
    required this.id,
    required this.title,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercentage,
    required this.imageUrl,
    required this.platform,
    required this.isPsPlusBonus,
    this.description = '',
  });

  /// The amount saved in the same currency, useful for UI hints.
  double get savings => (originalPrice - discountedPrice).clamp(0, originalPrice);

  factory GameDeal.fromJson(Map<String, dynamic> json) => GameDeal(
        id: (json['id'] ?? json['title'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 0,
        discountedPrice: (json['discountedPrice'] as num?)?.toDouble() ?? 0,
        discountPercentage: (json['discountPercentage'] as num?)?.toInt() ?? 0,
        imageUrl: (json['imageUrl'] ?? '').toString(),
        platform: (json['platform'] ?? 'PS5').toString(),
        isPsPlusBonus: json['isPsPlusBonus'] as bool? ?? false,
        description: (json['description'] ?? '').toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'originalPrice': originalPrice,
        'discountedPrice': discountedPrice,
        'discountPercentage': discountPercentage,
        'imageUrl': imageUrl,
        'platform': platform,
        'isPsPlusBonus': isPsPlusBonus,
        'description': description,
      };
}
