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
    final path = join(await getDatabasesPath(), 'cinemate_bookinnnnng.db');
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
    password TEXT NOT NULL,
    profile_image TEXT  -- New column for storing the profile image path
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
        seat_number TEXT NOT NULL,
        row_number INTEGER NOT NULL,
        column_number INTEGER NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE showtime_seats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        showtime_id INTEGER NOT NULL,
        seat_id INTEGER NOT NULL,
        is_booked INTEGER DEFAULT 0,
        FOREIGN KEY (showtime_id) REFERENCES showtimes (id) ON DELETE CASCADE,
        FOREIGN KEY (seat_id) REFERENCES seats (id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        showtime_id INTEGER NOT NULL,
        seat_ids TEXT NOT NULL,
        total REAL NOT NULL,
        booked_at TEXT NOT NULL,
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
    List<String> genres = [
      'Action',
      'Comedy',
      'Drama',
      'Horror',
      'Sci-Fi',
      'Romance',
      'Thriller'
    ];

    for (var genre in genres) {
      await db.insert('genres', {'name': genre});
    }

    // Sample movies
    await db.insert('movies', {
      'title': 'Dune: Part Two',
      'description':
          'Paul Atreides unites with Chani and the Fremen as he seeks revenge against those who destroyed his family.',
      'poster_url':
          'https://www.movieposters.com/cdn/shop/files/scan_92952849-df3d-4305-9798-5529fc91c78f_480x.progressive.jpg?v=1707837263',
      'trailer_url': 'https://www.youtube.com/watch?v=Way9Dexny3w',
      'rating': 0.0, // Upcoming
      'actors': 'Timothée Chalamet, Zendaya, Rebecca Ferguson',
      'release_date': '2025-03-01'
    });

    await db.insert('movies', {
      'title': 'Deadpool & Wolverine',
      'description':
          'Deadpool and Wolverine join forces in a multiverse adventure filled with humor, action, and surprises.',
      'poster_url':
          'https://www.movieposters.com/cdn/shop/files/deadpool-wolverine_ghl6lfru_480x.progressive.jpg?v=1728072513',
      'trailer_url': 'https://www.youtube.com/watch?v=73_1biulkYk',
      'rating': 0.0, // Upcoming
      'actors': 'Ryan Reynolds, Hugh Jackman, Morena Baccarin',
      'release_date': '2025-07-26'
    });

    await db.insert('movies', {
      'title': 'Oppenheimer',
      'description':
          'The story of J. Robert Oppenheimer and his role in developing the atomic bomb.',
      'poster_url':
          'https://www.movieposters.com/cdn/shop/files/oppenheimer_fwt2opqh_480x.progressive.jpg?v=1705953716',
      'trailer_url':
          'https://www.youtube.com/watch?v=uYPbbksJxIg&pp=ygUSb3BlbmhlaW1lciB0cmFpbGVy',
      'rating': 8.6,
      'actors': 'Cillian Murphy, Robert Downey Jr., Emily Blunt',
      'release_date': '2023-07-21'
    });

    await db.insert('movies', {
      'title': 'Godzilla x Kong: The New Empire',
      'description':
          'The mighty Kong and the fearsome Godzilla team up to face a colossal undiscovered threat lurking within our world.',
      'poster_url':
          'https://www.movieposters.com/cdn/shop/files/scan002_af1807b5-a755-42a7-9cf6-f08c0d66e2cf_480x.progressive.jpg?v=1710876259',
      'trailer_url':
          'https://www.youtube.com/watch?v=lV1OOlGwExM&pp=ygUnR29kemlsbGEgeCBLb25nOiBUaGUgTmV3IEVtcGlyZSB0cmFpbGVy',
      'rating': 0.0, // Upcoming
      'actors': 'Rebecca Hall, Brian Tyree Henry, Dan Stevens',
      'release_date': '2025-03-29'
    });

    await db.insert('movies', {
      'title': 'The Batman',
      'description':
          'Batman ventures into Gotham’s underworld when a sadistic killer leaves behind a trail of cryptic clues.',
      'poster_url':
          'https://www.movieposters.com/cdn/shop/products/the-batman_tgstxmov_480x.progressive.jpg?v=1641930817',
      'trailer_url':
          'https://www.youtube.com/watch?v=mqqft2x_Aa4&pp=ygUSVGhlIEJhdG1hbiB0cmFpbGVy',
      'rating': 7.9,
      'actors': 'Robert Pattinson, Zoë Kravitz, Paul Dano',
      'release_date': '2022-03-04'
    });

    await db.insert('movies', {
      'title': 'Mission: Impossible – Final Reckoning Part Two',
      'description':
          'Ethan Hunt embarks on another thrilling adventure full of espionage and impossible stunts.',
      'poster_url':
          'https://www.movieposters.com/cdn/shop/files/mission_impossible__the_final_reckoning_480x.progressive.jpg?v=1733261099',
      'trailer_url':
          'https://www.youtube.com/watch?v=NOhDyUmT9z0&pp=ygU3TWlzc2lvbjogSW1wb3NzaWJsZSDigJMgRGVhZCBSZWNrb25pbmcgUGFydCBUd28gdHJhaWxlcg%3D%3D',
      'rating': 0.0, // Upcoming
      'actors': 'Tom Cruise, Hayley Atwell, Ving Rhames',
      'release_date': '2025-06-28'
    });

    await db.insert('movies', {
      'title': 'Wonka',
      'description':
          'The story of Willy Wonka’s early days as a chocolate maker and his journey to becoming the greatest chocolatier.',
      'poster_url':
          'https://www.movieposters.com/cdn/shop/files/scan_1909c333-7137-424f-bf5d-1755ef49c574_480x.progressive.jpg?v=1701722300',
      'trailer_url':
          'https://www.youtube.com/watch?v=otNh9bTjXWg&pp=ygUNd29ua2EgdHJhaWxlcg%3D%3D',
      'rating': 7.5,
      'actors': 'Timothée Chalamet, Hugh Grant, Olivia Colman',
      'release_date': '2023-12-15'
    });

    await db.insert('movies', {
      'title': 'The Marvels',
      'description':
          'Carol Danvers, Kamala Khan, and Monica Rambeau must unite to save the universe in this cosmic adventure.',
      'poster_url':
          'https://www.movieposters.com/cdn/shop/files/the-marvels_pnk1tryd_480x.progressive.jpg?v=1692041579',
      'trailer_url':
          'https://www.youtube.com/watch?v=wS_qbDztgVY&pp=ygUSVGhlIE1hcnZlbHN0cmFpbGVy',
      'rating': 6.3,
      'actors': 'Brie Larson, Iman Vellani, Teyonah Parris',
      'release_date': '2023-11-10'
    });

    await db.insert('movies', {
      'title': 'Avatar: The Way of Water',
      'description':
          'Jake Sully and Neytiri face new threats and explore the oceans of Pandora in this visually stunning sequel.',
      'poster_url':
          'https://www.movieposters.com/cdn/shop/files/avatar-the-way-of-water_zou5uxd9_480x.progressive.jpg?v=1704285772',
      'trailer_url':
          'https://www.youtube.com/watch?v=d9MyW72ELq0&pp=ygUYQXZhdGFyOiBUaGUgV2F5IG9mIFdhdGVy',
      'rating': 7.6,
      'actors': 'Sam Worthington, Zoe Saldaña, Sigourney Weaver',
      'release_date': '2022-12-16'
    });

    await db.insert('movies', {
      'title': 'Spider-Man: Beyond the Spider-Verse',
      'description':
          'Miles Morales returns in the next chapter of the Oscar-winning animated Spider-Verse saga.',
      'poster_url':
          'https://www.google.com/url?sa=i&url=https%3A%2F%2Fencrypted-tbn2.gstatic.com%2Fimages%3Fq%3Dtbn%3AANd9GcRm-NzmwrzG5Wvp-XSeTwhNo2U_vXAJAxd6gJJEq_ydqrCpXYCk&psig=AOvVaw3CEooXDeb_RMiMo5LxL5SO&ust=1740427858678000&source=images&cd=vfe&opi=89978449&ved=0CBAQjRxqFwoTCLDToZbN2osDFQAAAAAdAAAAABAE',
      'trailer_url':
          'https://www.youtube.com/watch?v=D7pQ-S8QlC8&pp=ygUjU3BpZGVyLU1hbjogQmV5b25kIHRoZSBTcGlkZXItVmVyc2U%3D',
      'rating': 0.0, // Upcoming
      'actors': 'Shameik Moore, Hailee Steinfeld, Oscar Isaac',
      'release_date': '2025-05-02'
    });

    // Sample users
    // await db.insert('users', {
    //   'name': 'John Doe',
    //   'email': 'john@example.com',
    //   'phone_number': '1234567890',
    //   'password': 'password123',
    //   'gender': 'Male',
    //   'date_of_birth': '1990-05-15'
    // });

    // await db.insert('users', {
    //   'name': 'Jane Smith',
    //   'email': 'jane@example.com',
    //   'phone_number': '9876543210',
    //   'password': 'password456',
    //   'gender': 'Female',
    //   'date_of_birth': '1988-08-22'
    // });

    // Sample showtimes
    final List<String> showtimes = [
      '11:00 am',
      '3:00 pm',
      '7:00 pm',
      '10:30 pm'
    ];
    final List<int> movieIds = [
      1,
      2,
      3,
      4,
      5,
      6,
      7,
      8,
      9,
      10
    ]; // Assuming you have 10 movies

    for (int row = 1; row <= 10; row++) {
      for (int column = 1; column <= 20; column++) {
        await db.insert('seats', {
          'seat_number': 'R${row}C${column}',
          'row_number': row,
          'column_number': column,
        });
      }
    }

    // Insert showtimes and link seats
    final List<int> seatIds =
        List.generate(200, (index) => index + 1); // Assuming 200 seats
    final DateTime now = DateTime.now();
    for (int i = 0; i < 10; i++) {
      final DateTime date = now.add(Duration(days: i));
      final String formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

      for (int movieId in movieIds) {
        for (String time in showtimes) {
          // Insert showtime
          final int showtimeId = await db.insert('showtimes', {
            'movie_id': movieId,
            'date': formattedDate,
            'time': time,
          });

          // Link seats to showtime
          for (int seatId in seatIds) {
            await db.insert('showtime_seats', {
              'showtime_id': showtimeId,
              'seat_id': seatId,
              'is_booked': 0,
            });
          }
        }
      }
    }

    // Mapping movies to genres
    await db.insert('movie_genres',
        {'movie_id': 1, 'genre_id': 1}); // Dune: Part Two - Action
    await db.insert('movie_genres',
        {'movie_id': 1, 'genre_id': 5}); // Dune: Part Two - Sci-Fi

    await db.insert('movie_genres',
        {'movie_id': 2, 'genre_id': 1}); // Deadpool & Wolverine - Action
    await db.insert('movie_genres',
        {'movie_id': 2, 'genre_id': 2}); // Deadpool & Wolverine - Comedy

    await db.insert(
        'movie_genres', {'movie_id': 3, 'genre_id': 3}); // Oppenheimer - Drama
    await db.insert('movie_genres',
        {'movie_id': 3, 'genre_id': 8}); // Oppenheimer - Biography

    await db.insert('movie_genres', {
      'movie_id': 4,
      'genre_id': 1
    }); // Godzilla x Kong: The New Empire - Action
    await db.insert('movie_genres', {
      'movie_id': 4,
      'genre_id': 5
    }); // Godzilla x Kong: The New Empire - Sci-Fi

    await db.insert(
        'movie_genres', {'movie_id': 5, 'genre_id': 1}); // The Batman - Action
    await db.insert('movie_genres',
        {'movie_id': 5, 'genre_id': 7}); // The Batman - Thriller

    await db.insert('movie_genres', {
      'movie_id': 6,
      'genre_id': 1
    }); // Mission: Impossible – Final Reckoning Part Two - Action
    await db.insert('movie_genres', {
      'movie_id': 6,
      'genre_id': 7
    }); // Mission: Impossible – Final Reckoning Part Two - Thriller

    await db.insert(
        'movie_genres', {'movie_id': 7, 'genre_id': 2}); // Wonka - Comedy
    await db.insert(
        'movie_genres', {'movie_id': 7, 'genre_id': 3}); // Wonka - Drama

    await db.insert(
        'movie_genres', {'movie_id': 8, 'genre_id': 1}); // The Marvels - Action
    await db.insert(
        'movie_genres', {'movie_id': 8, 'genre_id': 5}); // The Marvels - Sci-Fi

    await db.insert('movie_genres',
        {'movie_id': 9, 'genre_id': 5}); // Avatar: The Way of Water - Sci-Fi
    await db.insert('movie_genres',
        {'movie_id': 9, 'genre_id': 6}); // Avatar: The Way of Water - Adventure

    await db.insert('movie_genres', {
      'movie_id': 10,
      'genre_id': 1
    }); // Spider-Man: Beyond the Spider-Verse - Action
    await db.insert('movie_genres', {
      'movie_id': 10,
      'genre_id': 5
    }); // Spider-Man: Beyond the Spider-Verse - Sci-Fi
    await db.insert('movie_genres', {
      'movie_id': 10,
      'genre_id': 2
    }); // Spider-Man: Beyond the Spider-Verse - Comedy
  }
}
