import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/booking.dart';
import 'checkout_screen.dart';
import '../../database/showtime_dao.dart';
import '../../database/seat_dao.dart';
import '../../models/showtime.dart';
import '../../models/seat.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({Key? key}) : super(key: key);

  @override
  _BookingListScreenState createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  late Future<List<Booking>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    _bookingsFuture =
        bookingProvider.getUserBookings(userProvider.currentUser?.id ?? -1);
  }

  Future<void> _refreshBookings() async {
    setState(() {
      _loadBookings();
    });
    await _bookingsFuture;
  }

  Future<void> _confirmAndDeleteBooking(Booking booking) async {
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);

    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Booking"),
        content: const Text("Are you sure you want to delete this booking?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await bookingProvider.deleteBooking(booking.id!);
      _refreshBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("My Bookings", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<Booking>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.orange));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No bookings found",
                  style: TextStyle(color: Colors.white70)),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshBookings,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final booking = snapshot.data![index];
                return BookingListItem(
                  booking: booking,
                  onDelete: _confirmAndDeleteBooking,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class BookingListItem extends StatelessWidget {
  final Booking booking;
  final Function(Booking booking) onDelete;

  const BookingListItem({
    Key? key,
    required this.booking,
    required this.onDelete,
  }) : super(key: key);

  Future<Map<String, dynamic>> _fetchExtraDetails() async {
    final showtimeDao = ShowtimeDao();
    final seatDao = SeatDAO();
    Showtime? showtime = await showtimeDao.getShowtimeById(booking.showtimeId);

    List<String> seatIdStrs = booking.seatIds.split(',');
    List<Seat> seats = [];
    for (var seatIdStr in seatIdStrs) {
      int seatId = int.tryParse(seatIdStr.trim()) ?? 0;
      if (seatId != 0) {
        Seat seat = await seatDao.getSeatById(seatId);
        seats.add(seat);
      }
    }
    return {
      'showtime': showtime,
      'seats': seats,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchExtraDetails(),
      builder: (context, snapshot) {
        String showtimeText = 'Loading...';
        String seatsText = 'Loading...';

        if (snapshot.hasData) {
          final showtime = snapshot.data!['showtime'] as Showtime?;
          final seats = snapshot.data!['seats'] as List<Seat>;
          showtimeText =
              showtime != null ? '${showtime.date} ${showtime.time}' : 'N/A';
          seatsText = seats.isNotEmpty
              ? seats.map((s) => s.seatNumber).join(', ')
              : 'N/A';
        }

        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundColor: Colors.orange,
              child: const Icon(Icons.movie, color: Colors.white, size: 20),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Showtime: $showtimeText",
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  "Seats: $seatsText",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  "Booked At: ${booking.bookedAt}",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.orange, size: 20),
              onPressed: () => onDelete(booking),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BookingConfirmationScreen(bookingId: booking.id!),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
