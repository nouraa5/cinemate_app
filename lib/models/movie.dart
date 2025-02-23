class Movie {
  final int id;
  final String title;
  final String description;
  final String posterUrl;
  final String trailerUrl;
  final double rating;
  final List<String> actors;
  final List<int> genreIds;
  final String releaseDate; // New field

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    required this.trailerUrl,
    required this.rating,
    required this.actors,
    required this.genreIds,
    required this.releaseDate, // Add this
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'poster_url': posterUrl,
      'trailer_url': trailerUrl,
      'rating': rating,
      'actors': actors.join(','),
      'release_date': releaseDate, // Add this
    };
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      posterUrl: map['poster_url'],
      trailerUrl: map['trailer_url'],
      rating: map['rating'],
      actors: map['actors'].split(','),
      genreIds: [], // Will be fetched separately
      releaseDate: map['release_date'], // Add this
    );
  }
}
