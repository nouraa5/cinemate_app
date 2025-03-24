import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/seat_provider.dart';
import '../../providers/user_provider.dart';
import 'checkout_screen.dart';

class SelectSeatsScreen extends StatefulWidget {
  final int showtimeId;
  const SelectSeatsScreen({Key? key, required this.showtimeId})
      : super(key: key);

  @override
  _SelectSeatsScreenState createState() => _SelectSeatsScreenState();
}

class _SelectSeatsScreenState extends State<SelectSeatsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<SeatProvider>(context, listen: false)
        .loadSeats(widget.showtimeId));
  }

  @override
  Widget build(BuildContext context) {
    final seatProvider = Provider.of<SeatProvider>(context);
    final selectedSeats = seatProvider.selectedSeats;
    final totalPrice = selectedSeats.length * 7;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select Seats',
          style: TextStyle(
            color: Colors.white,
            shadows: [
              Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black)
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          _buildScreenIndicator(),
          const SizedBox(height: 20),
          _buildSeatsGrid(seatProvider),
          const SizedBox(height: 30),
          _buildSeatLegend(),
          const Spacer(),
          _buildBottomBar(selectedSeats, totalPrice, seatProvider),
        ],
      ),
    );
  }

  Widget _buildScreenIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        height: 80,
        // Using a ClipPath with our custom ScreenClipper for a curved screen shape.
        child: ClipPath(
          clipper: ScreenClipper(),
          child: Container(
            height: 80,
            color: Colors.orange,
          ),
        ),
      ),
    );
  }

  Widget _buildSeatsGrid(SeatProvider seatProvider) {
    // Build a seat map for easier lookup
    Map<String, Map<String, dynamic>> seatMap = {
      for (var seat in seatProvider.seats)
        "${seat['row_number']}-${seat['column_number']}": seat
    };

    return Column(
      children: List.generate(6, (rowIndex) {
        return Padding(
          padding: EdgeInsets.only(bottom: rowIndex == 5 ? 0 : 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(8, (colIndex) {
              String key = "${rowIndex + 1}-${colIndex + 1}";
              var seatData = seatMap[key];
              bool isBooked =
                  seatData != null ? seatData['is_booked'] == 1 : false;
              int? seatId = seatData != null ? seatData['id'] as int : null;
              bool isSelected =
                  seatId != null && seatProvider.selectedSeats.contains(seatId);
              Color seatColor = isBooked
                  ? Colors.white
                  : isSelected
                      ? Colors.orange
                      : Colors.grey;

              return GestureDetector(
                onTap: (seatData == null || isBooked)
                    ? null
                    : () => seatProvider.toggleSeatSelection(seatId!),
                child: Container(
                  height: 30,
                  width: 30,
                  margin: EdgeInsets.only(right: colIndex == 3 ? 30 : 10),
                  decoration: BoxDecoration(
                    color: seatColor,
                    borderRadius: BorderRadius.circular(7.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black45,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      )
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildSeatLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        SeatLegend(color: Colors.grey, status: 'Available'),
        SizedBox(width: 10),
        SeatLegend(color: Colors.orange, status: 'Selected'),
        SizedBox(width: 10),
        SeatLegend(color: Colors.white, status: 'Reserved'),
      ],
    );
  }

  Widget _buildBottomBar(
      List selectedSeats, int totalPrice, SeatProvider seatProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 35),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.grey],
          stops: [0.5, 1],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(50)),
      ),
      child: Column(
        children: [
          const Text(
            'Total Price',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Text(
            '\$${totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              if (seatProvider.selectedSeats.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Please select a seat to proceed')),
                );
                return;
              }
              bool proceed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Confirm Booking"),
                      content: const Text(
                          "Are you sure you want to proceed with your booking?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Proceed"),
                        ),
                      ],
                    ),
                  ) ??
                  false;
              if (!proceed) return;
              final userProvider =
                  Provider.of<UserProvider>(context, listen: false);
              final userId = userProvider.currentUser?.id;
              if (userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please log in to book seats')),
                );
                return;
              }
              int bookingId =
                  await seatProvider.confirmBooking(widget.showtimeId, userId);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BookingConfirmationScreen(bookingId: bookingId),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            ),
            child: const Text(
              'Confirm Booking',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class SeatLegend extends StatelessWidget {
  final Color color;
  final String status;
  const SeatLegend({Key? key, required this.color, required this.status})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(5))),
        const SizedBox(width: 5),
        Text(status,
            style: const TextStyle(color: Colors.white, fontSize: 12, shadows: [
              Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black)
            ])),
      ],
    );
  }
}

class ScreenClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    // Start a little below the top so the curve is more pronounced
    path.moveTo(0, size.height * 0.2);
    // Create a smooth curve: control point in the middle at the bottom of the container
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height * 0.2);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
