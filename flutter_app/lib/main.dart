import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const LazBEmpireApp());

const storePhone = '+2348140499272';
const storeWhatsApp = '2348140499272';
const storeAddress = 'Beside FirstBank, Choba Campus/UNIPORT, Port Harcourt, Rivers';
const mapsUrl = 'https://www.google.com/maps/search/?api=1&query=Laz+B+Empire%2C+Beside+FirstBank%2C+Choba%2C+Port+Harcourt%2C+Rivers%2C+Nigeria';

class Product {
  final String name;
  final String category;
  final IconData icon;
  const Product(this.name, this.category, this.icon);
}

const products = <Product>[
  Product('Handbags', 'Bags', Icons.shopping_bag_outlined),
  Product('Wrist Watches', 'Watches', Icons.watch_outlined),
  Product('Jewelry', 'Jewelry', Icons.diamond_outlined),
  Product('Sunglasses', 'Sunglasses', Icons.wb_sunny_outlined),
  Product('Belts', 'Accessories', Icons.linear_scale),
  Product('Fashion Accessories', 'Accessories', Icons.auto_awesome_outlined),
];

class LazBEmpireApp extends StatelessWidget {
  const LazBEmpireApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Laz B Empire',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7542E6)),
      scaffoldBackgroundColor: const Color(0xFFF9F8FC),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    ),
    home: const StoreShell(),
  );
}

class StoreShell extends StatefulWidget {
  const StoreShell({super.key});
  @override State<StoreShell> createState() => _StoreShellState();
}

class _StoreShellState extends State<StoreShell> {
  int tab = 0;
  final List<Product> cart = [];
  String query = '';
  String category = 'All';

