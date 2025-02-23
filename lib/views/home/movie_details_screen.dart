import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/movie_dao.dart';
import '../../models/movie.dart';
import '../../providers/user_provider.dart';

class MovieDetailsScreen extends StatelessWidget {
  final int movieId;

  MovieDetailsScreen({required this.movieId});

  @override
  Widget build(BuildContext context) {
    final MovieDAO movieDao = MovieDAO();
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text('Movie Details')),
      body: FutureBuilder<Movie?>(
        future: movieDao.getMovieById(movieId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Movie not found'));
          } else {
            final Movie movie = snapshot.data!;
            final isAvailable =
                DateTime.parse(movie.releaseDate).isBefore(DateTime.now());

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Image.asset(movie.posterUrl)),
                  SizedBox(height: 20),
                  Text(movie.title,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text(movie.description, style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Text('Rating: ${movie.rating}',
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  Text('Actors: ${movie.actors.join(", ")}',
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 20),
                  if (isAvailable)
                    ElevatedButton(
                      onPressed: () {
                        if (userProvider.isAuthenticated) {
                          // Navigate to booking screen
                          Navigator.pushNamed(context, "/booking",
                              arguments: movieId);
                        } else {
                          // Redirect to login
                          Navigator.pushNamed(context, "/login");
                        }
                      },
                      child: Text('Book a Seat'),
                    )
                  else
                    Text(
                      "Movie coming soon on ${movie.releaseDate}",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
