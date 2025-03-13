import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child:
              const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        ),
        title: const Text(
          'Movie Detail',
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<Movie?>(
        future: movieDao.getMovieById(movieId),
        builder: (context, movieSnapshot) {
          if (movieSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (movieSnapshot.hasError) {
            return Center(
                child: Text('Error: ${movieSnapshot.error}',
                    style: const TextStyle(color: Colors.white)));
          } else if (!movieSnapshot.hasData || movieSnapshot.data == null) {
            return const Center(
                child: Text('Movie not found',
                    style: TextStyle(color: Colors.white)));
          } else {
            final Movie movie = movieSnapshot.data!;
            final DateTime releaseDate = DateTime.parse(movie.releaseDate);
            final bool isAvailable = releaseDate.isBefore(DateTime.now());

            return FutureBuilder<List<String>>(
              future: movieDao.getGenresForMovie(movieId),
              builder: (context, genreSnapshot) {
                List<String> genres = genreSnapshot.data ?? [];

                return Stack(
                  children: [
                    // Blurred Background (less blur)
                    Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(movie.posterUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(color: Colors.black.withOpacity(0.5)),
                      ),
                    ),
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Trailer in Card
                          Card(
                            color: Colors.black,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: SizedBox(
                                height: 220,
                                child:
                                    TrailerPlayer(trailerUrl: movie.trailerUrl),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Movie Title (slightly larger)
                          Text(
                            movie.title,
                            style: const TextStyle(
                              fontSize: 30,
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
                          const SizedBox(height: 20),
                          // Description & Actors
                          const Text(
                            'Description',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            movie.description,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14, height: 1.5),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Actors: ${movie.actors.join(', ')}",
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 20),
                          // Inline rating and genre with labels, icons, and vertical divider
                          if (isAvailable)
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                const Text("Rating:",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12)),
                                const SizedBox(width: 4),
                                Text("${movie.rating} / 10",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12)),
                                const SizedBox(width: 8),
                                Container(
                                  height: 16,
                                  width: 1,
                                  color: Colors.white54,
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.videocam_rounded,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                const Text("Genre:",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12)),
                                const SizedBox(width: 4),
                                Text(genres.join(', '),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12)),
                              ],
                            )
                          else
                            Row(
                              children: [
                                Icon(Icons.videocam_rounded,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                const Text("Genre:",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12)),
                                const SizedBox(width: 4),
                                Text(genres.join(', '),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12)),
                              ],
                            ),
                          const SizedBox(height: 30),
                          // Reservation button or Coming Soon message
                          Center(
                            child: isAvailable
                                ? ElevatedButton(
                                    onPressed: () {
                                      if (userProvider.isAuthenticated) {
                                        Navigator.pushNamed(
                                            context, "/select-showtime",
                                            arguments: movie.id);
                                      } else {
                                        Navigator.pushNamed(context, "/login");
                                      }
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
                                    child: const Text(
                                      'Get Reservation',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.black),
                                    ),
                                  )
                                : Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        text:
                                            'This movie will be available on ',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: movie.releaseDate,
                                            style: const TextStyle(
                                              color: Colors.orangeAccent,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}

class TrailerPlayer extends StatefulWidget {
  final String trailerUrl;
  const TrailerPlayer({Key? key, required this.trailerUrl}) : super(key: key);

  @override
  _TrailerPlayerState createState() => _TrailerPlayerState();
}

class _TrailerPlayerState extends State<TrailerPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    String? videoId = YoutubePlayer.convertUrlToId(widget.trailerUrl);
    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? "",
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.orange,
    );
  }
}
