import 'package:sqflite/sqflite.dart';
import '../models/movie.dart';
import 'db_helper.dart';
import '../models/showtime.dart';

class MovieDAO {
  // Insert a movie
  Future<int> insertMovie(Movie movie, List<int> genreIds) async {
    final db = await DBHelper.database;
    int movieId = await db.insert('movies', movie.toMap());

    for (int genreId in genreIds) {
      await db.insert('movie_genres', {
        'movie_id': movieId,
        'genre_id': genreId,
      });
    }
    return movieId;
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

  Future<List<Movie>> getMoviesByGenre(String genreName) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT movies.* FROM movies
    JOIN movie_genres ON movies.id = movie_genres.movie_id
    JOIN genres ON movie_genres.genre_id = genres.id
    WHERE genres.name = ?
  ''', [genreName]);

    return List.generate(maps.length, (i) => Movie.fromMap(maps[i]));
  }

  Future<List<String>> getGenresForMovie(int movieId) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT genres.name FROM genres
    JOIN movie_genres ON genres.id = movie_genres.genre_id
    WHERE movie_genres.movie_id = ?
  ''', [movieId]);

    return maps.map((map) => map['name'] as String).toList();
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

  Future<List<Showtime>> getShowtimesForMovieAndDate(
      int movieId, DateTime date) async {
    final db = await DBHelper.database;
    final String formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final List<Map<String, dynamic>> maps = await db.query(
      'showtimes',
      where: 'movie_id = ? AND date = ?',
      whereArgs: [movieId, formattedDate],
    );

    return List.generate(maps.length, (i) => Showtime.fromMap(maps[i]));
  }

  // In movie_dao.dart
  Future<List<Showtime>> getShowtimesForMovie(int movieId) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'showtimes',
      where: 'movie_id = ?',
      whereArgs: [movieId],
    );
    return List.generate(maps.length, (i) => Showtime.fromMap(maps[i]));
  }

  Future<List<String>> getAllGenres() async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('genres');

    return maps.map((map) => map['name'] as String).toList();
  }

  // Future<List<Movie>> getMoviesByGenre(int genreId) async {
  //   final db = await DBHelper.database;
  //   final List<Map<String, dynamic>> maps = await db.rawQuery('''
  //     SELECT movies.* FROM movies
  //     JOIN movie_genres ON movies.id = movie_genres.movie_id
  //     WHERE movie_genres.genre_id = ?
  //   ''', [genreId]);

  //   return List.generate(maps.length, (i) {
  //     return Movie.fromMap(maps[i]);
  //   });
  // }
}
