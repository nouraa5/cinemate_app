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

  Future<Booking?> getBookingById(int bookingId) async {
    return await _bookingDao.getBookingById(bookingId);
  }
}
