import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const LazBEmpireApp());

class Product {
  final String name;
  final String category;
  final IconData icon;
  const Product(this.name, this.category, this.icon);
}

const products = [
  Product('Handbags', 'Bags', Icons.shopping_bag_outlined),
  Product('Wrist Watches', 'Watches', Icons.watch_outlined),
  Product('Jewelry', 'Jewelry', Icons.diamond_outlined),
  Product('Sunglasses', 'Sunglasses', Icons.visibility_outlined),
  Product('Belts', 'Accessories', Icons.loyalty_outlined),
  Product('Fashion Accessories', 'Accessories', Icons.auto_awesome_outlined),
];

const whatsappUrl = 'https://wa.me/2348140499272?text=Hello%20Laz%20B%20Empire%2C%20I%20saw%20your%20online%20store%20and%20would%20like%20to%20make%20an%20order.';

class LazBEmpireApp extends StatelessWidget {
  const LazBEmpireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Laz B Empire',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7C3AED)),
        scaffoldBackgroundColor: const Color(0xFFF8F7FC),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  String search = '';

  Future<void> openWhatsApp() async {
    final uri = Uri.parse(whatsappUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp could not be opened.')),
      );
    }
  }

  Future<void> callStore() async {
    final uri = Uri.parse('tel:+2348140499272');
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_shop(context), _orders(context), _account(context)];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laz B Empire', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(onPressed: openWhatsApp, icon: const Icon(Icons.chat_outlined)),
          IconButton(onPressed: callStore, icon: const Icon(Icons.call_outlined)),
        ],
      ),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Shop'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Account'),
        ],
      ),
    );
  }

  Widget _shop(BuildContext context) {
    final filtered = products.where((p) =>
      p.name.toLowerCase().contains(search.toLowerCase()) ||
      p.category.toLowerCase().contains(search.toLowerCase())).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF5B21B6), Color(0xFF8B5CF6)]),
            borderRadius: BorderRadius.circular(28),
          ),
          child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('FASHION THAT FITS YOUR STYLE', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
            SizedBox(height: 8),
            Text('Discover your next favourite accessory.', style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w800)),
            SizedBox(height: 10),
            Text('Browse the collection and order directly on WhatsApp.', style: TextStyle(color: Colors.white70, fontSize: 14)),
          ]),
        ),
        const SizedBox(height: 18),
        TextField(
          onChanged: (v) => setState(() => search = v),
          decoration: InputDecoration(
            hintText: 'Search accessories',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 18),
        const Text('Categories', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: ['Bags', 'Watches', 'Jewelry', 'Sunglasses', 'Accessories']
                .map((c) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(label: Text(c), avatar: const Icon(Icons.auto_awesome, size: 16)),
                )).toList(),
          ),
        ),
        const SizedBox(height: 18),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Featured collection', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          Text('${filtered.length} items', style: TextStyle(color: Colors.grey.shade600)),
        ]),
        const SizedBox(height: 10),
        ...filtered.map((p) => Card(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFFEDE9FE),
              child: Icon(p.icon, color: const Color(0xFF6D28D9)),
            ),
            title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('${p.category} • Price available on request'),
            trailing: const Icon(Icons.chevron_right),
            onTap: openWhatsApp,
          ),
        )),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Visit Laz B Empire', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Beside FirstBank, Choba Campus/UNIPORT, Port Harcourt, Rivers.'),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: OutlinedButton.icon(onPressed: callStore, icon: const Icon(Icons.call), label: const Text('Call'))),
                const SizedBox(width: 10),
                Expanded(child: FilledButton.icon(onPressed: openWhatsApp, icon: const Icon(Icons.chat), label: const Text('WhatsApp'))),
              ]),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _orders(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(30),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.receipt_long_outlined, size: 64, color: Color(0xFF7C3AED)),
        SizedBox(height: 14),
        Text('Your orders will appear here', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        SizedBox(height: 8),
        Text('For this demo, orders are completed through WhatsApp. A production version can add online checkout and order tracking.', textAlign: TextAlign.center),
      ]),
    ),
  );

  Widget _account(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const CircleAvatar(radius: 42, child: Icon(Icons.storefront, size: 42)),
      const SizedBox(height: 12),
      const Center(child: Text('Laz B Empire', style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800))),
      const Center(child: Text('Fashion accessories store')),
      const SizedBox(height: 24),
      Card(elevation: 0, child: ListTile(leading: const Icon(Icons.location_on_outlined), title: const Text('Location'), subtitle: const Text('Beside FirstBank, Choba Campus/UNIPORT'))),
      Card(elevation: 0, child: ListTile(leading: const Icon(Icons.phone_outlined), title: const Text('0814 049 9272'), onTap: callStore)),
      Card(elevation: 0, child: ListTile(leading: const Icon(Icons.schedule_outlined), title: const Text('Opening hours'), subtitle: const Text('Mon–Fri: 7:30am–9:30pm\nSaturday: 7:30am–8:00pm\nSunday: Closed'))),
    ],
  );
}
