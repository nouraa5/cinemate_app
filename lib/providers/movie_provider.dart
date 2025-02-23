import 'package:flutter/material.dart';
import '../database/movie_dao.dart';
import '../models/movie.dart';

class MovieProvider extends ChangeNotifier {
  final MovieDAO _movieDao = MovieDAO();
  List<Movie> _availableMovies = [];
  List<Movie> _comingSoonMovies = [];

  List<Movie> get availableMovies => _availableMovies;
  List<Movie> get comingSoonMovies => _comingSoonMovies;

  Future<void> fetchMovies() async {
    final allMovies = await _movieDao.getAllMovies();
    final today = DateTime.now();

    _availableMovies = allMovies.where((movie) {
      return DateTime.parse(movie.releaseDate).isBefore(today);
    }).toList();

    _comingSoonMovies = allMovies.where((movie) {
      return DateTime.parse(movie.releaseDate).isAfter(today);
    }).toList();

    notifyListeners();
  }
}
