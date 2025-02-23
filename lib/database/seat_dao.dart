import 'package:sqflite/sqflite.dart';
import '../models/seat.dart';
import 'db_helper.dart';

class SeatDAO {
  // Mark seats as booked
  static Future<int> bookSeats(List<int> seatIds) async {
    final db = await DBHelper.database;
    int count = 0;

    for (int seatId in seatIds) {
      count += await db.update(
        'seats',
        {'is_booked': 1},
        where: 'id = ?',
        whereArgs: [seatId],
      );
    }

    return count;
  }

  // Insert multiple seats for a showtime
  static Future<void> insertSeatsForShowtime(
      int showtimeId, List<String> seatNumbers) async {
    final db = await DBHelper.database;

    for (String seat in seatNumbers) {
      await db.insert('seats',
          {'showtime_id': showtimeId, 'seat_number': seat, 'is_booked': 0});
    }
  }

  static Future<List<Seat>> getAvailableSeats(
      int movieId, String showtime) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT * FROM seats
    WHERE id NOT IN (
      SELECT seat_id FROM bookings
      WHERE movie_id = ? AND showtime = ?
    )
  ''', [movieId, showtime]);

    return List.generate(maps.length, (i) {
      return Seat.fromMap(maps[i]);
    });
  }
}
