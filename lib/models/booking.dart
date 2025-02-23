class Booking {
  final int id;
  final int userId;
  final int showtimeId;
  final List<String> seats;
  final double totalPrice;
  final String qrCode;

  Booking({
    required this.id,
    required this.userId,
    required this.showtimeId,
    required this.seats,
    required this.totalPrice,
    required this.qrCode,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'showtime_id': showtimeId,
        'seats': seats.join(','),
        'total_price': totalPrice,
        'qr_code': qrCode,
      };

  factory Booking.fromMap(Map<String, dynamic> map) => Booking(
        id: map['id'],
        userId: map['user_id'],
        showtimeId: map['showtime_id'],
        seats: map['seats'].split(','),
        totalPrice: map['total_price'],
        qrCode: map['qr_code'],
      );
}
