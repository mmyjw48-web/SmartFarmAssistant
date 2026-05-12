import 'package:flutter/material.dart';

import '../data/farm_animal_dao.dart';
import '../data/farm_animal_model.dart';

class AddEditFarmAnimalScreen extends StatefulWidget {
  final FarmAnimal? animal;

  const AddEditFarmAnimalScreen({
    super.key,
    this.animal,
  });

  @override
  State<AddEditFarmAnimalScreen> createState() =>
      _AddEditFarmAnimalScreenState();
}

class _AddEditFarmAnimalScreenState extends State<AddEditFarmAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  final FarmAnimalDao _animalDao = FarmAnimalDao();

  late TextEditingController _nameController;
  late TextEditingController _diseaseTypeController;

  String _selectedType = 'Sheep';
  String _selectedAge = 'Under 1 year';
  String _selectedRiskLevel = 'Unknown';
  String _selectedDiseaseDuration = 'Unknown';

  bool get isEditing => widget.animal != null;

  final List<String> animalTypes = [
    'Sheep',
    'Cow',
    'Goat',
    'Hen',
  ];

  final List<String> ages = [
    'Under 1 year',
    '1 - 3 years',
    'More than 3 years',
  ];

  final List<String> riskLevels = [
    'Unknown',
    'Low',
    'Medium',
    'High',
  ];

  final List<String> diseaseDurations = [
    'Unknown',
    'Less than 3 days',
    '3 - 7 days',
    'More than 7 days',
  ];

  @override
  void initState() {
    super.initState();

    final animal = widget.animal;

    _nameController = TextEditingController(text: animal?.name ?? '');
    _diseaseTypeController = TextEditingController(
      text: animal?.diseaseType == 'Not diagnosed'
          ? ''
          : animal?.diseaseType ?? '',
    );

    _selectedType = animal?.type ?? 'Sheep';
    _selectedAge = animal?.age ?? 'Under 1 year';
    _selectedRiskLevel = animal?.riskLevel ?? 'Unknown';
    _selectedDiseaseDuration = animal?.diseaseDuration ?? 'Unknown';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _diseaseTypeController.dispose();
    super.dispose();
  }

  Future<void> _saveAnimal() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now().toIso8601String();

    final animal = FarmAnimal(
      id: widget.animal?.id,
      name: _nameController.text.trim(),
      type: _selectedType,
      age: _selectedAge,
      riskLevel: _selectedRiskLevel,
      diseaseType: _diseaseTypeController.text.trim().isEmpty
          ? 'Not diagnosed'
          : _diseaseTypeController.text.trim(),
      diseaseDuration: _selectedDiseaseDuration,
      createdAt: widget.animal?.createdAt ?? now,
      updatedAt: now,
    );

    if (isEditing) {
      await _animalDao.updateAnimal(animal);
    } else {
      await _animalDao.insertAnimal(animal);
    }

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F3),
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Animal' : 'Add Animal'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Animal Name',
                      prefixIcon: Icon(Icons.label_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter animal name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Animal Type',
                      prefixIcon: Icon(Icons.pets),
                      border: OutlineInputBorder(),
                    ),
                    items: animalTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedType = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedAge,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      prefixIcon: Icon(Icons.calendar_month_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: ages.map((age) {
                      return DropdownMenuItem(
                        value: age,
                        child: Text(age),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedAge = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedRiskLevel,
                    decoration: const InputDecoration(
                      labelText: 'Risk Level',
                      prefixIcon: Icon(Icons.warning_amber_rounded),
                      border: OutlineInputBorder(),
                    ),
                    items: riskLevels.map((risk) {
                      return DropdownMenuItem(
                        value: risk,
                        child: Text(risk),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedRiskLevel = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _diseaseTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Disease Type',
                      hintText: 'Example: Bacterial Pneumonia',
                      prefixIcon: Icon(Icons.medical_information_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedDiseaseDuration,
                    decoration: const InputDecoration(
                      labelText: 'Disease Duration',
                      prefixIcon: Icon(Icons.timer_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: diseaseDurations.map((duration) {
                      return DropdownMenuItem(
                        value: duration,
                        child: Text(duration),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedDiseaseDuration = value;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3D7A4B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: _saveAnimal,
                      icon: const Icon(Icons.save),
                      label: Text(
                        isEditing ? 'Update Animal' : 'Save Animal',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}