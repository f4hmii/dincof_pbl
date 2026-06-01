class Coffee {
  final String id;
  final String name;
  final String type;
  final String description;
  final double price;
  final String imagePath;
  final double rating;

  Coffee({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.price,
    required this.imagePath,
    required this.rating,
  });
}

class CartItem {
  final Coffee coffee;
  int quantity;

  CartItem({required this.coffee, this.quantity = 1});
}

class Order {
  final String id;
  final List<CartItem> items;
  final double total;
  final DateTime date;
  final String status;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.date,
    required this.status,
  });
}

final List<Coffee> sampleCoffees = [
  Coffee(
    id: '1',
    name: 'Cappuccino',
    type: 'with Oat Milk',
    description: 'A cappuccino is an espresso-based coffee drink that originated in Italy, and is traditionally prepared with steamed milk foam. It has a rich taste and a very smooth texture.',
    price: 35000.0,
    imagePath: 'coffee-cappuccino',
    rating: 4.8,
  ),
  Coffee(
    id: '2',
    name: 'Macchiato',
    type: 'with Almond Milk',
    description: 'Caffè macchiato is an espresso coffee drink with a small amount of milk, usually foamed. It provides a strong coffee flavor with a hint of milk.',
    price: 32000.0,
    imagePath: 'coffee-macchiato',
    rating: 4.5,
  ),
  Coffee(
    id: '3',
    name: 'Latte',
    type: 'with Soy Milk',
    description: 'A latte is a coffee drink made with espresso and steamed milk. Perfect for a morning boost or a relaxing afternoon.',
    price: 38000.0,
    imagePath: 'coffee-latte',
    rating: 4.9,
  ),
  Coffee(
    id: '4',
    name: 'Espresso',
    type: 'Classic',
    description: 'Espresso is a coffee-making method of Italian origin, in which a small amount of nearly boiling water is forced under pressure through finely-ground coffee beans.',
    price: 22000.0,
    imagePath: 'coffee-espresso',
    rating: 4.7,
  ),
];
