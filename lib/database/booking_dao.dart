import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../models/booking.dart';

class BookingDao {
  Future<int> insertBooking(Booking booking) async {
    final db = await DBHelper.database;
    return await db.insert('bookings', booking.toMap());
  }

  Future<Booking?> getBookingById(int bookingId) async {
    final db = await DBHelper.database;
    final result = await db.query(
      'bookings',
      where: 'id = ?',
      whereArgs: [bookingId],
    );
    if (result.isNotEmpty) {
      return Booking.fromMap(result.first);
    }
    return null;
  }

  Future<List<Booking>> getAllBookings() async {
    final db = await DBHelper.database;
    final result = await db.query('bookings');
    return result.map((map) => Booking.fromMap(map)).toList();
  }

  // Add more methods if needed, e.g. update, delete, etc.
}
