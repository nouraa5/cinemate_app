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

  Map<String, dynamic> toMap() => {
        'id': id,
        'movie_id': movieId,
        'date': date,
        'time': time,
      };

  factory Showtime.fromMap(Map<String, dynamic> map) => Showtime(
        id: map['id'],
        movieId: map['movie_id'],
        date: map['date'],
        time: map['time'],
      );
}
