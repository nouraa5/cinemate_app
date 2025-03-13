import 'package:sqflite/sqflite.dart';
import '../models/showtime.dart';
import '../database/db_helper.dart';

class ShowtimeDao {
  // Insert Showtime
  Future<int> insertShowtime(Showtime showtime) async {
    final db = await DBHelper.database;
    return await db.insert('showtimes', showtime.toMap());
  }

  // Fetch all showtimes
  Future<List<Showtime>> getAllShowtimes() async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> result = await db.query('showtimes');
    return result.map((map) => Showtime.fromMap(map)).toList();
  }

  // Inside your ShowtimeDao class

  Future<Showtime?> getShowtimeById(int id) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'showtimes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Showtime.fromMap(result.first);
    }
    return null;
  }

  // Fetch showtimes for a specific movie
  Future<List<Showtime>> getShowtimesByMovieAndDate(
      int movieId, String date) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'showtimes',
      where: 'movie_id = ? AND date = ?',
      whereArgs: [movieId, date],
    );
    return result.map((map) => Showtime.fromMap(map)).toList();
  }
}
