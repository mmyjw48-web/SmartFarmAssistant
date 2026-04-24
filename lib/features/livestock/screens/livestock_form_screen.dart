import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../models/livestock_model.dart';
import '../providers/livestock_provider.dart';
import '../widgets/livestock_widgets.dart';

class LivestockFormScreen extends ConsumerWidget {
  const LivestockFormScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(livestockProvider);

    return LoadingOverlay(
      isLoading: state.isLoading,
      message: 'Analyzing condition with AI...',
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          title: const Text(AppStrings.livestockTitle),
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () {
              ref.read(livestockProvider.notifier).reset();
              if (context.canPop()) context.pop();
            },
          ),
          actions: [
            // Reset button
            TextButton(
              onPressed: () => ref.read(livestockProvider.notifier).reset(),
              child: const Text(
                'Reset',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Animal Type ─────────────────────────────────
              const SectionHeader(
                title: AppStrings.animalType,
                icon: Icons.pets_outlined,
              ),
              const SizedBox(height: 14),
              _AnimalGrid(
                selected: state.selectedAnimal,
                onSelect: (a) =>
                    ref.read(livestockProvider.notifier).selectAnimal(a),
              ),

              const SizedBox(height: 28),

              // ── 2. Symptoms ────────────────────────────────────
              const SectionHeader(
                title: AppStrings.selectSymptoms,
                icon: Icons.medical_services_outlined,
              ),
              const SizedBox(height: 14),
              _SymptomsGrid(
                selected: state.selectedSymptoms,
                onToggle: (s) =>
                    ref.read(livestockProvider.notifier).toggleSymptom(s),
              ),

              const SizedBox(height: 28),

              // ── 3. Age & Onset ─────────────────────────────────
              const SectionHeader(
                title: 'Animal Details',
                icon: Icons.info_outline,
              ),
              const SizedBox(height: 14),

              OptionSelectorField(
                label: AppStrings.dateOfBirth,
                selectedValue: state.selectedAge?.label,
                options: AgeRange.values.map((a) => a.label).toList(),
                onSelected: (val) {
                  final age = AgeRange.values.firstWhere(
                      (a) => a.label == val);
                  ref.read(livestockProvider.notifier).selectAge(age);
                },
              ),
              const SizedBox(height: 12),
              OptionSelectorField(
                label: AppStrings.symptomOnset,
                selectedValue: state.selectedOnset?.label,
                options: SymptomOnset.values.map((o) => o.label).toList(),
                onSelected: (val) {
                  final onset = SymptomOnset.values.firstWhere(
                      (o) => o.label == val);
                  ref.read(livestockProvider.notifier).selectOnset(onset);
                },
              ),

              const SizedBox(height: 36),

              // ── 4. Analyze Button ──────────────────────────────
              _AnalyzeButton(
                canAnalyze: state.canAnalyze,
                onPressed: () => _handleAnalyze(context, ref),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAnalyze(
      BuildContext context, WidgetRef ref) async {
    final result =
        await ref.read(livestockProvider.notifier).analyze();

    if (result != null && context.mounted) {
      context.push(
        AppRoutes.diagnosisResult,
        extra: {
          'condition': result.possibleCondition,
          'risk': result.riskLevel.label,
          'actions': result.recommendedActions,
          'info': result.additionalInfo,
        },
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Animal Grid (2x2)
// ─────────────────────────────────────────────────────────────────────────
class _AnimalGrid extends StatelessWidget {
  final AnimalType? selected;
  final void Function(AnimalType) onSelect;

  const _AnimalGrid({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: AnimalType.values.length,
      itemBuilder: (_, i) {
        final animal = AnimalType.values[i];
        return AnimalSelectorCard(
          animal: animal,
          isSelected: selected == animal,
          onTap: () => onSelect(animal),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Symptoms Grid (2 columns)
// ─────────────────────────────────────────────────────────────────────────
class _SymptomsGrid extends StatelessWidget {
  final List<Symptom> selected;
  final void Function(Symptom) onToggle;

  const _SymptomsGrid({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 3.2,
      ),
      itemCount: Symptom.values.length,
      itemBuilder: (_, i) {
        final symptom = Symptom.values[i];
        return SymptomCheckboxTile(
          symptom: symptom,
          isSelected: selected.contains(symptom),
          onToggle: () => onToggle(symptom),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Analyze Button with disabled state
// ─────────────────────────────────────────────────────────────────────────
class _AnalyzeButton extends StatelessWidget {
  final bool canAnalyze;
  final VoidCallback onPressed;

  const _AnalyzeButton(
      {required this.canAnalyze, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: canAnalyze
            ? const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight])
            : null,
        color: canAnalyze ? null : AppColors.grey200,
        boxShadow: canAnalyze
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                )
              ]
            : [],
      ),
      child: ElevatedButton.icon(
        onPressed: canAnalyze ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor:
              canAnalyze ? AppColors.white : AppColors.grey400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        icon: const Icon(Icons.psychology_outlined, size: 22),
        label: Text(
          AppStrings.analyzeCondition,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
