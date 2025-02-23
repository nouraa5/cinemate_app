import 'package:sqflite/sqflite.dart';
import '../models/booking.dart';
import 'db_helper.dart';

class BookingDAO {
  // Insert a booking
  Future<int> insertBooking(Booking booking) async {
    final db = await DBHelper.database;
    return await db.insert('bookings', booking.toMap());
  }

  // Get bookings by user ID
  Future<List<Booking>> getBookingsByUserId(int userId) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps =
        await db.query('bookings', where: 'user_id = ?', whereArgs: [userId]);

    return List.generate(maps.length, (i) => Booking.fromMap(maps[i]));
  }

  // Delete a booking
  Future<int> deleteBooking(int id) async {
    final db = await DBHelper.database;
    return await db.delete('bookings', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Booking>> getUserBookings(int userId) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT bookings.*, movies.title, seats.row_number, seats.column_number
    FROM bookings
    JOIN movies ON bookings.movie_id = movies.id
    JOIN seats ON bookings.seat_id = seats.id
    WHERE bookings.user_id = ?
  ''', [userId]);

    return List.generate(maps.length, (i) {
      return Booking.fromMap(maps[i]);
    });
  }

  Future<int> bookSeat(
      int userId, int movieId, int seatId, String showtime) async {
    final db = await DBHelper.database;
    return await db.insert('bookings', {
      'user_id': userId,
      'movie_id': movieId,
      'seat_id': seatId,
      'showtime': showtime,
    });
  }
}
