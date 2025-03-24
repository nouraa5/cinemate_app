import 'package:cinema_app/database/seat_dao.dart';
import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../database/booking_dao.dart';

class BookingProvider extends ChangeNotifier {
  final BookingDao _bookingDao = BookingDao();

  Booking? _latestBooking;
  Booking? get latestBooking => _latestBooking;

  Future<int> createBooking({
    required int userId,
    required int showtimeId,
    required List<int> seatIds,
    required double total,
    required String qrCodeContent,
  }) async {
    final booking = Booking(
      userId: userId,
      showtimeId: showtimeId,
      seatIds: seatIds.join(','), // or JSON-encode if you prefer
      total: total,
      bookedAt: DateTime.now().toIso8601String(),
      qrCode: qrCodeContent,
    );
    final newId = await _bookingDao.insertBooking(booking);
    _latestBooking = await _bookingDao.getBookingById(newId);
    notifyListeners();
    return newId;
  }

  Future<List<Booking>> getUserBookings(int userId) async {
    return await _bookingDao.getUserBookings(userId);
  }

  Future<Booking?> getBookingById(int bookingId) async {
    return await _bookingDao.getBookingById(bookingId);
  }

  Future<void> deleteBooking(int bookingId) async {
    // First, fetch the booking to get its details (seatIds and showtimeId)
    Booking? booking = await _bookingDao.getBookingById(bookingId);

    if (booking != null) {
      // Parse the seatIds (assuming a comma-separated string)
      List<String> seatIdStrs = booking.seatIds.split(',');
      final seatDao = SeatDAO();
      for (var seatIdStr in seatIdStrs) {
        int seatId = int.tryParse(seatIdStr.trim()) ?? 0;
        if (seatId != 0) {
          // Call unbookSeat to update the seat status back to available
          await seatDao.unbookSeat(seatId, booking.showtimeId);
        }
      }
    }

    // Now, delete the booking record
    await _bookingDao.deleteBooking(bookingId);
    notifyListeners();
  }
}
