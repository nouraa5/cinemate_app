import 'package:sqflite/sqflite.dart';
import '../models/seat.dart';
import '../database/db_helper.dart';

class SeatDAO {
  // Insert Seat
  Future<int> insertSeat(Seat seat) async {
    final db = await DBHelper.database;
    return await db.insert('seats', seat.toMap());
  }

  Future<Seat> getSeatById(int id) async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'seats',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Seat.fromMap(result.first);
    } else {
      throw Exception('Seat with id $id not found');
    }
  }

  // Fetch all seats
  Future<List<Seat>> getAllSeats() async {
    final db = await DBHelper.database;
    final List<Map<String, dynamic>> result = await db.query('seats');
    return result.map((map) => Seat.fromMap(map)).toList();
  }

  // Fetch seats for a specific showtime
  Future<List<Map<String, dynamic>>> getSeatsByShowtime(int showtimeId) async {
    final db = await DBHelper.database;
    final result = await db.rawQuery('''
      SELECT s.id, s.seat_number, s.row_number, s.column_number, ss.is_booked
      FROM seats s
      JOIN showtime_seats ss ON s.id = ss.seat_id
      WHERE ss.showtime_id = ?
    ''', [showtimeId]);
    return result;
  }

  // Mark seat as booked
  Future<int> bookSeat(int seatId, int showtimeId) async {
    final db = await DBHelper.database;
    return await db.update(
      'showtime_seats',
      {'is_booked': 1},
      where: 'seat_id = ? AND showtime_id = ?',
      whereArgs: [seatId, showtimeId],
    );
  }

  // Unbook seat (optional, in case of cancellation)
  Future<int> unbookSeat(int seatId, int showtimeId) async {
    final db = await DBHelper.database;
    return await db.update(
      'showtime_seats',
      {'is_booked': 0},
      where: 'seat_id = ? AND showtime_id = ?',
      whereArgs: [seatId, showtimeId],
    );
  }
}
