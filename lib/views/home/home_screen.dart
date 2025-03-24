import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../providers/movie_provider.dart';
import '../../models/movie.dart';
import '../../views/home/movie_details_screen.dart';
import '../../widgets/nav_bar_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);
    movieProvider.fetchMovies();
    movieProvider.fetchGenres();
  }

  void _openFilterBottomSheet() {
    final movieProvider = Provider.of<MovieProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: movieProvider.genres.map((genre) {
              bool isSelected = movieProvider.selectedGenre == genre;
              return ChoiceChip(
                label: Text(
                  genre,
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                ),
                selected: isSelected,
                onSelected: (bool selected) {
                  movieProvider.setSelectedGenre(genre);
                  Navigator.pop(context);
                },
                selectedColor: Colors.orange,
                backgroundColor: Colors.grey[800],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildTrendingSlider(MovieProvider movieProvider) {
    List<Movie> allMovies = [
      ...movieProvider.availableMovies,
      ...movieProvider.comingSoonMovies,
    ];
    allMovies.sort((a, b) => b.rating.compareTo(a.rating));
    List<Movie> trendingMovies = allMovies.take(5).toList();
    if (trendingMovies.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 220,
          autoPlay: true,
          enlargeCenterPage: true,
          enableInfiniteScroll: true,
          autoPlayInterval: const Duration(seconds: 3),
        ),
        items: trendingMovies.map((movie) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MovieDetailsScreen(movieId: movie.id),
                ),
              );
            },
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    movie.posterUrl,
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [Colors.black54, Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      "TRENDING",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 2,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMovieList(List<Movie> movies) {
    if (movies.isEmpty) {
      return Center(
        child: Text("No movies available",
            style: TextStyle(color: Colors.white70)),
      );
    }
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        itemBuilder: (context, index) {
          Movie movie = movies[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MovieDetailsScreen(movieId: movie.id),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      movie.posterUrl,
                      width: 130,
                      height: 190,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 130,
                    child: Text(
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final movieProvider = Provider.of<MovieProvider>(context);
    List<Movie> filteredAvailableMovies =
        movieProvider.availableMovies.where((movie) {
      return movie.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
    List<Movie> filteredComingSoonMovies =
        movieProvider.comingSoonMovies.where((movie) {
      return movie.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return NavBarScaffold(
      title: "Movies",
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Search movies...",
                        hintStyle: const TextStyle(color: Colors.white70),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.white),
                        filled: true,
                        fillColor: Colors.grey.shade800,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: _openFilterBottomSheet,
                  ),
                ],
              ),
            ),
            _buildTrendingSlider(movieProvider),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                "Now Showing",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black45)
                  ],
                ),
              ),
            ),
            _buildMovieList(filteredAvailableMovies),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                "Coming Soon",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black45)
                  ],
                ),
              ),
            ),
            _buildMovieList(filteredComingSoonMovies),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
