class Seat {
  final int id;
  final int showtimeId;
  final String seatNumber;
  final bool isBooked;

  Seat({
    required this.id,
    required this.showtimeId,
    required this.seatNumber,
    required this.isBooked,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'showtime_id': showtimeId,
        'seat_number': seatNumber,
        'is_booked': isBooked ? 1 : 0,
      };

  factory Seat.fromMap(Map<String, dynamic> map) => Seat(
        id: map['id'],
        showtimeId: map['showtime_id'],
        seatNumber: map['seat_number'],
        isBooked: map['is_booked'] == 1,
      );
}
