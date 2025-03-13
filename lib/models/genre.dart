class Genre {
  int? id;
  String name;

  Genre({this.id, required this.name});

  // Convert a Genre object into a Map (for database operations)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  // Convert a Map into a Genre object
  factory Genre.fromMap(Map<String, dynamic> map) {
    return Genre(
      id: map['id'],
      name: map['name'],
    );
  }
}
