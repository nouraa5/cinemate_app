class Booking {
  final int? id;
  final int userId;
  final int showtimeId;
  final String seatIds; // store seat IDs as comma-separated or JSON
  final double total;
  final String bookedAt; // or store as a DateTime
  final String qrCode;

  Booking({
    this.id,
    required this.userId,
    required this.showtimeId,
    required this.seatIds,
    required this.total,
    required this.bookedAt,
    required this.qrCode,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      userId: map['user_id'],
      showtimeId: map['showtime_id'],
      seatIds: map['seat_ids'],
      total: map['total'],
      bookedAt: map['booked_at'],
      qrCode: map['qr_code'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'showtime_id': showtimeId,
      'seat_ids': seatIds,
      'total': total,
      'booked_at': bookedAt,
      'qr_code': qrCode,
    };
  }
}
