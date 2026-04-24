// ── Animal Type ────────────────────────────────────────────────────────
enum AnimalType {
  sheep,
  cow,
  goat,
  hen;

  String get label {
    switch (this) {
      case AnimalType.sheep: return 'Sheep';
      case AnimalType.cow:   return 'Cow';
      case AnimalType.goat:  return 'Goat';
      case AnimalType.hen:   return 'Hen';
    }
  }

  String get emoji {
    switch (this) {
      case AnimalType.sheep: return '🐑';
      case AnimalType.cow:   return '🐄';
      case AnimalType.goat:  return '🐐';
      case AnimalType.hen:   return '🐔';
    }
  }
}

// ── Symptom ────────────────────────────────────────────────────────────
enum Symptom {
  fever,
  lossOfAppetite,
  diarrhea,
  cough,
  lethargy,
  weightLoss,
  skinLesions,
  nasalDischarge;

  String get label {
    switch (this) {
      case Symptom.fever:           return 'Fever';
      case Symptom.lossOfAppetite:  return 'Loss of Appetite';
      case Symptom.diarrhea:        return 'Diarrhea';
      case Symptom.cough:           return 'Cough';
      case Symptom.lethargy:        return 'Lethargy';
      case Symptom.weightLoss:      return 'Weight Loss';
      case Symptom.skinLesions:     return 'Skin Lesions';
      case Symptom.nasalDischarge:  return 'Nasal Discharge';
    }
  }
}

// ── Age Range ──────────────────────────────────────────────────────────
enum AgeRange {
  under1Year,
  under5Years,
  over5Years;

  String get label {
    switch (this) {
      case AgeRange.under1Year:  return 'Under 1 year';
      case AgeRange.under5Years: return 'Under 5 years';
      case AgeRange.over5Years:  return 'Over 5 years';
    }
  }
}

// ── Symptom Onset ──────────────────────────────────────────────────────
enum SymptomOnset {
  lessThan3Days,
  under1Week,
  overAWeek;

  String get label {
    switch (this) {
      case SymptomOnset.lessThan3Days: return 'Less than 3 days';
      case SymptomOnset.under1Week:    return 'Under 1 week';
      case SymptomOnset.overAWeek:     return 'Over a week';
    }
  }
}

// ── Risk Level ─────────────────────────────────────────────────────────
enum RiskLevel {
  low,
  medium,
  high,
  unknown;

  String get label {
    switch (this) {
      case RiskLevel.low:     return 'Low';
      case RiskLevel.medium:  return 'Medium';
      case RiskLevel.high:    return 'High';
      case RiskLevel.unknown: return 'Unknown';
    }
  }

  static RiskLevel fromString(String value) {
    final v = value.toLowerCase().trim();
    if (v.contains('high'))   return RiskLevel.high;
    if (v.contains('medium') || v.contains('moderate')) return RiskLevel.medium;
    if (v.contains('low'))    return RiskLevel.low;
    return RiskLevel.unknown;
  }
}

// ── Livestock Input (what the user fills in) ───────────────────────────
class LivestockInput {
  final AnimalType animalType;
  final List<Symptom> symptoms;
  final AgeRange ageRange;
  final SymptomOnset onset;

  const LivestockInput({
    required this.animalType,
    required this.symptoms,
    required this.ageRange,
    required this.onset,
  });
}

// ── Diagnosis Result (what AI returns) ────────────────────────────────
class DiagnosisResult {
  final String possibleCondition;
  final RiskLevel riskLevel;
  final List<String> recommendedActions;
  final String? additionalInfo;

  const DiagnosisResult({
    required this.possibleCondition,
    required this.riskLevel,
    required this.recommendedActions,
    this.additionalInfo,
  });

  /// Build from the raw AI text response
  factory DiagnosisResult.fromAiResponse(Map<String, dynamic> parsed) {
    return DiagnosisResult(
      possibleCondition: parsed['condition'] ?? 'Unable to determine',
      riskLevel: RiskLevel.fromString(parsed['risk'] ?? ''),
      recommendedActions: List<String>.from(parsed['actions'] ?? []),
      additionalInfo: parsed['info'],
    );
  }

  /// Fallback when AI fails
  factory DiagnosisResult.error() {
    return const DiagnosisResult(
      possibleCondition: 'Analysis unavailable',
      riskLevel: RiskLevel.unknown,
      recommendedActions: [
        'Please consult a local veterinarian.',
        'Monitor the animal closely.',
        'Isolate from other livestock as a precaution.',
      ],
    );
  }
}
