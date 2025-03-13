class Showtime {
  final int id;
  final int movieId;
  final String date;
  final String time;

  Showtime({
    required this.id,
    required this.movieId,
    required this.date,
    required this.time,
  });

  factory Showtime.fromMap(Map<String, dynamic> map) {
    return Showtime(
      id: map['id'],
      movieId: map['movie_id'],
      date: map['date'],
      time: map['time'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'movie_id': movieId,
      'date': date,
      'time': time,
    };
  }
}
