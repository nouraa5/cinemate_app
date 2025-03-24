import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/booking_provider.dart';
import '../../models/booking.dart';
import '../../database/showtime_dao.dart';
import '../../database/movie_dao.dart';
import '../../database/seat_dao.dart';
import '../../models/showtime.dart';
import '../../models/movie.dart';
import '../../models/seat.dart';
import '../../providers/user_provider.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final int bookingId;
  const BookingConfirmationScreen({Key? key, required this.bookingId})
      : super(key: key);

  @override
  _BookingConfirmationScreenState createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  Booking? _booking;
  Showtime? _showtime;
  Movie? _movie;
  List<Seat> _seats = [];
  bool _isLoading = true;
  String? _qrData;

  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
  }

  Future<void> _loadBookingDetails() async {
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    Booking? booking = await bookingProvider.getBookingById(widget.bookingId);

    if (booking != null) {
      final showtimeDao = ShowtimeDao();
      Showtime? showtime =
          await showtimeDao.getShowtimeById(booking.showtimeId);

      Movie? movie;
      if (showtime != null) {
        final movieDao = MovieDAO();
        movie = await movieDao.getMovieById(showtime.movieId);
      }

      List<Seat> seats = [];
      final seatDao = SeatDAO();
      List<String> seatIdStrs = booking.seatIds.split(',');
      for (var seatIdStr in seatIdStrs) {
        int seatId = int.tryParse(seatIdStr.trim()) ?? 0;
        if (seatId != 0) {
          Seat seat = await seatDao.getSeatById(seatId);
          seats.add(seat);
        }
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      String userIdentifier =
          userProvider.currentUser?.id.toString() ?? 'Unknown';

      String qrData = "Reference: BOOKING-${booking.id}\n"
          "Showtime: ${showtime != null ? '${showtime.date} ${showtime.time}' : 'N/A'}\n"
          "Seats: ${seats.map((s) => s.seatNumber).join(', ')}\n"
          "Movie: ${movie != null ? movie.title : 'N/A'}\n"
          "User: $userIdentifier";

      setState(() {
        _booking = booking;
        _showtime = showtime;
        _movie = movie;
        _seats = seats;
        _qrData = qrData;
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadBookingInfo() async {
    if (_booking == null) return;

    String fileContent = "Booking Reference: BOOKING-${_booking!.id}\n"
        "Movie: ${_movie != null ? _movie!.title : 'N/A'}\n"
        "Showtime: ${_showtime != null ? '${_showtime!.date} ${_showtime!.time}' : 'N/A'}\n"
        "Seats: ${_seats.map((seat) => seat.seatNumber).join(', ')}\n"
        "Total: \$${_booking!.total.toStringAsFixed(2)}\n"
        "QR Data:\n$_qrData\n";

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String filePath = "${appDocDir.path}/booking_${_booking!.id}.txt";
    File file = File(filePath);
    await file.writeAsString(fileContent);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Booking details saved to: $filePath")),
    );
  }

  void _shareBooking() {
    if (_qrData != null) {
      Share.share(_qrData!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // When back is pressed, navigate to the Home Screen.
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text(
            'Booking Confirmation',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: _shareBooking,
            ),
          ],
        ),
        body: _isLoading || _booking == null
            ? const Center(
                child: CircularProgressIndicator(color: Colors.orange))
            : SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Card(
                  color: Colors.grey.shade900,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Movie Poster
                        if (_movie != null && _movie!.posterUrl.isNotEmpty)
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                _movie!.posterUrl,
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),
                        // Movie Title
                        Center(
                          child: Text(
                            _movie != null ? _movie!.title : 'Movie Name',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Divider(
                          color: Colors.white70,
                          thickness: 1,
                        ),
                        const SizedBox(height: 10),
                        // Booking Details
                        _buildDetailRow(
                            "Booking Reference:", "BOOKING-${_booking!.id}"),
                        const SizedBox(height: 10),
                        _buildDetailRow(
                            "Showtime:",
                            _showtime != null
                                ? '${_showtime!.date} ${_showtime!.time}'
                                : 'N/A'),
                        const SizedBox(height: 10),
                        _buildDetailRow("Seats:",
                            _seats.map((seat) => seat.seatNumber).join(', ')),
                        const SizedBox(height: 10),
                        _buildDetailRow("Total:",
                            "\$${_booking!.total.toStringAsFixed(2)}"),
                        const SizedBox(height: 20),
                        // QR Code
                        Center(
                          child: QrImageView(
                            data: _qrData ?? '',
                            version: QrVersions.auto,
                            size: 220,
                            backgroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Center(
                          child: Text(
                            'Show this QR code at the cinema',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        // Download Button
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _downloadBookingInfo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 28),
                              elevation: 0,
                            ),
                            icon:
                                const Icon(Icons.download, color: Colors.black),
                            label: const Text(
                              'Download Details',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
