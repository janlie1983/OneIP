class MarketInsight {
  final String id;
  final String title;
  final String? titleEn;
  final String content;
  final String? contentEn;
  final String? category;
  final String? province;
  final DateTime publishedAt;
  final bool isPremium;

  const MarketInsight({
    required this.id,
    required this.title,
    this.titleEn,
    required this.content,
    this.contentEn,
    this.category,
    this.province,
    required this.publishedAt,
    this.isPremium = false,
  });

  factory MarketInsight.fromMap(Map<String, dynamic> map) {
    return MarketInsight(
      id: map['id'] as String,
      title: map['title'] as String,
      titleEn: map['title_en'] as String?,
      content: map['content'] as String,
      contentEn: map['content_en'] as String?,
      category: map['category'] as String?,
      province: map['province'] as String?,
      publishedAt: DateTime.parse(map['published_at'] as String),
      isPremium: map['is_premium'] as bool? ?? false,
    );
  }
}
