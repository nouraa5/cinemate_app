import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  // Get database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // Initialize database
  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'cinemate_booking2.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Create tables
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone_number TEXT NOT NULL,
        gender TEXT NOT NULL,
        date_of_birth TEXT NOT NULL,
        password TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE movies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        poster_url TEXT,
        trailer_url TEXT,
        rating REAL DEFAULT 0,
        actors TEXT,
        release_date TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE genres (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE movie_genres (
        movie_id INTEGER,
        genre_id INTEGER,
        FOREIGN KEY (movie_id) REFERENCES movies (id) ON DELETE CASCADE,
        FOREIGN KEY (genre_id) REFERENCES genres (id) ON DELETE CASCADE,
        PRIMARY KEY (movie_id, genre_id)
      );
    ''');

    await db.execute('''
      CREATE TABLE showtimes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        movie_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        FOREIGN KEY (movie_id) REFERENCES movies (id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE seats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        showtime_id INTEGER NOT NULL,
        seat_number TEXT NOT NULL,
        is_booked INTEGER DEFAULT 0,
        FOREIGN KEY (showtime_id) REFERENCES showtimes (id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        showtime_id INTEGER NOT NULL,
        seats TEXT NOT NULL,
        total_price REAL NOT NULL,
        qr_code TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (showtime_id) REFERENCES showtimes (id) ON DELETE CASCADE
      );
    ''');

    // Insert sample data after creating tables
    await _insertSampleData(db);
  }

  // Insert sample data into the database
  static Future<void> _insertSampleData(Database db) async {
    // Sample genres
    await db.insert('genres', {'name': 'Action'});
    await db.insert('genres', {'name': 'Comedy'});
    await db.insert('genres', {'name': 'Drama'});
    await db.insert('genres', {'name': 'Sci-Fi'});
    await db.insert('genres', {'name': 'Thriller'});

    // Sample movies
    await db.insert('movies', {
      'title': 'Dune: Part Two',
      'description':
          'Paul Atreides unites with Chani and the Fremen as he seeks revenge against those who destroyed his family.',
      'poster_url':
          'https://image.tmdb.org/t/p/w500/8ZtvqZ7sO9v21LJFriC8jP3kE5Y.jpg',
      'trailer_url': 'https://www.youtube.com/watch?v=Way9Dexny3w',
      'rating': 0.0, // Upcoming
      'actors': 'Timothée Chalamet, Zendaya, Rebecca Ferguson',
      'release_date': '2025-03-01'
    });

    await db.insert('movies', {
      'title': 'Deadpool & Wolverine',
      'description':
          'Deadpool and Wolverine join forces in a multiverse adventure filled with humor, action, and surprises.',
      'poster_url': 'https://image.tmdb.org/t/p/w500/your_poster_url.jpg',
      'trailer_url': 'https://www.youtube.com/watch?v=your_trailer_url',
      'rating': 0.0, // Upcoming
      'actors': 'Ryan Reynolds, Hugh Jackman, Morena Baccarin',
      'release_date': '2025-07-26'
    });

    await db.insert('movies', {
      'title': 'Oppenheimer',
      'description':
          'The story of J. Robert Oppenheimer and his role in developing the atomic bomb.',
      'poster_url':
          'https://image.tmdb.org/t/p/w500/8GVpIEBqlRBdx2Qfx7fFIM7FXuB.jpg',
      'trailer_url': 'https://www.youtube.com/watch?v=bK6ldnjE3Y0',
      'rating': 8.6,
      'actors': 'Cillian Murphy, Robert Downey Jr., Emily Blunt',
      'release_date': '2023-07-21'
    });

    await db.insert('movies', {
      'title': 'Godzilla x Kong: The New Empire',
      'description':
          'The mighty Kong and the fearsome Godzilla team up to face a colossal undiscovered threat lurking within our world.',
      'poster_url': 'https://image.tmdb.org/t/p/w500/your_poster_url.jpg',
      'trailer_url': 'https://www.youtube.com/watch?v=your_trailer_url',
      'rating': 0.0, // Upcoming
      'actors': 'Rebecca Hall, Brian Tyree Henry, Dan Stevens',
      'release_date': '2025-03-29'
    });

    await db.insert('movies', {
      'title': 'The Batman',
      'description':
          'Batman ventures into Gotham’s underworld when a sadistic killer leaves behind a trail of cryptic clues.',
      'poster_url':
          'https://image.tmdb.org/t/p/w500/74xTEgt7R36Fpooo50r9T25onhq.jpg',
      'trailer_url': 'https://www.youtube.com/watch?v=mqqft2x_Aa4',
      'rating': 7.9,
      'actors': 'Robert Pattinson, Zoë Kravitz, Paul Dano',
      'release_date': '2022-03-04'
    });

    await db.insert('movies', {
      'title': 'Mission: Impossible – Dead Reckoning Part Two',
      'description':
          'Ethan Hunt embarks on another thrilling adventure full of espionage and impossible stunts.',
      'poster_url': 'https://image.tmdb.org/t/p/w500/your_poster_url.jpg',
      'trailer_url': 'https://www.youtube.com/watch?v=your_trailer_url',
      'rating': 0.0, // Upcoming
      'actors': 'Tom Cruise, Hayley Atwell, Ving Rhames',
      'release_date': '2025-06-28'
    });

    await db.insert('movies', {
      'title': 'Wonka',
      'description':
          'The story of Willy Wonka’s early days as a chocolate maker and his journey to becoming the greatest chocolatier.',
      'poster_url':
          'https://image.tmdb.org/t/p/w500/fbrzO4D28JL9Agj9jzNmnTYuqak.jpg',
      'trailer_url': 'https://www.youtube.com/watch?v=otNh9bTjXWg',
      'rating': 7.5,
      'actors': 'Timothée Chalamet, Hugh Grant, Olivia Colman',
      'release_date': '2023-12-15'
    });

    await db.insert('movies', {
      'title': 'The Marvels',
      'description':
          'Carol Danvers, Kamala Khan, and Monica Rambeau must unite to save the universe in this cosmic adventure.',
      'poster_url': 'https://image.tmdb.org/t/p/w500/your_poster_url.jpg',
      'trailer_url': 'https://www.youtube.com/watch?v=your_trailer_url',
      'rating': 6.3,
      'actors': 'Brie Larson, Iman Vellani, Teyonah Parris',
      'release_date': '2023-11-10'
    });

    await db.insert('movies', {
      'title': 'Avatar: The Way of Water',
      'description':
          'Jake Sully and Neytiri face new threats and explore the oceans of Pandora in this visually stunning sequel.',
      'poster_url':
          'https://image.tmdb.org/t/p/w500/t6HIqrRAclMCA60NsSmeqe9RmNV.jpg',
      'trailer_url': 'https://www.youtube.com/watch?v=d9MyW72ELq0',
      'rating': 7.6,
      'actors': 'Sam Worthington, Zoe Saldaña, Sigourney Weaver',
      'release_date': '2022-12-16'
    });

    await db.insert('movies', {
      'title': 'Spider-Man: Beyond the Spider-Verse',
      'description':
          'Miles Morales returns in the next chapter of the Oscar-winning animated Spider-Verse saga.',
      'poster_url': 'https://image.tmdb.org/t/p/w500/your_poster_url.jpg',
      'trailer_url': 'https://www.youtube.com/watch?v=your_trailer_url',
      'rating': 5.8, // Upcoming
      'actors': 'Shameik Moore, Hailee Steinfeld, Oscar Isaac',
      'release_date': '2024-05-02'
    });

    // Sample users
    await db.insert('users', {
      'name': 'John Doe',
      'email': 'john@example.com',
      'phone_number': '1234567890',
      'password': 'password123',
      'gender': 'Male',
      'date_of_birth': '1990-05-15'
    });

    await db.insert('users', {
      'name': 'Jane Smith',
      'email': 'jane@example.com',
      'phone_number': '9876543210',
      'password': 'password456',
      'gender': 'Female',
      'date_of_birth': '1988-08-22'
    });

    // Sample showtimes
    await db.insert('showtimes', {
      'movie_id': 1,
      'date': '2025-02-20',
      'time': '18:30',
    });

    await db.insert('showtimes', {
      'movie_id': 2,
      'date': '2025-02-21',
      'time': '21:00',
    });

    // Sample seats
    for (int row = 1; row <= 10; row++) {
      for (int column = 1; column <= 20; column++) {
        await db.insert('seats', {
          'showtime_id': 1,
          'seat_number': 'R${row}C${column}',
          'is_booked': 0,
        });
      }
    }

    // Sample booking
    await db.insert('bookings', {
      'user_id': 1,
      'showtime_id': 1,
      'seats': 'R1C1, R1C2',
      'total_price': 25.0,
      'qr_code': 'qr_code_1234',
    });
  }
}
