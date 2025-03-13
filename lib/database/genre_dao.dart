import 'package:sqflite/sqflite.dart';
import '../models/genre.dart';
import 'package:cinema_app/database/db_helper.dart';

class GenreDAO {
  // Insert a new genre into the database
  static Future<int> insertGenre(Genre genre) async {
    final db = await DBHelper.database;
    return await db.insert(
      'genres',
      genre.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // Get all genres from the database
  static Future<List<Genre>> getAllGenres() async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('genres');

    return List.generate(maps.length, (i) {
      return Genre.fromMap(maps[i]);
    });
  }

  // Get a genre by ID
  static Future<Genre?> getGenreById(int id) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query('genres', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Genre.fromMap(maps.first);
    }
    return null;
  }

  // Update a genre
  static Future<int> updateGenre(Genre genre) async {
    final db = await DBHelper.database;
    return await db.update(
      'genres',
      genre.toMap(),
      where: 'id = ?',
      whereArgs: [genre.id],
    );
  }

  // Delete a genre
  static Future<int> deleteGenre(int id) async {
    final db = await DBHelper.database;
    return await db.delete('genres', where: 'id = ?', whereArgs: [id]);
  }

  // Assign a genre to a movie
  static Future<void> assignGenreToMovie(int movieId, int genreId) async {
    final db = await DBHelper.database;
    await db.insert(
      'movie_genres',
      {'movie_id': movieId, 'genre_id': genreId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // Get all genres for a given movie
  static Future<List<Genre>> getGenresForMovie(int movieId) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT g.id, g.name FROM genres g
      JOIN movie_genres mg ON g.id = mg.genre_id
      WHERE mg.movie_id = ?
    ''', [movieId]);

    return results.map((map) => Genre.fromMap(map)).toList();
  }
}
