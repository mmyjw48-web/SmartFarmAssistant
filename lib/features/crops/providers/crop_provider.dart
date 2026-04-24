import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/crop_model.dart';
import '../../../core/services/gemini_service.dart';

// ── Crop Form State ────────────────────────────────────────────────────
class CropFormState {
  final SoilType? soilType;
  final Season? season;
  final String location;
  final String landSize;
  final bool isLoading;
  final String? errorMessage;
  final CropResult? result;

  const CropFormState({
    this.soilType,
    this.season,
    this.location = '',
    this.landSize = '',
    this.isLoading = false,
    this.errorMessage,
    this.result,
  });

  /// All required fields are filled
  bool get canAnalyze =>
      soilType != null &&
      season != null &&
      location.trim().isNotEmpty &&
      landSize.trim().isNotEmpty;

  CropFormState copyWith({
    SoilType? soilType,
    Season? season,
    String? location,
    String? landSize,
    bool? isLoading,
    String? errorMessage,
    CropResult? result,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return CropFormState(
      soilType: soilType ?? this.soilType,
      season: season ?? this.season,
      location: location ?? this.location,
      landSize: landSize ?? this.landSize,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      result: clearResult ? null : (result ?? this.result),
    );
  }
}

// ── Crop Notifier ──────────────────────────────────────────────────────
class CropNotifier extends StateNotifier<CropFormState> {
  CropNotifier() : super(const CropFormState());

  void selectSoil(SoilType soil) =>
      state = state.copyWith(soilType: soil);

  void selectSeason(Season season) =>
      state = state.copyWith(season: season);

  void setLocation(String value) =>
      state = state.copyWith(location: value);

  void setLandSize(String value) =>
      state = state.copyWith(landSize: value);

  Future<CropResult?> analyze() async {
    if (!state.canAnalyze) return null;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final rawResult = await GeminiService.recommendCrops(
        soilType: state.soilType!.label,
        season: state.season!.label,
        location: state.location.trim(),
        landSize: state.landSize.trim(),
      );

      final result = CropResult.fromAiResponse(rawResult);
      state = state.copyWith(isLoading: false, result: result);
      return result;
    } catch (e) {
      final fallback = CropResult.error();
      state = state.copyWith(
        isLoading: false,
        result: fallback,
        errorMessage: 'AI service unavailable. Showing general guidance.',
      );
      return fallback;
    }
  }

  void reset() => state = const CropFormState();
}

// ── Provider ───────────────────────────────────────────────────────────
final cropProvider = StateNotifierProvider<CropNotifier, CropFormState>(
  (ref) => CropNotifier(),
);
