import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/db_helper.dart';
import 'providers/user_provider.dart';
import 'providers/movie_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/seat_provider.dart';
import 'providers/showtime_provider.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/signup_screen.dart';
import 'views/home/home_screen.dart';
import 'views/home/movie_details_screen.dart';
import 'views/booking/select_showtime_screen.dart';
import 'views/booking/select_seat_screen.dart';
import 'widgets/navigation_bar.dart'; // Ensure correct path for AppNavigation

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.database;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => SeatProvider()),
        ChangeNotifierProvider(create: (_) => ShowtimeProvider()),
      ],
      child: MaterialApp(
        title: 'Cinema Booking App',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        routes: {
          // Use AppNavigation as the shell widget for main pages
          '/': (context) => const AppNavigation(),
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/movie-details' && settings.arguments is int) {
            final movieId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => MovieDetailsScreen(movieId: movieId),
            );
          }
          if (settings.name == '/select-showtime' &&
              settings.arguments is int) {
            final movieId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => SelectShowtimeScreen(movieId: movieId),
            );
          }
          if (settings.name == '/select-seat' && settings.arguments is Map) {
            final args = settings.arguments as Map;
            return MaterialPageRoute(
              builder: (context) => SelectSeatsScreen(
                showtimeId: args['showtimeId'],
              ),
            );
          }
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Center(child: Text('Page Not Found')),
            ),
          );
        },
      ),
    );
  }
}
