import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/livestock_model.dart';
import '../../../core/services/gemini_service.dart';

// ── Livestock Form State ───────────────────────────────────────────────
class LivestockFormState {
  final AnimalType? selectedAnimal;
  final List<Symptom> selectedSymptoms;
  final AgeRange? selectedAge;
  final SymptomOnset? selectedOnset;
  final bool isLoading;
  final String? errorMessage;
  final DiagnosisResult? result;

  const LivestockFormState({
    this.selectedAnimal,
    this.selectedSymptoms = const [],
    this.selectedAge,
    this.selectedOnset,
    this.isLoading = false,
    this.errorMessage,
    this.result,
  });

  bool get canAnalyze =>
      selectedAnimal != null &&
      selectedSymptoms.isNotEmpty &&
      selectedAge != null &&
      selectedOnset != null;

  LivestockFormState copyWith({
    AnimalType? selectedAnimal,
    List<Symptom>? selectedSymptoms,
    AgeRange? selectedAge,
    SymptomOnset? selectedOnset,
    bool? isLoading,
    String? errorMessage,
    DiagnosisResult? result,
    bool clearError = false,
    bool clearResult = false,
  }) {
    return LivestockFormState(
      selectedAnimal: selectedAnimal ?? this.selectedAnimal,
      selectedSymptoms: selectedSymptoms ?? this.selectedSymptoms,
      selectedAge: selectedAge ?? this.selectedAge,
      selectedOnset: selectedOnset ?? this.selectedOnset,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      result: clearResult ? null : (result ?? this.result),
    );
  }
}

// ── Livestock Notifier ─────────────────────────────────────────────────
class LivestockNotifier extends StateNotifier<LivestockFormState> {
  LivestockNotifier() : super(const LivestockFormState());

  void selectAnimal(AnimalType animal) {
    state = state.copyWith(
      selectedAnimal: animal,
      // Reset symptoms when animal changes
      selectedSymptoms: [],
    );
  }

  void toggleSymptom(Symptom symptom) {
    final current = List<Symptom>.from(state.selectedSymptoms);
    if (current.contains(symptom)) {
      current.remove(symptom);
    } else {
      current.add(symptom);
    }
    state = state.copyWith(selectedSymptoms: current);
  }

  void selectAge(AgeRange age) {
    state = state.copyWith(selectedAge: age);
  }

  void selectOnset(SymptomOnset onset) {
    state = state.copyWith(selectedOnset: onset);
  }

  Future<DiagnosisResult?> analyze() async {
    if (!state.canAnalyze) return null;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final input = LivestockInput(
        animalType: state.selectedAnimal!,
        symptoms: state.selectedSymptoms,
        ageRange: state.selectedAge!,
        onset: state.selectedOnset!,
      );

      final rawResult = await GeminiService.diagnoseLivestock(input);
      final result = DiagnosisResult.fromAiResponse(rawResult);

      state = state.copyWith(isLoading: false, result: result);
      return result;
    } catch (e) {
      final fallback = DiagnosisResult.error();
      state = state.copyWith(
        isLoading: false,
        result: fallback,
        errorMessage: 'AI service unavailable. Showing general guidance.',
      );
      return fallback;
    }
  }

  void reset() {
    state = const LivestockFormState();
  }
}

// ── Provider ───────────────────────────────────────────────────────────
final livestockProvider =
    StateNotifierProvider<LivestockNotifier, LivestockFormState>(
  (ref) => LivestockNotifier(),
);
