import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/screens/mock_user_entity.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _databaseName = 'healthai.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _usersTable = 'users';
  static const String _healthEntriesTable = 'health_entries';

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createTables,
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE $_usersTable (
        uid TEXT PRIMARY KEY,
        email TEXT UNIQUE NOT NULL,
        name TEXT,
        age INTEGER,
        created_at TEXT NOT NULL
      )
    ''');

    // Health entries table
    await db.execute('''
      CREATE TABLE $_healthEntriesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_uid TEXT NOT NULL,
        date TEXT NOT NULL,
        systolic INTEGER NOT NULL,
        diastolic INTEGER NOT NULL,
        blood_sugar INTEGER NOT NULL,
        age INTEGER NOT NULL,
        notes TEXT,
        predicted_risk_level INTEGER,
        confidence REAL,
        risk_category TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_uid) REFERENCES $_usersTable (uid)
      )
    ''');
  }

  // User operations
  static Future<void> insertUser(MockUser user) async {
    final db = await database;
    await db.insert(
      _usersTable,
      {
        'uid': user.uid,
        'email': user.email,
        'name': user.name,
        'age': user.age,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<MockUser?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _usersTable,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return MockUser(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      age: map['age'],
    );
  }

  static Future<MockUser?> getUserByUid(String uid) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _usersTable,
      where: 'uid = ?',
      whereArgs: [uid],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    return MockUser(
      uid: map['uid'],
      email: map['email'],
      name: map['name'],
      age: map['age'],
    );
  }

  // Health entries operations
  static Future<int> insertHealthEntry(String userUid, HealthEntry entry) async {
    final db = await database;
    return await db.insert(
      _healthEntriesTable,
      {
        'user_uid': userUid,
        'date': entry.date.toIso8601String(),
        'systolic': entry.systolic,
        'diastolic': entry.diastolic,
        'blood_sugar': entry.bloodSugar,
        'age': entry.age,
        'notes': entry.notes,
        'predicted_risk_level': entry.predictedRiskLevel,
        'confidence': entry.confidence,
        'risk_category': entry.riskCategory,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<List<HealthEntry>> getHealthEntries(String userUid) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _healthEntriesTable,
      where: 'user_uid = ?',
      whereArgs: [userUid],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return HealthEntry(
        date: DateTime.parse(maps[i]['date']),
        systolic: maps[i]['systolic'],
        diastolic: maps[i]['diastolic'],
        bloodSugar: maps[i]['blood_sugar'],
        age: maps[i]['age'],
        notes: maps[i]['notes'],
        predictedRiskLevel: maps[i]['predicted_risk_level'],
        confidence: maps[i]['confidence'],
        riskCategory: maps[i]['risk_category'],
      );
    });
  }

  static Future<void> deleteHealthEntry(int id) async {
    final db = await database;
    await db.delete(
      _healthEntriesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> clearUserData(String userUid) async {
    final db = await database;
    await db.delete(
      _healthEntriesTable,
      where: 'user_uid = ?',
      whereArgs: [userUid],
    );
  }
}

class DatabaseAuthNotifier extends StateNotifier<AsyncValue<MockUser?>> {
  DatabaseAuthNotifier() : super(const AsyncValue.data(null));

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw Exception('Invalid email format');
      }

      if (password.isEmpty) {
        throw Exception('Password cannot be empty');
      }

      // Check if user exists in database
      final user = await DatabaseHelper.getUserByEmail(email);
      if (user == null) {
        throw Exception('No account found with this email');
      }

      state = AsyncValue.data(user);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required int age,
  }) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Validation
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw Exception('Invalid email format');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      if (name.trim().isEmpty || name.trim().length < 2) {
        throw Exception('Name must be at least 2 characters');
      }

      if (age < 13 || age > 120) {
        throw Exception('Age must be between 13 and 120');
      }

      // Check if user already exists
      final existingUser = await DatabaseHelper.getUserByEmail(email);
      if (existingUser != null) {
        throw Exception('An account with this email already exists');
      }

      // Create new user
      final user = MockUser(
        uid: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        name: name.trim(),
        age: age,
      );

      // Save to database
      await DatabaseHelper.insertUser(user);

      state = AsyncValue.data(user);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 200));
    state = const AsyncValue.data(null);
  }
}