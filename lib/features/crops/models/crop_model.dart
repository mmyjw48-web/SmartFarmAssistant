// ── Soil Type ──────────────────────────────────────────────────────────
enum SoilType {
  clay,
  sandy,
  loamy,
  silty,
  peaty,
  chalky;

  String get label {
    switch (this) {
      case SoilType.clay:   return 'Clay';
      case SoilType.sandy:  return 'Sandy';
      case SoilType.loamy:  return 'Loamy';
      case SoilType.silty:  return 'Silty';
      case SoilType.peaty:  return 'Peaty';
      case SoilType.chalky: return 'Chalky';
    }
  }

  String get description {
    switch (this) {
      case SoilType.clay:   return 'Heavy, holds water well';
      case SoilType.sandy:  return 'Light, drains quickly';
      case SoilType.loamy:  return 'Balanced, ideal for most crops';
      case SoilType.silty:  return 'Fertile, holds moisture';
      case SoilType.peaty:  return 'Rich in organic matter';
      case SoilType.chalky: return 'Alkaline, free draining';
    }
  }

  String get emoji {
    switch (this) {
      case SoilType.clay:   return '🟫';
      case SoilType.sandy:  return '🏖️';
      case SoilType.loamy:  return '🌱';
      case SoilType.silty:  return '💧';
      case SoilType.peaty:  return '🍂';
      case SoilType.chalky: return '⚪';
    }
  }
}

// ── Season ────────────────────────────────────────────────────────────
enum Season {
  drySeasonHot,
  drySeasonCool,
  wetSeason,
  transition;

  String get label {
    switch (this) {
      case Season.drySeasonHot:  return 'Dry Season (Hot)';
      case Season.drySeasonCool: return 'Dry Season (Cool)';
      case Season.wetSeason:     return 'Wet / Rainy Season';
      case Season.transition:    return 'Transition Season';
    }
  }

  String get emoji {
    switch (this) {
      case Season.drySeasonHot:  return '☀️';
      case Season.drySeasonCool: return '🌤️';
      case Season.wetSeason:     return '🌧️';
      case Season.transition:    return '🌦️';
    }
  }
}

// ── Suitability ────────────────────────────────────────────────────────
enum Suitability {
  high,
  medium,
  low;

  static Suitability fromString(String value) {
    final v = value.toLowerCase().trim();
    if (v.contains('high'))   return Suitability.high;
    if (v.contains('medium')) return Suitability.medium;
    return Suitability.low;
  }
}

// ── Crop Input ─────────────────────────────────────────────────────────
class CropInput {
  final SoilType soilType;
  final Season season;
  final String location;
  final String landSize;

  const CropInput({
    required this.soilType,
    required this.season,
    required this.location,
    required this.landSize,
  });
}

// ── Single Crop Recommendation ─────────────────────────────────────────
class CropRecommendation {
  final String name;
  final Suitability suitability;
  final String reason;
  final String tips;

  const CropRecommendation({
    required this.name,
    required this.suitability,
    required this.reason,
    required this.tips,
  });

  factory CropRecommendation.fromMap(Map<String, dynamic> map) {
    return CropRecommendation(
      name: map['name'] as String? ?? 'Unknown',
      suitability: Suitability.fromString(map['suitability'] as String? ?? ''),
      reason: map['reason'] as String? ?? '',
      tips: map['tips'] as String? ?? '',
    );
  }
}

// ── Full Crop Result ───────────────────────────────────────────────────
class CropResult {
  final List<CropRecommendation> crops;
  final String generalAdvice;
  final String risks;

  const CropResult({
    required this.crops,
    required this.generalAdvice,
    required this.risks,
  });

  factory CropResult.fromAiResponse(Map<String, dynamic> parsed) {
    final cropList = (parsed['crops'] as List<dynamic>? ?? [])
        .map((c) => CropRecommendation.fromMap(c as Map<String, dynamic>))
        .toList();

    return CropResult(
      crops: cropList,
      generalAdvice: parsed['general_advice'] as String? ?? '',
      risks: parsed['risks'] as String? ?? '',
    );
  }

  factory CropResult.error() {
    return const CropResult(
      crops: [],
      generalAdvice: 'Please consult a local agricultural officer for advice.',
      risks: 'Unable to assess risks. Check soil moisture and local weather.',
    );
  }
}
