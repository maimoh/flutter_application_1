// app_state.dart — shared state بين Home وـ My Trip

class Attraction {
  final String id;
  final String name;
  final String location;
  final String category;
  final String categoryColor; // hex
  final double rating;
  final int price;
  final String imageUrl;
  final String pace;

  const Attraction({
    required this.id,
    required this.name,
    required this.location,
    required this.category,
    required this.categoryColor,
    required this.rating,
    required this.price,
    required this.imageUrl,
    required this.pace,
  });
}

// ── Static sample data ─────────────────────────────────────────────────
const List<Attraction> kAttractions = [
  Attraction(
    id: '1',
    name: 'Great Pyramids of Giza',
    location: 'Giza',
    category: 'Ancient',
    categoryColor: '1B3A6B',
    rating: 4.9,
    price: 200,
    imageUrl: 'https://images.unsplash.com/photo-1539768942893-daf53e448371?w=600&q=80',
    pace: 'Medium',
  ),
  Attraction(
    id: '2',
    name: 'Nile Felucca Cruise',
    location: 'Luxor',
    category: 'Nature',
    categoryColor: '2E8B57',
    rating: 4.6,
    price: 150,
    imageUrl: 'https://images.unsplash.com/photo-1568322445389-f64ac2515020?w=600&q=80',
    pace: 'Medium',
  ),
  Attraction(
    id: '3',
    name: 'Karnak Temple Complex',
    location: 'Luxor',
    category: 'Pharaonic',
    categoryColor: '4A5568',
    rating: 4.8,
    price: 180,
    imageUrl: 'https://images.unsplash.com/photo-1553913861-c0fddf2619ee?w=600&q=80',
    pace: 'Slow',
  ),
  Attraction(
    id: '4',
    name: 'Khan el-Khalili Bazaar',
    location: 'Cairo',
    category: 'Islamic',
    categoryColor: '744210',
    rating: 4.5,
    price: 0,
    imageUrl: 'https://images.unsplash.com/photo-1572252009286-268acec5ca0a?w=600&q=80',
    pace: 'Medium',
  ),
  Attraction(
    id: '5',
    name: 'Abu Simbel Temples',
    location: 'Aswan',
    category: 'Ancient',
    categoryColor: '1B3A6B',
    rating: 4.9,
    price: 300,
    imageUrl: 'https://images.unsplash.com/photo-1594614271900-6e7a8ab0d50b?w=600&q=80',
    pace: 'Quick',
  ),
  Attraction(
    id: '6',
    name: 'Hanging Church',
    location: 'Cairo',
    category: 'Coptic',
    categoryColor: '6B4226',
    rating: 4.4,
    price: 50,
    imageUrl: 'https://images.unsplash.com/photo-1571401835393-8c5f35328320?w=600&q=80',
    pace: 'Quick',
  ),
];

// ── Simple in-memory cart ──────────────────────────────────────────────
class AppCart {
  static final AppCart _instance = AppCart._internal();
  factory AppCart() => _instance;
  AppCart._internal();

  final List<Attraction> items = [];
  static const int maxItems = 6;

  bool contains(String id) => items.any((a) => a.id == id);
  bool get isFull => items.length >= maxItems;

  void add(Attraction a) {
    if (!contains(a.id) && !isFull) items.add(a);
  }

  void remove(String id) => items.removeWhere((a) => a.id == id);
  void clear() => items.clear();
}
