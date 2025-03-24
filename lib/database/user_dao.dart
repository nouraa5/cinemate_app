import 'package:sqflite/sqflite.dart';
import '../models/user.dart';
import 'db_helper.dart';

class UserDAO {
  // Insert user
  Future<int> insertUser(User user) async {
    final db = await DBHelper.database;
    return await db.insert('users', user.toMap(includeId: false));
  }

// Modify getUser to use hashed password
  Future<User?> getUser(String email, String password) async {
    final db = await DBHelper.database;
    final hashedPassword = User.hashPassword(password);
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, hashedPassword],
    );

    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await DBHelper.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // Get user by ID
  Future<User?> getUserById(int id) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query('users', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) return User.fromMap(maps.first);
    return null;
  }
}
