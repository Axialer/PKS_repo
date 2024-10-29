class Product {
  final int id; // Оставляем id как int
  final String name;
  final double price;
  final List<String> images;
  final String description;
  final List<String> reviews; // Изменяем на List<String>
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.images,
    required this.description,
    required this.reviews,
    this.isFavorite = false,
  });
}

class ProductRepository {
  static Future<List<Product>> loadProducts() async {
    return [
      Product(
        id: 1,
        name: 'Guitar',
        description: 'An acoustic guitar with 6 strings.',
        price: 500.00,
        images: ['assets/images/phone.png'],
        reviews: ['Amazing sound quality', 'Great build quality'],
      ),
      Product(
        id: 2,
        name: 'Piano',
        description: 'A grand piano with 88 keys.',
        price: 3000.00,
        images: ['assets/images/phone.png'],
        reviews: ['Rich sound', 'Beautiful design'],
      ),
      Product(
        id: 3,
        name: 'Drum Set',
        description: 'A complete drum set with cymbals.',
        price: 1200.00,
        images: ['assets/images/laptop.png'],
        reviews: ['Perfect for rock bands', 'Great quality'],
      ),
      Product(
        id: 4,
        name: 'Violin',
        description: 'A classic violin with a beautiful tone.',
        price: 800.00,
        images: ['assets/images/violin.png'],
        reviews: ['Excellent sound', 'Lightweight and portable'],
      ),
      Product(
        id: 5,
        name: 'Flute',
        description: 'A silver flute for beginners.',
        price: 300.00,
        images: ['assets/images/flute.png'],
        reviews: ['Easy to learn', 'Great for kids'],
      ),
      Product(
        id: 6,
        name: 'Saxophone',
        description: 'A high-quality saxophone for professionals.',
        price: 1500.00,
        images: ['assets/images/saxophone.png'],
        reviews: ['Smooth sound', 'Perfect for jazz'],
      ),
      Product(
        id: 7,
        name: 'Trumpet',
        description: 'A brass trumpet with a bright sound.',
        price: 600.00,
        images: ['assets/images/trumpet.png'],
        reviews: ['Clear tone', 'Great for marching bands'],
      ),
      Product(
        id: 8,
        name: 'Accordion',
        description: 'A versatile accordion for all music styles.',
        price: 1200.00,
        images: ['assets/images/accordion.png'],
        reviews: ['Very expressive', 'Fun to play'],
      ),
      Product(
        id: 9,
        name: 'Harmonica',
        description: 'A pocket harmonica for on-the-go music.',
        price: 50.00,
        images: ['assets/images/harmonica.png'],
        reviews: ['Portable', 'Perfect for blues'],
      ),
      Product(
        id: 10,
        name: 'Cello',
        description: 'A rich-sounding cello for classical music.',
        price: 2500.00,
        images: ['assets/images/cello.png'],
        reviews: ['Deep tones', 'Great craftsmanship'],
      ),
    ];
  }
}
