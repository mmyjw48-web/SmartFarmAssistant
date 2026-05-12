import 'package:flutter/material.dart';

import '../data/farm_animal_dao.dart';
import '../data/farm_animal_model.dart';
import 'add_edit_farm_animal_screen.dart';

class FarmAnimalsScreen extends StatefulWidget {
  const FarmAnimalsScreen({super.key});

  @override
  State<FarmAnimalsScreen> createState() => _FarmAnimalsScreenState();
}

class _FarmAnimalsScreenState extends State<FarmAnimalsScreen> {
  final FarmAnimalDao _animalDao = FarmAnimalDao();

  Future<List<FarmAnimal>> _loadAnimals() {
    return _animalDao.getAnimals();
  }

  Future<void> _openAddScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditFarmAnimalScreen(),
      ),
    );

    if (result == true) {
      setState(() {});
    }
  }

  Future<void> _openEditScreen(FarmAnimal animal) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditFarmAnimalScreen(animal: animal),
      ),
    );

    if (result == true) {
      setState(() {});
    }
  }

  Future<void> _deleteAnimal(FarmAnimal animal) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Animal'),
          content: Text('Are you sure you want to delete ${animal.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await _animalDao.deleteAnimal(animal.id!);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Animal deleted successfully'),
      ),
    );

    setState(() {});
  }

  Color _riskColor(String riskLevel) {
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

  Widget _riskBadge(String riskLevel) {
    final color = _riskColor(riskLevel);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

  Widget _animalCard(FarmAnimal animal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFE7F3EA),
                  child: Icon(
                    Icons.pets,
                    color: const Color(0xFF3D7A4B),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        animal.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${animal.type} • ${animal.age}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                _riskBadge(animal.riskLevel),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),

            Row(
              children: [
                const Icon(
                  Icons.medical_information_outlined,
                  size: 20,
                  color: Color(0xFF3D7A4B),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Disease: ${animal.diseaseType}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 20,
                  color: Color(0xFF3D7A4B),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Duration: ${animal.diseaseDuration}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _openEditScreen(animal),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deleteAnimal(animal),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F3),
      appBar: AppBar(
        title: const Text('Registered Animals'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF3D7A4B),
        foregroundColor: Colors.white,
        onPressed: _openAddScreen,
        icon: const Icon(Icons.add),
        label: const Text('Add Animal'),
      ),
      body: FutureBuilder<List<FarmAnimal>>(
        future: _loadAnimals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final animals = snapshot.data ?? [];

          if (animals.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pets,
                      size: 72,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No animals registered yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap Add Animal to store livestock data using SQLite.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: animals.length,
            itemBuilder: (context, index) {
              return _animalCard(animals[index]);
            },
          );
        },
      ),
    );
  }
}