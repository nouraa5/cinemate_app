class Seat {
  final int id;
  final String seatNumber; // Example: R1C2
  final int row;
  final int column;
  final bool isBooked;

  Seat({
    required this.id,
    required this.seatNumber,
    required this.row,
    required this.column,
    this.isBooked = false,
  });

  factory Seat.fromMap(Map<String, dynamic> map) {
    return Seat(
      id: map['id'],
      seatNumber: map['seat_number'],
      row: map['row_number'],
      column: map['column_number'],
      isBooked: map['is_booked'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'seat_number': seatNumber,
      'row_number': row,
      'column_number': column,
    };
  }
}
