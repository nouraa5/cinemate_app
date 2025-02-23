import 'package:sqflite/sqflite.dart';
import '../models/movie.dart';
import 'db_helper.dart';

class MovieDAO {
  // Insert a movie
  Future<int> insertMovie(Movie movie) async {
    final db = await DBHelper.database;
    return await db.insert('movies', movie.toMap());
  }

  // Get all movies
  Future<List<Movie>> getAllMovies() async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('movies');

    return List.generate(maps.length, (i) {
      return Movie.fromMap(maps[i]);
    });
  }

  // Get a movie by ID
  Future<Movie?> getMovieById(int id) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query('movies', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) return Movie.fromMap(maps.first);
    return null;
  }

  // Delete a movie
  Future<int> deleteMovie(int id) async {
    final db = await DBHelper.database;
    return await db.delete('movies', where: 'id = ?', whereArgs: [id]);
  }

  // Update a movie
  Future<int> updateMovie(Movie movie) async {
    final db = await DBHelper.database;
    return await db.update('movies', movie.toMap(),
        where: 'id = ?', whereArgs: [movie.id]);
  }

  Future<List<Movie>> getMoviesByGenre(int genreId) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT movies.* FROM movies
      JOIN movie_genres ON movies.id = movie_genres.movie_id
      WHERE movie_genres.genre_id = ?
    ''', [genreId]);

    return List.generate(maps.length, (i) {
      return Movie.fromMap(maps[i]);
    });
  }
}
