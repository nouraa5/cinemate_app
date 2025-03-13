import 'package:flutter/material.dart';
import '../database/movie_dao.dart';
import '../models/movie.dart';

class MovieProvider extends ChangeNotifier {
  final MovieDAO _movieDao = MovieDAO();
  List<Movie> _availableMovies = [];
  List<Movie> _comingSoonMovies = [];
  List<String> _genres = [];
  String? _selectedGenre;

  List<Movie> get availableMovies => _availableMovies;
  List<Movie> get comingSoonMovies => _comingSoonMovies;
  List<String> get genres => _genres;
  String? get selectedGenre => _selectedGenre;

  Future<void> fetchMovies({String? genre}) async {
    final allMovies = await _movieDao.getAllMovies();
    final today = DateTime.now();

    if (genre == null || genre == "All") {
      _availableMovies = allMovies
          .where((movie) => DateTime.parse(movie.releaseDate).isBefore(today))
          .toList();
      _comingSoonMovies = allMovies
          .where((movie) => DateTime.parse(movie.releaseDate).isAfter(today))
          .toList();
    } else {
      _availableMovies = await _movieDao.getMoviesByGenre(genre);
      _availableMovies = _availableMovies
          .where((movie) => DateTime.parse(movie.releaseDate).isBefore(today))
          .toList();

      _comingSoonMovies = await _movieDao.getMoviesByGenre(genre);
      _comingSoonMovies = _comingSoonMovies
          .where((movie) => DateTime.parse(movie.releaseDate).isAfter(today))
          .toList();
    }

    notifyListeners();
  }

  Future<void> fetchGenres() async {
    _genres = await _movieDao.getAllGenres();
    _genres.insert(0, "All"); // Add "All" option at the beginning
    notifyListeners();
  }

  void setSelectedGenre(String genre) {
    _selectedGenre = genre;
    fetchMovies(genre: genre);
  }
}
