import 'package:flutter/material.dart';

void main() => runApp(const EbensApp());

class Product {
  final String name, category, price, description;
  final IconData icon;
  const Product(this.name, this.category, this.price, this.icon, this.description);
}

const products = <Product>[
  Product('iPhone 15 Pro', 'Phones', '₦1,250,000', Icons.phone_iphone, 'Premium Apple smartphone with Pro performance.'),
  Product('Samsung Galaxy S24', 'Phones', '₦980,000', Icons.phone_android, 'Flagship Android phone with a bright display and great camera.'),
  Product('AirPods Pro', 'Accessories', '₦320,000', Icons.headphones, 'Wireless earbuds with active noise cancellation.'),
  Product('MacBook Air M2', 'Laptops', '₦1,450,000', Icons.laptop_mac, 'Lightweight laptop for work, school and creativity.'),
  Product('Power Bank 20,000mAh', 'Accessories', '₦45,000', Icons.battery_charging_full, 'High-capacity portable power for your devices.'),
  Product('Gaming Headset', 'Gaming', '₦65,000', Icons.sports_esports, 'Comfortable headset for gaming and entertainment.'),
];

class EbensApp extends StatelessWidget {
  const EbensApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'EBENS GADGET UNIVERSE',
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple, scaffoldBackgroundColor: const Color(0xFFF7F7FA)),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  String category = 'All';
  final cart = <Product>[];

  List<Product> get visible => category == 'All' ? products : products.where((p) => p.category == category).toList();

  void add(Product p) {
    setState(() => cart.add(p));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(p.name + ' added to cart')));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('EBENS GADGET UNIVERSE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
      actions: [
        IconButton(
          tooltip: 'Cart',
          onPressed: () => showModalBottomSheet(context: context, showDragHandle: true, builder: (_) => CartSheet(cart: cart)),
          icon: Badge(isLabelVisible: cart.isNotEmpty, label: Text(cart.length.toString()), child: const Icon(Icons.shopping_cart_outlined)),
        ),
      ],
    ),
    body: tab == 0 ? home() : tab == 1 ? orders() : account(),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (i) => setState(() => tab = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Shop'),
        NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Orders'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Account'),
      ],
    ),
  );

  Widget home() => ListView(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
    children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF5E35B1), Color(0xFF8E5DE7)]),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Gadgets you want.', style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900)),
          SizedBox(height: 5),
          Text('Shop phones, laptops and accessories from EBENS GADGET UNIVERSE.', style: TextStyle(color: Colors.white70, height: 1.35)),
        ]),
      ),
      const SizedBox(height: 18),
      TextField(
        decoration: InputDecoration(
          hintText: 'Search phones, gadgets...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
      ),
      const SizedBox(height: 18),
      SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: ['All', 'Phones', 'Laptops', 'Accessories', 'Gaming'].map((c) =>
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(label: Text(c), selected: category == c, onSelected: (_) => setState(() => category = c)),
            )).toList(),
        ),
      ),
      const SizedBox(height: 18),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Popular products', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        Text(visible.length.toString() + ' items', style: const TextStyle(color: Colors.grey)),
      ]),
      const SizedBox(height: 10),
      ...visible.map((p) => Card(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: Colors.deepPurple.withOpacity(.08), borderRadius: BorderRadius.circular(14)),
            child: Icon(p.icon, size: 30, color: Colors.deepPurple),
          ),
          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(p.category + '\n' + p.price, maxLines: 2),
          isThreeLine: true,
          trailing: FilledButton(onPressed: () => add(p), child: const Text('Add')),
          onTap: () => showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(p.name),
              content: Text(p.description + '\n\nPrice: ' + p.price),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                FilledButton(onPressed: () { Navigator.pop(context); add(p); }, child: const Text('Add to cart')),
              ],
            ),
          ),
        ),
      )),
      const SizedBox(height: 8),
      Card(
        child: ListTile(
          leading: const Icon(Icons.location_on, color: Colors.deepPurple),
          title: const Text('Visit our store', style: TextStyle(fontWeight: FontWeight.w700)),
          subtitle: const Text('Shop 59, Everyday Supermarket Plaza, Choba, UNIPORT, Port Harcourt'),
          onTap: () => showDialog(
            context: context,
            builder: (_) => const AlertDialog(
              title: Text('EBENS GADGET UNIVERSE'),
              content: Text('Shop 59, Everyday Supermarket Plaza, Choba, UNIPORT, Port Harcourt\n\nPhone: 0806 023 2119'),
            ),
          ),
        ),
      ),
    ],
  );

  Widget orders() => const Center(child: Padding(
    padding: EdgeInsets.all(24),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.receipt_long, size: 64, color: Colors.deepPurple),
      SizedBox(height: 12),
      Text('Your orders', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
      SizedBox(height: 6),
      Text('Orders will appear here after checkout.'),
    ]),
  ));

  Widget account() => ListView(
    padding: const EdgeInsets.all(16),
    children: const [
      CircleAvatar(radius: 42, child: Icon(Icons.person, size: 42)),
      SizedBox(height: 12),
      Center(child: Text('Guest customer', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800))),
      SizedBox(height: 24),
      Card(child: ListTile(leading: Icon(Icons.call), title: Text('Call store'), subtitle: Text('0806 023 2119'))),
      Card(child: ListTile(leading: Icon(Icons.location_on), title: Text('Store location'), subtitle: Text('Choba, UNIPORT, Port Harcourt'))),
    ],
  );
}

class CartSheet extends StatelessWidget {
  final List<Product> cart;
  const CartSheet({super.key, required this.cart});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: cart.isEmpty
        ? const SizedBox(height: 220, child: Center(child: Text('Your cart is empty')))
        : Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Shopping cart', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            ...cart.map((p) => ListTile(leading: Icon(p.icon), title: Text(p.name), trailing: Text(p.price))),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, child: FilledButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const AlertDialog(
                  title: Text('Demo checkout'),
                  content: Text('This is a sales demo. A production version can connect Paystack or Flutterwave, delivery and order management.'),
                ),
              ),
              icon: const Icon(Icons.payment),
              label: const Text('Proceed to checkout'),
            )),
          ]),
    ),
  );
}
