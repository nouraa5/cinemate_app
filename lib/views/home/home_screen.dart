import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/movie_provider.dart';
import '../../models/movie.dart';
import '../../views/home/movie_details_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<MovieProvider>(context, listen: false).fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Movies")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Now Available",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            _buildMovieList(movieProvider.availableMovies),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Coming Soon",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            _buildMovieList(movieProvider.comingSoonMovies),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieList(List<Movie> movies) {
    return movies.isEmpty
        ? Center(child: Text("No movies available"))
        : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              Movie movie = movies[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(Icons.movie, size: 40),
                  title: Text(movie.title),
                  subtitle: Text(movie.description),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MovieDetailsScreen(movieId: movie.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
  }
}
