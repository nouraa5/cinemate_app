import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/showtime_provider.dart';
import '../../models/showtime.dart';
import 'select_seat_screen.dart';

class SelectShowtimeScreen extends StatelessWidget {
  final int movieId;
  const SelectShowtimeScreen({Key? key, required this.movieId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final showtimeProvider =
        Provider.of<ShowtimeProvider>(context, listen: false);

    // Load initial showtimes on frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showtimeProvider.loadShowtimes(movieId);
    });

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Select Showtime",
            style: TextStyle(color: Colors.white, fontSize: 16)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Label for date slider
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Choose a date",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Date Selector
          SizedBox(
            height: 80,
            child: Consumer<ShowtimeProvider>(
              builder: (context, provider, child) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    DateTime date = DateTime.now().add(Duration(days: index));
                    String formattedDate =
                        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                    bool isSelected = provider.selectedDate == formattedDate;

                    return GestureDetector(
                      onTap: () => provider.updateDate(movieId, formattedDate),
                      child: Container(
                        width: 70,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.orange : Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${date.day}",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.black : Colors.white,
                              ),
                            ),
                            Text(
                              [
                                "Sun",
                                "Mon",
                                "Tue",
                                "Wed",
                                "Thu",
                                "Fri",
                                "Sat"
                              ][date.weekday % 7],
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          // Label for showtime list
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Choose a showtime",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Showtime List
          Expanded(
            child: Consumer<ShowtimeProvider>(
              builder: (context, provider, child) {
                if (provider.showtimes.isEmpty) {
                  return const Center(
                    child: Text("No showtimes available.",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  );
                }
                return ListView.builder(
                  itemCount: provider.showtimes.length,
                  itemBuilder: (context, index) {
                    Showtime showtime = provider.showtimes[index];
                    bool isSelected =
                        provider.selectedShowtime?.id == showtime.id;

                    return GestureDetector(
                      onTap: () => provider.selectShowtime(showtime),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.orange : Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              showtime.time,
                              style: TextStyle(
                                  fontSize: 18,
                                  color:
                                      isSelected ? Colors.black : Colors.white),
                            ),
                            Icon(
                              Icons.check,
                              color: isSelected ? Colors.black : Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Continue button (if a showtime is selected)
          Consumer<ShowtimeProvider>(
            builder: (context, provider, child) {
              return provider.selectedShowtime != null
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SelectSeatsScreen(
                                  showtimeId: provider.selectedShowtime!.id),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 100),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text("Continue",
                            style:
                                TextStyle(fontSize: 16, color: Colors.black)),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
