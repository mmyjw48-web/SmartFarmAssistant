import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../features/livestock/widgets/livestock_widgets.dart';
import '../models/crop_model.dart';
import '../providers/crop_provider.dart';
import '../widgets/crop_widgets.dart';

class CropInputScreen extends ConsumerStatefulWidget {
  const CropInputScreen({super.key});

  @override
  ConsumerState<CropInputScreen> createState() => _CropInputScreenState();
}

class _CropInputScreenState extends ConsumerState<CropInputScreen> {
  final _locationCtrl = TextEditingController();
  final _landSizeCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _locationCtrl.dispose();
    _landSizeCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleAnalyze() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final result = await ref.read(cropProvider.notifier).analyze();
    if (result != null && mounted) {
      context.push(
        AppRoutes.cropResult,
        extra: {
          'crops': result.crops
              .map((c) => {
                    'name': c.name,
                    'suitability': c.suitability.name,
                    'reason': c.reason,
                    'tips': c.tips,
                  })
              .toList(),
          'general_advice': result.generalAdvice,
          'risks': result.risks,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cropProvider);

    // Show error if any
    ref.listen(cropProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    });

    return LoadingOverlay(
      isLoading: state.isLoading,
      message: 'Finding best crops for your farm...',
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBg,
        appBar: AppBar(
          title: const Text(AppStrings.cropsTitle),
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () {
              ref.read(cropProvider.notifier).reset();
              if (context.canPop()) context.pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(cropProvider.notifier).reset();
                _locationCtrl.clear();
                _landSizeCtrl.clear();
              },
              child: const Text(
                'Reset',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Subtitle ──────────────────────────────────
                Text(
                  AppStrings.cropsSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),

                const SizedBox(height: 24),

                // ── 1. Soil Type ───────────────────────────────
                SectionHeader(
                  title: AppStrings.soilType,
                  icon: Icons.layers_outlined,
                ),
                const SizedBox(height: 14),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: SoilType.values.length,
                  itemBuilder: (_, i) {
                    final soil = SoilType.values[i];
                    return SoilTypeCard(
                      soil: soil,
                      isSelected: state.soilType == soil,
                      onTap: () =>
                          ref.read(cropProvider.notifier).selectSoil(soil),
                    );
                  },
                ),

                const SizedBox(height: 28),

                // ── 2. Season ──────────────────────────────────
                SectionHeader(
                  title: AppStrings.season,
                  icon: Icons.wb_sunny_outlined,
                ),
                const SizedBox(height: 14),
                Column(
                  children: Season.values.map((season) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SeasonTile(
                        season: season,
                        isSelected: state.season == season,
                        onTap: () => ref
                            .read(cropProvider.notifier)
                            .selectSeason(season),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 28),

                // ── 3. Location ────────────────────────────────
                SectionHeader(
                  title: AppStrings.location,
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 14),
                LabeledInputField(
                  label: '',
                  hint: 'e.g. Central Java, Indonesia',
                  icon: Icons.location_on_outlined,
                  controller: _locationCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Please enter your location'
                      : null,
                  onChanged: (v) =>
                      ref.read(cropProvider.notifier).setLocation(v),
                ),

                const SizedBox(height: 24),

                // ── 4. Land Size ───────────────────────────────
                SectionHeader(
                  title: AppStrings.landSize,
                  icon: Icons.square_foot_outlined,
                ),
                const SizedBox(height: 14),
                LabeledInputField(
                  label: '',
                  hint: 'e.g. 2.5',
                  icon: Icons.crop_square_outlined,
                  controller: _landSizeCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter land size';
                    }
                    if (double.tryParse(v.trim()) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onChanged: (v) =>
                      ref.read(cropProvider.notifier).setLandSize(v),
                ),

                const SizedBox(height: 36),

                // ── 5. Get Advice Button ───────────────────────
                _GetAdviceButton(
                  canAnalyze: state.canAnalyze,
                  onPressed: _handleAnalyze,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Get Advice Button
// ─────────────────────────────────────────────────────────────────────────
class _GetAdviceButton extends StatelessWidget {
  final bool canAnalyze;
  final VoidCallback onPressed;

  const _GetAdviceButton(
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
                colors: [AppColors.teal, AppColors.primary],
              )
            : null,
        color: canAnalyze ? null : AppColors.grey200,
        boxShadow: canAnalyze
            ? [
                BoxShadow(
                  color: AppColors.teal.withOpacity(0.35),
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
        icon: const Icon(Icons.eco_outlined, size: 22),
        label: Text(
          AppStrings.getCropAdvice,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
