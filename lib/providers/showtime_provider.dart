import 'package:flutter/material.dart';
import '../database/showtime_dao.dart';
import '../models/showtime.dart';

class ShowtimeProvider extends ChangeNotifier {
  final ShowtimeDao _showtimeDao = ShowtimeDao();

  String _selectedDate = _getDefaultDate();
  List<Showtime> _showtimes = [];
  Showtime? _selectedShowtime;

  String get selectedDate => _selectedDate;
  List<Showtime> get showtimes => _showtimes;
  Showtime? get selectedShowtime => _selectedShowtime;

  // Generate default date (today's date)
  static String _getDefaultDate() {
    DateTime now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  // Load showtimes based on movie and date
  Future<void> loadShowtimes(int movieId) async {
    _showtimes =
        await _showtimeDao.getShowtimesByMovieAndDate(movieId, _selectedDate);
    notifyListeners();
  }

  // Update selected date & fetch new showtimes
  void updateDate(int movieId, String date) {
    _selectedDate = date;
    loadShowtimes(movieId);
  }

  // Select a showtime
  void selectShowtime(Showtime showtime) {
    _selectedShowtime = showtime;
    notifyListeners();
  }
}
