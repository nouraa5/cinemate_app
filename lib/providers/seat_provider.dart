import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../database/seat_dao.dart';
import '../models/booking.dart';

class SeatProvider extends ChangeNotifier {
  final SeatDAO _seatDao = SeatDAO();
  List<Map<String, dynamic>> _seats = [];
  List<int> _selectedSeats = [];

  List<Map<String, dynamic>> get seats => _seats;
  List<int> get selectedSeats => _selectedSeats;

  // Load seats for a given showtime
  Future<void> loadSeats(int showtimeId) async {
    _seats = await _seatDao.getSeatsByShowtime(showtimeId);
    notifyListeners();
  }

  // Select or deselect a seat
  void toggleSeatSelection(int seatId) {
    if (_selectedSeats.contains(seatId)) {
      _selectedSeats.remove(seatId);
    } else {
      _selectedSeats.add(seatId);
    }
    notifyListeners();
  }

  // Updated Confirm Booking method accepting userId
  Future<int> confirmBooking(int showtimeId, int userId) async {
    // 1. Mark each selected seat as booked in the showtime_seats table
    for (var seatId in _selectedSeats) {
      await _seatDao.bookSeat(seatId, showtimeId);
    }

    // 2. Calculate the total price (e.g., \$7 per seat)
    double total = _selectedSeats.length * 7.0;

    // 3. Create a new booking record
    final booking = Booking(
      userId: userId,
      showtimeId: showtimeId,
      seatIds: _selectedSeats.join(','), // e.g. "1,2,3"
      total: total,
      bookedAt: DateTime.now().toIso8601String(),
      qrCode:
          'Booking for user $userId at showtime $showtimeId with seats: ${_selectedSeats.join(',')}', // Customize as needed
    );

    final db = await DBHelper.database;
    final bookingId = await db.insert('bookings', booking.toMap());

    // 4. Clear selected seats and notify listeners
    _selectedSeats.clear();
    notifyListeners();

    return bookingId;
  }
}
