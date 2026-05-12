import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_farm_assistant/features/farm_animals/screens/farm_animals_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../models/livestock_model.dart';
import '../providers/livestock_provider.dart';
import '../widgets/livestock_widgets.dart';

import 'package:smart_farm_assistant/features/farm_animals/data/farm_animal_dao.dart';
import 'package:smart_farm_assistant/features/farm_animals/data/farm_animal_model.dart';
import 'package:smart_farm_assistant/features/farm_animals/screens/farm_animals_screen.dart';

class LivestockFormScreen extends ConsumerStatefulWidget {
  const LivestockFormScreen({super.key});

  @override
  ConsumerState<LivestockFormScreen> createState() =>
      _LivestockFormScreenState();
}

class _LivestockFormScreenState extends ConsumerState<LivestockFormScreen> {
  final FarmAnimalDao _farmAnimalDao = FarmAnimalDao();

  FarmAnimal? _selectedFarmAnimal;

  @override
  Widget build(BuildContext context) {
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
            IconButton(
              tooltip: 'Registered Animals',
              icon: const Icon(
                Icons.pets,
                color: AppColors.primary,
              ),
              onPressed: _showRegisteredAnimalsSheet,
            ),
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
              if (_selectedFarmAnimal != null) ...[
                _SelectedFarmAnimalCard(
                  animal: _selectedFarmAnimal!,
                  onClear: () {
                    setState(() {
                      _selectedFarmAnimal = null;
                    });
                  },
                ),
                const SizedBox(height: 20),
              ],
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
                  final age = AgeRange.values.firstWhere((a) => a.label == val);
                  ref.read(livestockProvider.notifier).selectAge(age);
                },
              ),
              const SizedBox(height: 12),
              OptionSelectorField(
                label: AppStrings.symptomOnset,
                selectedValue: state.selectedOnset?.label,
                options: SymptomOnset.values.map((o) => o.label).toList(),
                onSelected: (val) {
                  final onset =
                      SymptomOnset.values.firstWhere((o) => o.label == val);
                  ref.read(livestockProvider.notifier).selectOnset(onset);
                },
              ),

              const SizedBox(height: 36),

              // ── 4. Analyze Button ──────────────────────────────
              _AnalyzeButton(
                canAnalyze: state.canAnalyze,
                onPressed: () => _handleAnalyze(context),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showRegisteredAnimalsSheet() async {
    try {
      final animals = await _farmAnimalDao.getAnimals();

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        builder: (context) {
          if (animals.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.pets,
                    size: 48,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No registered animals yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add animals first from Registered Animals screen.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FarmAnimalsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Manage Animals'),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: animals.length + 1,
              itemBuilder: (context, index) {
                if (index == animals.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FarmAnimalsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings),
                      label: const Text('Manage Registered Animals'),
                    ),
                  );
                }

                final animal = animals[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE7F3EA),
                      child: Icon(
                        Icons.pets,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      animal.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${animal.type} • ${animal.age}\n'
                      'Disease: ${animal.diseaseType}\n'
                      'Duration: ${animal.diseaseDuration}',
                    ),
                    isThreeLine: true,
                    trailing: _RiskBadge(riskLevel: animal.riskLevel),
                    onTap: () {
                      setState(() {
                        _selectedFarmAnimal = animal;
                      });

                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load animals: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleAnalyze(BuildContext context) async {
    final currentState = ref.read(livestockProvider);

    final result = await ref.read(livestockProvider.notifier).analyze();

    if (result != null && context.mounted) {
      if (_selectedFarmAnimal != null) {
        final updatedAnimal = _selectedFarmAnimal!.copyWith(
          riskLevel: result.riskLevel.label,
          diseaseType: result.possibleCondition,
          diseaseDuration: currentState.selectedOnset?.label ?? 'Unknown',
          updatedAt: DateTime.now().toIso8601String(),
        );

        await _farmAnimalDao.updateAnimal(updatedAnimal);

        if (mounted) {
          setState(() {
            _selectedFarmAnimal = updatedAnimal;
          });
        }
      }

      if (!context.mounted) return;

      context.push(
        AppRoutes.diagnosisResult,
        extra: result,
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

  const _AnalyzeButton({required this.canAnalyze, required this.onPressed});

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
          foregroundColor: canAnalyze ? AppColors.white : AppColors.grey400,
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

class _SelectedFarmAnimalCard extends StatelessWidget {
  final FarmAnimal animal;
  final VoidCallback onClear;

  const _SelectedFarmAnimalCard({
    required this.animal,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.35),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFE7F3EA),
            child: Icon(
              Icons.pets,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selected Registered Animal',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  animal.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text('${animal.type} • ${animal.age}'),
                Text('Disease: ${animal.diseaseType}'),
                Text('Duration: ${animal.diseaseDuration}'),
              ],
            ),
          ),
          Column(
            children: [
              _RiskBadge(riskLevel: animal.riskLevel),
              IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  final String riskLevel;

  const _RiskBadge({
    required this.riskLevel,
  });

  Color get color {
    switch (riskLevel.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        riskLevel,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
