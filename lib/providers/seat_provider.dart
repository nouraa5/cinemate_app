import 'package:flutter/material.dart';
import '../database/seat_dao.dart';
import '../models/seat.dart';

class SeatProvider extends ChangeNotifier {
  List<Seat> _availableSeats = [];

  List<Seat> get availableSeats => _availableSeats;

  Future<void> fetchSeatsForShowtime(int movieId, String showtime) async {
    _availableSeats = await SeatDAO.getAvailableSeats(movieId, showtime);
    notifyListeners();
  }
}
