import '../../../core/database/app_database.dart';
import 'farm_animal_model.dart';

class FarmAnimalDao {
  static const String tableName = 'farm_animals';

  Future<int> insertAnimal(FarmAnimal animal) async {
    final db = await AppDatabase.instance.database;
    return db.insert(tableName, animal.toMap());
  }

  Future<List<FarmAnimal>> getAnimals() async {
    final db = await AppDatabase.instance.database;

    final result = await db.query(
      tableName,
      orderBy: 'id DESC',
    );

    return result.map((map) => FarmAnimal.fromMap(map)).toList();
  }

  Future<int> updateAnimal(FarmAnimal animal) async {
    final db = await AppDatabase.instance.database;

    return db.update(
      tableName,
      animal.toMap(),
      where: 'id = ?',
      whereArgs: [animal.id],
    );
  }

  Future<int> deleteAnimal(int id) async {
    final db = await AppDatabase.instance.database;

    return db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateAnimalDiagnosis({
    required int animalId,
    required String riskLevel,
    required String diseaseType,
    required String diseaseDuration,
  }) async {
    final db = await AppDatabase.instance.database;

    return db.update(
      tableName,
      {
        'risk_level': riskLevel,
        'disease_type': diseaseType,
        'disease_duration': diseaseDuration,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [animalId],
    );
  }
}