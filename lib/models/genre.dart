class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  factory Genre.fromMap(Map<String, dynamic> map) =>
      Genre(id: map['id'], name: map['name']);
}
