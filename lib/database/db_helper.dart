import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  static Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'ticket.db');

    return await openDatabase(
      path,
      version: 2,

      onCreate: (db, version) async {
        // USERS
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT UNIQUE,
            password TEXT,
            role TEXT DEFAULT 'user'
          )
        ''');

        // TICKETS
        await db.execute('''
          CREATE TABLE tickets(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            status TEXT DEFAULT 'Pending',
            image_path TEXT,
            assigned_to TEXT,
            created_by TEXT,
            created_at TEXT
          )
        ''');

        // HISTORY
        await db.execute('''
          CREATE TABLE ticket_history(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            ticket_id INTEGER,
            action TEXT,
            actor TEXT,
            timestamp TEXT
          )
        ''');

        // SEED USER
        await db.insert('users', {
          'name': 'Admin Sistem',
          'email': 'admin@helpdesk.com',
          'password': 'admin123',
          'role': 'admin'
        });

        await db.insert('users', {
          'name': 'Helpdesk Support',
          'email': 'helpdesk@helpdesk.com',
          'password': 'helpdesk123',
          'role': 'helpdesk'
        });

        await db.insert('users', {
          'name': 'User Biasa',
          'email': 'user@helpdesk.com',
          'password': 'user123',
          'role': 'user'
        });
      },

      // ✅ FIX DI SINI (TIDAK ADA LOOP)
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS tickets');
          await db.execute('DROP TABLE IF EXISTS users');
          await db.execute('DROP TABLE IF EXISTS ticket_history');

          // BUAT ULANG (JANGAN PANGGIL initDB!)
          await db.execute('''
            CREATE TABLE users(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT,
              email TEXT UNIQUE,
              password TEXT,
              role TEXT DEFAULT 'user'
            )
          ''');

          await db.execute('''
            CREATE TABLE tickets(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              title TEXT,
              description TEXT,
              status TEXT DEFAULT 'Pending',
              image_path TEXT,
              assigned_to TEXT,
              created_by TEXT,
              created_at TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE ticket_history(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              ticket_id INTEGER,
              action TEXT,
              actor TEXT,
              timestamp TEXT
            )
          ''');

          // SEED ULANG
          await db.insert('users', {
            'name': 'Admin Sistem',
            'email': 'admin@helpdesk.com',
            'password': 'admin123',
            'role': 'admin'
          });

          await db.insert('users', {
            'name': 'Helpdesk Support',
            'email': 'helpdesk@helpdesk.com',
            'password': 'helpdesk123',
            'role': 'helpdesk'
          });

          await db.insert('users', {
            'name': 'User Biasa',
            'email': 'user@helpdesk.com',
            'password': 'user123',
            'role': 'user'
          });
        }
      },
    );
  }

  // ===== LOGIN =====
  static Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    return result.isNotEmpty ? result.first : null;
  }

  // ===== REGISTER =====
  static Future<bool> registerUser(String name, String email, String password) async {
    try {
      final db = await database;

      await db.insert('users', {
        'name': name,
        'email': email,
        'password': password,
        'role': 'user',
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  // ===== RESET PASSWORD =====
  static Future<bool> resetPassword(String email, String newPassword) async {
    final db = await database;

    final result =
    await db.query('users', where: 'email = ?', whereArgs: [email]);

    if (result.isEmpty) return false;

    await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );

    return true;
  }

  // ===== GET HELPDESK =====
  static Future<List<Map<String, dynamic>>> getAllHelpdesk() async {
    final db = await database;
    return await db.query(
      'users',
      where: "role = 'helpdesk' OR role = 'admin'",
    );
  }

  // ===== INSERT TICKET =====
  static Future<int> insertTicket(Map<String, dynamic> data) async {
    final db = await database;

    final id = await db.insert('tickets', data);

    await db.insert('ticket_history', {
      'ticket_id': id,
      'action': 'Tiket dibuat',
      'actor': data['created_by'] ?? 'User',
      'timestamp': DateTime.now().toIso8601String(),
    });

    return id;
  }

  // ===== GET TICKETS =====
  static Future<List<Map<String, dynamic>>> getTickets() async {
    final db = await database;
    return await db.query('tickets', orderBy: 'id DESC');
  }

  static Future<List<Map<String, dynamic>>> getTicketsByUser(String email) async {
    final db = await database;

    return await db.query(
      'tickets',
      where: 'created_by = ?',
      whereArgs: [email],
      orderBy: 'id DESC',
    );
  }

  // ===== UPDATE STATUS =====
  static Future<void> updateTicketStatus(int id, String status, String actor) async {
    final db = await database;

    await db.update(
      'tickets',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );

    await db.insert('ticket_history', {
      'ticket_id': id,
      'action': 'Status diubah menjadi $status',
      'actor': actor,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ===== ASSIGN =====
  static Future<void> assignTicket(int id, String assignedTo, String actor) async {
    final db = await database;

    await db.update(
      'tickets',
      {'assigned_to': assignedTo},
      where: 'id = ?',
      whereArgs: [id],
    );

    await db.insert('ticket_history', {
      'ticket_id': id,
      'action': 'Tiket di-assign ke $assignedTo',
      'actor': actor,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ===== HISTORY =====
  static Future<List<Map<String, dynamic>>> getTicketHistory(int ticketId) async {
    final db = await database;

    return await db.query(
      'ticket_history',
      where: 'ticket_id = ?',
      whereArgs: [ticketId],
      orderBy: 'id ASC',
    );
  }

  // ===== STATS =====
  static Future<Map<String, int>> getTicketStats() async {
    final db = await database;

    final all = await db.query('tickets');

    int pending = all.where((t) => t['status'] == 'Pending').length;
    int proses = all.where((t) => t['status'] == 'Proses').length;
    int selesai = all.where((t) => t['status'] == 'Selesai').length;

    return {
      'total': all.length,
      'pending': pending,
      'proses': proses,
      'selesai': selesai,
    };
  }
}