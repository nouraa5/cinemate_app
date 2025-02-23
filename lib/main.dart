import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/db_helper.dart';
import 'providers/user_provider.dart';
import 'providers/movie_provider.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/signup_screen.dart';
import 'views/home/home_screen.dart';
import 'views/home/movie_details_screen.dart';

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
      ],
      child: MaterialApp(
        title: 'Cinema Booking App',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        routes: {
          '/': (context) => HomeScreen(),
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/movie-details': (context) =>
              MovieDetailsScreenWrapper(), // Wrapper for passing arguments
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/movie-details' && settings.arguments is int) {
            final movieId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (context) => MovieDetailsScreen(movieId: movieId),
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

// Wrapper to handle argument passing via named routes
class MovieDetailsScreenWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final movieId = ModalRoute.of(context)?.settings.arguments as int?;
    if (movieId == null) {
      return Scaffold(
        body: Center(child: Text('Invalid movie ID')),
      );
    }
    return MovieDetailsScreen(movieId: movieId);
  }
}
