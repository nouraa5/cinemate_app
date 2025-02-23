import 'package:flutter/material.dart';
import '../../models/movie.dart';
import 'package:go_router/go_router.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/movie-details', extra: movie),
      child: Container(
        width: 120,
        margin: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Image.asset(movie.posterUrl, height: 150, fit: BoxFit.cover),
            SizedBox(height: 8),
            Text(
              movie.title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
