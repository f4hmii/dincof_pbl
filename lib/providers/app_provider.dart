import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import '../models/coffee.dart';
import '../helpers/db_helper.dart';
import '../helpers/prefs_helper.dart';

class AppProvider extends ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();
  final List<CartItem> _cart = [];
  final List<Order> _orders = [];
  List<Coffee> _coffees = [];
  ThemeMode _themeMode = ThemeMode.system;

  AppProvider() {
    _initialize();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> _initialize() async {
    await _loadTheme();
    await _loadCoffees();
    await _loadOrders();
    await _loadCart();
  }

  Future<void> _loadTheme() async {
    _themeMode = await PrefsHelper.getTheme();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await PrefsHelper.setTheme(_themeMode);
    notifyListeners();
  }

  Future<void> _loadCoffees() async {
    if (kIsWeb) {
      developer.log('Platform: Web - Using sample data');
      if (_coffees.isEmpty) _coffees = List.from(sampleCoffees);
      notifyListeners();
      return;
    }

    try {
      developer.log('Platform: Native - Attempting to load from SQLite');
      _coffees = await _dbHelper.getAllCoffees();
      developer.log('SQLite: Loaded ${_coffees.length} coffees from database');
    } catch (e) {
      developer.log('Database Error: $e', error: e);
      _coffees = [];
    }
    notifyListeners();
  }

  Future<void> _loadOrders() async {
    if (kIsWeb) return;
    try {
      final dbOrders = await _dbHelper.getAllOrders();
      _orders.clear();
      _orders.addAll(dbOrders);
      notifyListeners();
    } catch (e) {
      developer.log('Error loading orders from DB: $e');
    }
  }

  Future<void> _loadCart() async {
    if (kIsWeb) return;
    try {
      final dbCart = await _dbHelper.getAllCartItems();
      _cart.clear();
      _cart.addAll(dbCart);
      notifyListeners();
    } catch (e) {
      developer.log('Error loading cart from DB: $e');
    }
  }

  List<CartItem> get cart => _cart;
  List<Order> get orders => _orders; // All orders (for admin) and user orders
  List<Coffee> get coffees => _coffees;

  // Mengambil daftar pesanan khusus untuk pengguna yang sedang login
  Future<List<Order>> getUserOrders() async {
    final userData = await PrefsHelper.getUserData();
    final email = userData['userEmail'] as String? ?? '';
    final userId = userData['userId'] as String? ?? '';
    final finalUserId = userId.isNotEmpty ? userId : email;

    if (finalUserId.isEmpty) return [];

    if (kIsWeb) {
      return _orders.where((order) => order.userId == finalUserId).toList();
    }

    try {
      return await _dbHelper.getOrdersByUserId(finalUserId);
    } catch (e) {
      developer.log('Error getting user orders: $e');
      return [];
    }
  }

  double get cartTotal {
    return _cart.fold(0, (sum, item) => sum + (item.coffee.price * item.quantity));
  }

  Future<void> addToCart(Coffee coffee) async {
    final index = _cart.indexWhere((item) => item.coffee.id == coffee.id);
    int newQuantity = 1;
    if (index != -1) {
      _cart[index].quantity++;
      newQuantity = _cart[index].quantity;
    } else {
      _cart.add(CartItem(coffee: coffee));
    }
    notifyListeners();

    if (!kIsWeb) {
      try {
        await _dbHelper.insertOrUpdateCartItem(coffee.id, newQuantity);
      } catch (e) {
        developer.log('Error adding item to DB cart: $e');
      }
    }
  }

  Future<void> removeFromCart(CartItem item) async {
    _cart.remove(item);
    notifyListeners();

    if (!kIsWeb) {
      try {
        await _dbHelper.deleteCartItem(item.coffee.id);
      } catch (e) {
        developer.log('Error removing item from DB cart: $e');
      }
    }
  }

  Future<void> updateQuantity(CartItem item, int newQuantity) async {
    if (newQuantity > 0) {
      item.quantity = newQuantity;
      notifyListeners();
      
      if (!kIsWeb) {
        try {
          await _dbHelper.insertOrUpdateCartItem(item.coffee.id, newQuantity);
        } catch (e) {
          developer.log('Error updating quantity in DB cart: $e');
        }
      }
    } else {
      await removeFromCart(item);
    }
  }

  Future<void> clearCart() async {
    _cart.clear();
    notifyListeners();

    if (!kIsWeb) {
      try {
        await _dbHelper.deleteAllCartItems();
      } catch (e) {
        developer.log('Error clearing DB cart: $e');
      }
    }
  }

  Future<void> checkout() async {
    if (_cart.isEmpty) return;

    final userData = await PrefsHelper.getUserData();
    final email = userData['userEmail'] as String? ?? 'guest@dincoff.com';
    final userId = userData['userId'] as String? ?? '';
    final finalUserId = userId.isNotEmpty ? userId : email;

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: List.from(_cart),
      total: cartTotal,
      date: DateTime.now(),
      status: 'Pending Payment',
      userId: finalUserId,
    );

    if (!kIsWeb) {
      try {
        await _dbHelper.insertOrder(order, finalUserId);
      } catch (e) {
        developer.log('Error saving order to DB: $e');
      }
    }

    _orders.insert(0, order);
    await clearCart();
  }

  // --- ADMIN FUNCTIONS ---

  Future<void> addCoffee(Coffee coffee) async {
    if (!kIsWeb) {
      try {
        await _dbHelper.insertCoffee(coffee);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    _coffees.add(coffee);
    notifyListeners();
  }

  Future<void> updateCoffee(Coffee updatedCoffee) async {
    if (!kIsWeb) {
      try {
        await _dbHelper.updateCoffee(updatedCoffee);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    final index = _coffees.indexWhere((c) => c.id == updatedCoffee.id);
    if (index != -1) {
      _coffees[index] = updatedCoffee;
      notifyListeners();
    }
  }

  Future<void> deleteCoffee(String id) async {
    if (!kIsWeb) {
      try {
        await _dbHelper.deleteCoffee(id);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    _coffees.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // Menghitung jumlah total produk kopi yang tersedia
  Future<int> getCoffeeCount() async {
    if (kIsWeb) {
      return _coffees.length;
    }
    try {
      return await _dbHelper.getCoffeeCount();
    } catch (e) {
      developer.log('Error getting coffee count: $e');
      return _coffees.length;
    }
  }

  // Mengambil daftar semua pengguna terdaftar
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    if (kIsWeb) {
      return [
        {
          'id': 'admin-id',
          'username': 'Admin',
          'email': 'admin@dincoff.com',
          'role': 'admin',
          'createdAt': DateTime.now().toIso8601String(),
        },
        {
          'id': 'web-user-id',
          'username': 'Web User',
          'email': 'user@dincoff.com',
          'role': 'user',
          'createdAt': DateTime.now().toIso8601String(),
        }
      ];
    }
    try {
      return await _dbHelper.getAllUsers();
    } catch (e) {
      developer.log('Error getting all users: $e');
      return [];
    }
  }

  // ========== LOGIN & REGISTER FUNCTIONS ==========

  Future<bool> registerUser(String username, String email, String password) async {
    try {
      // Check if email exists
      if (kIsWeb) {
        developer.log('Web Platform: Email validation skipped');
        return true;
      }

      final existingUser = await _dbHelper.getUserByEmail(email);
      if (existingUser != null) {
        developer.log('❌ Registration failed: Email already exists');
        return false;
      }

      // Insert user to database
      final result = await _dbHelper.insertUser(username, email, password);
      developer.log('✅ User registered successfully: $email');
      return result > 0;
    } catch (e) {
      developer.log('❌ Registration error: $e', error: e);
      return false;
    }
  }

  Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    try {
      // Admin credential check
      if (email == 'admin@dincoff.com') {
        if (password == 'admin123') {
          developer.log('✅ Admin authenticated: $email');
          return {
            'username': 'Admin',
            'email': 'admin@dincoff.com',
            'role': 'admin',
            'id': 'admin-id',
          };
        } else {
          developer.log('❌ Login failed: Incorrect password for admin');
          return null;
        }
      }

      if (kIsWeb) {
        developer.log('🌐 Web Platform: Any email/password accepted');
        return {
          'username': 'Web User',
          'email': email,
          'role': 'user',
          'id': 'web-user-id',
        };
      }

      // Get user from database
      final user = await _dbHelper.getUserByEmail(email);
      if (user == null) {
        developer.log('❌ Login failed: User not found - $email');
        return null;
      }

      // Password validation
      final savedPassword = user['password'] as String?;
      if (savedPassword != password) {
        developer.log('❌ Login failed: Incorrect password for - $email');
        return null;
      }

      developer.log('✅ User authenticated: $email');
      return user;
    } catch (e) {
      developer.log('❌ Login error: $e', error: e);
      return null;
    }
  }

  Future<void> confirmOrderPayment(String orderId) async {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      // Create a new order object with updated status
      final oldOrder = _orders[index];
      _orders[index] = Order(
        id: oldOrder.id,
        items: oldOrder.items,
        total: oldOrder.total,
        date: oldOrder.date,
        status: 'Payment Confirmed',
        userId: oldOrder.userId,
      );

      if (!kIsWeb) {
        try {
          await _dbHelper.updateOrderStatus(orderId, 'Payment Confirmed');
        } catch (e) {
          developer.log('Error updating order status in DB: $e');
        }
      }
      notifyListeners();
    }
  }
}
