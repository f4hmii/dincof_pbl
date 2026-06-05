import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:developer' as developer;
import '../models/coffee.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._();
  static Database? _database;
  static Future<Database>? _dbFuture;

  DBHelper._();

  factory DBHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _dbFuture ??= _initDB();
    _database = await _dbFuture;
    return _database!;
  }

  Future<Database> _initDB() async {
    // Inisialisasi FFI untuk desktop Windows/Linux/macOS
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      developer.log('✅ SQLite FFI initialized for desktop platform');
    }

    String dbPath;

    // Untuk Windows desktop, gunakan lokasi penyimpanan yang diketahui
    if (Platform.isWindows) {
      final documentsPath = Platform.environment['USERPROFILE'] ?? '.';
      dbPath = join(documentsPath, 'Dincoff', 'dincoff.db');
      developer.log('📁 Using Windows Documents path');
    } else {
      final path = await getDatabasesPath();
      dbPath = join(path, 'dincoff.db');
    }

    developer.log('📁 Database directory: ${dirname(dbPath)}');
    developer.log('📁 Full database path: $dbPath');

    // Buat direktori jika belum ada
    final dir = Directory(dirname(dbPath));
    if (!dir.existsSync()) {
      try {
        await dir.create(recursive: true);
        developer.log('✅ Database directory created');
      } catch (e) {
        developer.log('❌ Failed to create directory: $e');
      }
    }

    final file = File(dbPath);
    if (await file.exists()) {
      developer.log('✅ Database file already exists');
    } else {
      developer.log(
        '⚠️ Database file does not exist yet, will be created on first open',
      );
    }

    final db = await openDatabase(
      dbPath,
      version: 3,
      onCreate: (db, version) async {
        developer.log('🔨 Creating new database schema...');
        await db.execute('''
          CREATE TABLE coffees (
            id TEXT PRIMARY KEY,
            name TEXT,
            type TEXT,
            description TEXT,
            price REAL,
            imagePath TEXT,
            rating REAL
          )
        ''');

        await db.execute('''
          CREATE TABLE orders (
            id TEXT PRIMARY KEY,
            userId TEXT,
            totalPrice REAL,
            status TEXT,
            createdAt TEXT,
            updatedAt TEXT,
            items TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE cartItems (
            id TEXT PRIMARY KEY,
            coffeeId TEXT,
            quantity INTEGER,
            addedAt TEXT,
            FOREIGN KEY(coffeeId) REFERENCES coffees(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            username TEXT,
            email TEXT,
            password TEXT,
            role TEXT,
            createdAt TEXT
          )
        ''');
        developer.log('✅ Database schema created successfully');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        developer.log('🔨 Upgrading database from $oldVersion to $newVersion');
        if (oldVersion < 2) {
          try {
            await db.execute('ALTER TABLE users ADD COLUMN password TEXT');
            developer.log('✅ Added password column to users table');
          } catch (e) {
            developer.log('❌ Error adding password column: $e');
          }
        }
        if (oldVersion < 3) {
          try {
            await db.execute('ALTER TABLE orders ADD COLUMN items TEXT');
            developer.log('✅ Added items column to orders table');
          } catch (e) {
            developer.log('❌ Error adding items column: $e');
          }
        }
      },
      onOpen: (db) async {
        developer.log('✅ Database opened successfully');
      },
    );

    developer.log('✅ Database initialized');
    return db;
  }

  Future<int> insertCoffee(Coffee coffee) async {
    final db = await database;
    return await db.insert('coffees', {
      'id': coffee.id,
      'name': coffee.name,
      'type': coffee.type,
      'description': coffee.description,
      'price': coffee.price,
      'imagePath': coffee.imagePath,
      'rating': coffee.rating,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Coffee>> getAllCoffees() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('coffees');
    return List.generate(maps.length, (i) {
      return Coffee(
        id: maps[i]['id'],
        name: maps[i]['name'],
        type: maps[i]['type'],
        description: maps[i]['description'],
        price: maps[i]['price'],
        imagePath: maps[i]['imagePath'],
        rating: maps[i]['rating'],
      );
    });
  }

  Future<Coffee?> getCoffeeById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'coffees',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Coffee(
        id: maps[0]['id'],
        name: maps[0]['name'],
        type: maps[0]['type'],
        description: maps[0]['description'],
        price: maps[0]['price'],
        imagePath: maps[0]['imagePath'],
        rating: maps[0]['rating'],
      );
    }
    return null;
  }

  Future<int> updateCoffee(Coffee coffee) async {
    final db = await database;
    return await db.update(
      'coffees',
      {
        'name': coffee.name,
        'type': coffee.type,
        'description': coffee.description,
        'price': coffee.price,
        'imagePath': coffee.imagePath,
        'rating': coffee.rating,
      },
      where: 'id = ?',
      whereArgs: [coffee.id],
    );
  }

  Future<int> deleteCoffee(String id) async {
    final db = await database;
    return await db.delete('coffees', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getCoffeeCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM coffees');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<List<Coffee>> getCoffeesByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'coffees',
      where: 'type = ?',
      whereArgs: [type],
    );
    return List.generate(maps.length, (i) {
      return Coffee(
        id: maps[i]['id'],
        name: maps[i]['name'],
        type: maps[i]['type'],
        description: maps[i]['description'],
        price: maps[i]['price'],
        imagePath: maps[i]['imagePath'],
        rating: maps[i]['rating'],
      );
    });
  }

  Future<List<Coffee>> getTopRatedCoffees({int limit = 5}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'coffees',
      orderBy: 'rating DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) {
      return Coffee(
        id: maps[i]['id'],
        name: maps[i]['name'],
        type: maps[i]['type'],
        description: maps[i]['description'],
        price: maps[i]['price'],
        imagePath: maps[i]['imagePath'],
        rating: maps[i]['rating'],
      );
    });
  }

  Future<List<Coffee>> searchCoffeeByName(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'coffees',
      where: 'name LIKE ?',
      whereArgs: ['%$name%'],
    );
    return List.generate(maps.length, (i) {
      return Coffee(
        id: maps[i]['id'],
        name: maps[i]['name'],
        type: maps[i]['type'],
        description: maps[i]['description'],
        price: maps[i]['price'],
        imagePath: maps[i]['imagePath'],
        rating: maps[i]['rating'],
      );
    });
  }

  Future<List<Coffee>> getCoffeesByPriceRange(
    double minPrice,
    double maxPrice,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'coffees',
      where: 'price BETWEEN ? AND ?',
      whereArgs: [minPrice, maxPrice],
    );
    return List.generate(maps.length, (i) {
      return Coffee(
        id: maps[i]['id'],
        name: maps[i]['name'],
        type: maps[i]['type'],
        description: maps[i]['description'],
        price: maps[i]['price'],
        imagePath: maps[i]['imagePath'],
        rating: maps[i]['rating'],
      );
    });
  }

  Future<List<int>> batchInsertCoffees(List<Coffee> coffees) async {
    final db = await database;
    final batch = db.batch();
    for (var coffee in coffees) {
      batch.insert('coffees', {
        'id': coffee.id,
        'name': coffee.name,
        'type': coffee.type,
        'description': coffee.description,
        'price': coffee.price,
        'imagePath': coffee.imagePath,
        'rating': coffee.rating,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    return await batch.commit() as List<int>;
  }

  Future<int> deleteAllCoffees() async {
    final db = await database;
    return await db.delete('coffees');
  }

  Future<int> insertUser(String username, String email, String password) async {
    final db = await database;
    return await db.insert('users', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'username': username,
      'email': email,
      'password': password,
      'role': 'user',
      'createdAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUserById(String id) async {
    final db = await database;
    final result = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users');
  }

  Future<int> deleteUser(String id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> emailExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  Future<int> insertOrder(Order order, String userId) async {
    final db = await database;

    final List<Map<String, dynamic>> itemsJson = order.items.map((item) {
      return {
        'coffeeId': item.coffee.id,
        'coffeeName': item.coffee.name,
        'coffeeType': item.coffee.type,
        'coffeeDescription': item.coffee.description,
        'coffeePrice': item.coffee.price,
        'coffeeImagePath': item.coffee.imagePath,
        'coffeeRating': item.coffee.rating,
        'quantity': item.quantity,
      };
    }).toList();

    final itemsString = jsonEncode(itemsJson);

    return await db.insert('orders', {
      'id': order.id,
      'userId': userId,
      'totalPrice': order.total,
      'status': order.status,
      'createdAt': order.date.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'items': itemsString,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Order>> getAllOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      orderBy: 'createdAt DESC',
    );

    List<Order> orders = [];
    for (var map in maps) {
      final itemsString = map['items'] as String?;
      List<CartItem> items = [];
      if (itemsString != null && itemsString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(itemsString);
        items = decoded.map((itemMap) {
          return CartItem(
            coffee: Coffee(
              id: itemMap['coffeeId'] ?? '',
              name: itemMap['coffeeName'] ?? '',
              type: itemMap['coffeeType'] ?? '',
              description: itemMap['coffeeDescription'] ?? '',
              price: (itemMap['coffeePrice'] as num?)?.toDouble() ?? 0.0,
              imagePath: itemMap['coffeeImagePath'] ?? '',
              rating: (itemMap['coffeeRating'] as num?)?.toDouble() ?? 0.0,
            ),
            quantity: itemMap['quantity'] ?? 1,
          );
        }).toList();
      }

      orders.add(
        Order(
          id: map['id'],
          items: items,
          total: (map['totalPrice'] as num).toDouble(),
          date: DateTime.parse(map['createdAt']),
          status: map['status'],
          userId: map['userId'] as String?,
        ),
      );
    }
    return orders;
  }

  Future<List<Order>> getOrdersByUserId(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );

    List<Order> orders = [];
    for (var map in maps) {
      final itemsString = map['items'] as String?;
      List<CartItem> items = [];
      if (itemsString != null && itemsString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(itemsString);
        items = decoded.map((itemMap) {
          return CartItem(
            coffee: Coffee(
              id: itemMap['coffeeId'] ?? '',
              name: itemMap['coffeeName'] ?? '',
              type: itemMap['coffeeType'] ?? '',
              description: itemMap['coffeeDescription'] ?? '',
              price: (itemMap['coffeePrice'] as num?)?.toDouble() ?? 0.0,
              imagePath: itemMap['coffeeImagePath'] ?? '',
              rating: (itemMap['coffeeRating'] as num?)?.toDouble() ?? 0.0,
            ),
            quantity: itemMap['quantity'] ?? 1,
          );
        }).toList();
      }

      orders.add(
        Order(
          id: map['id'],
          items: items,
          total: (map['totalPrice'] as num).toDouble(),
          date: DateTime.parse(map['createdAt']),
          status: map['status'],
          userId: map['userId'] as String?,
        ),
      );
    }
    return orders;
  }

  Future<int> updateOrderStatus(String orderId, String status) async {
    final db = await database;
    return await db.update(
      'orders',
      {'status': status, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<int> insertOrUpdateCartItem(String coffeeId, int quantity) async {
    final db = await database;
    return await db.insert('cartItems', {
      'id': coffeeId,
      'coffeeId': coffeeId,
      'quantity': quantity,
      'addedAt': DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CartItem>> getAllCartItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cartItems');

    List<CartItem> items = [];
    for (var map in maps) {
      final coffeeId = map['coffeeId'] as String;
      final coffee = await getCoffeeById(coffeeId);
      if (coffee != null) {
        items.add(CartItem(coffee: coffee, quantity: map['quantity'] as int));
      }
    }
    return items;
  }

  Future<int> deleteCartItem(String coffeeId) async {
    final db = await database;
    return await db.delete(
      'cartItems',
      where: 'coffeeId = ?',
      whereArgs: [coffeeId],
    );
  }

  Future<int> deleteAllCartItems() async {
    final db = await database;
    return await db.delete('cartItems');
  }
}