  Future<void> openUrl(String value) async {
    final uri = Uri.parse(value);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the link.')));
    }
  }

  Future<void> whatsapp([String? message]) => openUrl(
    'https://wa.me/$storeWhatsApp?text=${Uri.encodeComponent(message ?? 'Hello Laz B Empire, I would like to make an order.')}',
  );

  Future<void> call() => openUrl('tel:$storePhone');

  void addToCart(Product product) {
    setState(() => cart.add(product));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} added to your order'), action: SnackBarAction(label: 'VIEW', onPressed: () => setState(() => tab = 1))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_shop(), _cart(), _account()];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Laz B Empire', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          Stack(children: [
            IconButton(onPressed: () => setState(() => tab = 1), icon: const Icon(Icons.shopping_bag_outlined)),
            if (cart.isNotEmpty)
              Positioned(right: 6, top: 5, child: CircleAvatar(radius: 9, child: Text('${cart.length}', style: const TextStyle(fontSize: 10)))),
          ]),
          IconButton(onPressed: whatsapp, icon: const Icon(Icons.chat_outlined)),
        ],
      ),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Shop'),
          NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag), label: 'Order'),
          NavigationDestination(icon: Icon(Icons.info_outline), selectedIcon: Icon(Icons.info), label: 'Store'),
        ],
      ),
    );
  }

  Widget _shop() {
    final filtered = products.where((p) {
      final matchesCategory = category == 'All' || p.category == category;
      final q = query.toLowerCase().trim();
      return matchesCategory && (q.isEmpty || p.name.toLowerCase().contains(q) || p.category.toLowerCase().contains(q));
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF241631), Color(0xFF7542E6)]),
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('LAZ B EMPIRE', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w800, letterSpacing: 2)),
            SizedBox(height: 10),
            Text('Your style.\nYour statement.', style: TextStyle(color: Colors.white, fontSize: 31, height: 1.05, fontWeight: FontWeight.w900)),
            SizedBox(height: 10),
            Text('Browse accessories, build your order and chat with the store.', style: TextStyle(color: Colors.white70)),
          ]),
        ),
        const SizedBox(height: 18),
        TextField(onChanged: (v) => setState(() => query = v), decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search products or categories')),
        const SizedBox(height: 14),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ['All', 'Bags', 'Watches', 'Jewelry', 'Sunglasses', 'Accessories'].map((c) =>
              Padding(padding: const EdgeInsets.only(right: 8), child: ChoiceChip(label: Text(c), selected: category == c, onSelected: (_) => setState(() => category = c)))).toList(),
          ),
        ),
        const SizedBox(height: 20),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Shop', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          Text('${filtered.length} categories', style: TextStyle(color: Colors.grey)),
        ]),
        const SizedBox(height: 10),
        ...filtered.map(_productCard),
        const SizedBox(height: 10),
        Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Need the latest catalogue?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 7),
          const Text('Stock, colours and prices can change. Ask Laz B Empire for current availability before ordering.'),
          const SizedBox(height: 14),
          SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: whatsapp, icon: const Icon(Icons.chat), label: const Text('Request current catalogue'))),
        ]))),
      ],
    );
  }

  Widget _productCard(Product p) => Card(
    elevation: 0, margin: const EdgeInsets.only(bottom: 12),
    child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
      Container(width: 68, height: 68, decoration: BoxDecoration(color: const Color(0xFFF0EAFE), borderRadius: BorderRadius.circular(18)), child: Icon(p.icon, size: 32, color: const Color(0xFF7542E6))),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(p.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 4), Text(p.category, style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 3), const Text('Check current price & availability', style: TextStyle(fontSize: 12)),
      ])),
      IconButton(onPressed: () => addToCart(p), icon: const Icon(Icons.add_shopping_cart)),
    ])),
  );

  Widget _cart() {
    if (cart.isEmpty) return Center(child: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.shopping_bag_outlined, size: 70, color: Color(0xFF7542E6)),
      const SizedBox(height: 14), const Text('Your order is empty', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8), const Text('Add items from the shop, then send your order to Laz B Empire on WhatsApp.', textAlign: TextAlign.center),
      const SizedBox(height: 18), FilledButton(onPressed: () => setState(() => tab = 0), child: const Text('Browse shop')),
    ]));

    return ListView(padding: const EdgeInsets.all(16), children: [
      const Text('Your order', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      const SizedBox(height: 5), Text('${cart.length} item(s) • Final price confirmed by the store', style: TextStyle(color: Colors.grey)),
      const SizedBox(height: 16),
      ...cart.asMap().entries.map((entry) {
        final i = entry.key; final p = entry.value;
        return Card(elevation: 0, child: ListTile(
          leading: CircleAvatar(backgroundColor: const Color(0xFFF0EAFE), child: Icon(p.icon, color: const Color(0xFF7542E6))),
          title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(p.category),
          trailing: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => cart.removeAt(i))),
        ));
      }),
      const SizedBox(height: 12),
      Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Checkout on WhatsApp', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8), const Text('The store will confirm current prices, availability, pickup and delivery details with you.'),
        const SizedBox(height: 14),
        SizedBox(width: double.infinity, child: FilledButton.icon(
          onPressed: () {
            final items = cart.map((p) => '• ${p.name}').join('\n');
            whatsapp('Hello Laz B Empire, I would like to order:\n$items\n\nPlease confirm availability, current prices and pickup/delivery options.');
          },
          icon: const Icon(Icons.send), label: const Text('Send order to WhatsApp'),
        )),
      ]))),
    ]);
  }

  Widget _account() => ListView(padding: const EdgeInsets.all(16), children: [
    Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: const Color(0xFF17151B), borderRadius: BorderRadius.circular(24)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.storefront, color: Colors.white, size: 42), SizedBox(height: 12),
      Text('Laz B Empire', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
      SizedBox(height: 3), Text('Fashion accessories • Choba, Port Harcourt', style: TextStyle(color: Colors.white70)),
    ])),
    const SizedBox(height: 14),
    Card(elevation: 0, child: ListTile(leading: const Icon(Icons.location_on_outlined), title: const Text('Store location'), subtitle: const Text(storeAddress), trailing: const Icon(Icons.open_in_new), onTap: () => openUrl(mapsUrl))),
    Card(elevation: 0, child: ListTile(leading: const Icon(Icons.phone_outlined), title: const Text('0814 049 9272'), subtitle: const Text('Call the store'), onTap: call)),
    Card(elevation: 0, child: ListTile(leading: const Icon(Icons.chat_outlined), title: const Text('WhatsApp'), subtitle: const Text('Chat about products and orders'), onTap: whatsapp)),
    Card(elevation: 0, child: const ListTile(leading: Icon(Icons.schedule_outlined), title: Text('Opening hours'), subtitle: Text('Monday–Friday: 7:30am–9:30pm\nSaturday: 7:30am–8:00pm\nSunday: Closed'))),
    const SizedBox(height: 10),
    const Text('Ordering', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
    const SizedBox(height: 6),
    const Text('Prices and stock are confirmed directly by Laz B Empire before payment.'),
  ]);
}