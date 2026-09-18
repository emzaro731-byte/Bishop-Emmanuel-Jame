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
  final String image;
  final String tag;
  const Product(this.name, this.category, this.image, this.tag);
}

const products = <Product>[
  Product('Handbags', 'Bags', 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=800&q=80', 'TRENDING'),
  Product('Wrist Watches', 'Watches', 'https://images.unsplash.com/photo-1523170335258-f5ed11844a49?auto=format&fit=crop&w=800&q=80', 'NEW'),
  Product('Jewelry', 'Jewelry', 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?auto=format&fit=crop&w=800&q=80', 'HOT'),
  Product('Sunglasses', 'Sunglasses', 'https://images.unsplash.com/photo-1511499767150-a48a237f0083?auto=format&fit=crop&w=800&q=80', 'SALE'),
  Product('Fashion Bags', 'Bags', 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=800&q=80', 'POPULAR'),
  Product('Fashion Accessories', 'Accessories', 'https://images.unsplash.com/photo-1525507119028-ed4c629a60a3?auto=format&fit=crop&w=800&q=80', 'STYLE'),
];

class LazBEmpireApp extends StatelessWidget {
  const LazBEmpireApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Laz B Empire',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF1744)),
      scaffoldBackgroundColor: const Color(0xFFF6F6F6),
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
  String query = '';
  String category = 'All';
  final List<Product> cart = [];

  Future<void> openUrl(String value) async {
    final uri = Uri.parse(value);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the link.')));
    }
  }

  Future<void> whatsapp([String? message]) => openUrl(
    'https://wa.me/$storeWhatsApp?text=${Uri.encodeComponent(message ?? 'Hello Laz B Empire, I would like to shop.')}',
  );

  Future<void> call() => openUrl('tel:$storePhone');

  void addToCart(Product product) {
    setState(() => cart.add(product));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} added to cart'), action: SnackBarAction(label: 'CART', onPressed: () => setState(() => tab = 1))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_home(), _cart(), _store()];
    return Scaffold(
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        height: 68,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFFFE3EA),
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: _cartIcon(false), selectedIcon: _cartIcon(true), label: 'Cart'),
          const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }

  Widget _cartIcon(bool selected) => Stack(
    clipBehavior: Clip.none,
    children: [
      Icon(selected ? Icons.shopping_cart : Icons.shopping_cart_outlined),
      if (cart.isNotEmpty)
        Positioned(
          right: -9, top: -9,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: const BoxDecoration(color: Color(0xFFFF1744), shape: BoxShape.circle),
            child: Text('${cart.length}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
          ),
        ),
    ],
  );

  Widget _home() {
    final filtered = products.where((p) {
      final q = query.trim().toLowerCase();
      final matchesCategory = category == 'All' || p.category == category;
      return matchesCategory && (q.isEmpty || p.name.toLowerCase().contains(q) || p.category.toLowerCase().contains(q));
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _topBar()),
        SliverToBoxAdapter(child: _searchBar()),
        SliverToBoxAdapter(child: _promoBanner()),
        SliverToBoxAdapter(child: _quickCategories()),
        SliverToBoxAdapter(child: _sectionHeader('Bundle Deals', '3 items')),
        SliverToBoxAdapter(child: _bundleRow()),
        SliverToBoxAdapter(child: _sectionHeader('SuperDeals', 'Limited time')),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: .67,
              ),
              itemBuilder: (_, i) => _productCard(filtered[i]),
            ),
          ),
        ),
        if (filtered.isEmpty)
          const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(40), child: Center(child: Text('No matching products yet.')))),
        SliverToBoxAdapter(child: _trustSection()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Widget _topBar() => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(16, 10, 10, 8),
    child: Row(
      children: [
        Container(
          width: 38, height: 38,
          decoration: const BoxDecoration(color: Color(0xFFFF1744), shape: BoxShape.circle),
          child: const Icon(Icons.shopping_bag, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 9),
        const Expanded(child: Text('Laz B Empire', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -.6))),
        IconButton(onPressed: whatsapp, icon: const Icon(Icons.chat_bubble_outline)),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(onPressed: () => setState(() => tab = 1), icon: const Icon(Icons.shopping_cart_outlined)),
            if (cart.isNotEmpty)
              Positioned(
                right: 5, top: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: const BoxDecoration(color: Color(0xFFFF1744), shape: BoxShape.circle),
                  child: Text('${cart.length}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ],
    ),
  );

  Widget _searchBar() => Container(
    color: Colors.white,
    padding: const EdgeInsets.fromLTRB(14, 3, 14, 12),
    child: TextField(
      onChanged: (v) => setState(() => query = v),
      decoration: InputDecoration(
        hintText: 'Search on Laz B Empire',
        prefixIcon: const Icon(Icons.search, color: Colors.black54),
        suffixIcon: query.isEmpty ? const Icon(Icons.camera_alt_outlined, color: Colors.black45) : IconButton(onPressed: () => setState(() => query = ''), icon: const Icon(Icons.close)),
        filled: true,
        fillColor: const Color(0xFFF1F1F1),
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    ),
  );

  Widget _promoBanner() => Container(
    margin: const EdgeInsets.fromLTRB(12, 10, 12, 8),
    height: 126,
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFFFF1744), Color(0xFFFF6D00)]),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Stack(
      children: [
        Positioned(right: -22, top: -28, child: CircleAvatar(radius: 72, backgroundColor: Colors.white12)),
        const Padding(
          padding: EdgeInsets.fromLTRB(18, 15, 18, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('LAZ B EMPIRE SALE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
              SizedBox(height: 5),
              Text('Style deals made easy', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              SizedBox(height: 5),
              Text('Fresh fashion accessories • Shop local', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ),
        Positioned(
          right: 14, bottom: 12,
          child: FilledButton(
            onPressed: whatsapp,
            style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFFF1744)),
            child: const Text('Shop now'),
          ),
        ),
      ],
    ),
  );

  Widget _quickCategories() {
    final cats = <String, IconData>{
      'All': Icons.auto_awesome,
      'Bags': Icons.shopping_bag_outlined,
      'Watches': Icons.watch_outlined,
      'Jewelry': Icons.diamond_outlined,
      'Sunglasses': Icons.wb_sunny_outlined,
      'Accessories': Icons.grid_view_rounded,
    };
    return SizedBox(
      height: 98,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        scrollDirection: Axis.horizontal,
        children: cats.entries.map((e) => InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => category = e.key),
          child: SizedBox(
            width: 78,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: category == e.key ? const Color(0xFFFFE3EA) : const Color(0xFFF1F1F1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(e.value, color: category == e.key ? const Color(0xFFFF1744) : Colors.black87),
                ),
                const SizedBox(height: 6),
                Text(e.key, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _sectionHeader(String title, String action) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 9),
    child: Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -.4)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: const Color(0xFFFFEEF2), borderRadius: BorderRadius.circular(20)),
          child: Text(action, style: const TextStyle(color: Color(0xFFE91E4D), fontSize: 11, fontWeight: FontWeight.w800)),
        ),
      ],
    ),
  );

  Widget _bundleRow() => SizedBox(
    height: 166,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      scrollDirection: Axis.horizontal,
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (_, i) {
        final p = products[i];
        return Container(
          width: 154,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _networkImage(p.image)),
              Padding(
                padding: const EdgeInsets.fromLTRB(9, 7, 7, 8),
                child: Row(
                  children: [
                    Expanded(child: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800))),
                    InkWell(onTap: () => addToCart(p), child: const Icon(Icons.add_circle, color: Color(0xFFFF1744), size: 22)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  Widget _productCard(Product p) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => _showProduct(p),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(child: _networkImage(p.image)),
                Positioned(
                  left: 7, top: 7,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(.92), borderRadius: BorderRadius.circular(5)),
                    child: Text(p.tag, style: const TextStyle(color: Color(0xFFE91E4D), fontSize: 9, fontWeight: FontWeight.w900)),
                  ),
                ),
                Positioned(
                  right: 7, bottom: 7,
                  child: Material(
                    color: Colors.white.withOpacity(.94),
                    shape: const CircleBorder(),
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => addToCart(p),
                      icon: const Icon(Icons.add_shopping_cart, size: 19),
                      color: const Color(0xFFFF1744),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(9, 8, 9, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 3),
                Text(p.category, style: const TextStyle(color: Colors.black54, fontSize: 11)),
                const SizedBox(height: 5),
                const Text('Check current price', style: TextStyle(color: Color(0xFFE91E4D), fontSize: 12, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _networkImage(String url) => Image.network(
    url,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => Container(color: const Color(0xFFF1F1F1), child: const Center(child: Icon(Icons.image_outlined, size: 38, color: Colors.black26))),
    loadingBuilder: (context, child, progress) => progress == null ? child : Container(color: const Color(0xFFF1F1F1), child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
  );

  void _showProduct(Product p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(14), child: SizedBox(height: 220, width: double.infinity, child: _networkImage(p.image))),
              const SizedBox(height: 14),
              Text(p.name, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900)),
              Text(p.category, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              const Text('Current price, colour and availability are confirmed by Laz B Empire before purchase.'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        whatsapp('Hello Laz B Empire, I am interested in ${p.name}. Please send me the current price and available options.');
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text('Ask on WhatsApp'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        addToCart(p);
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Add to cart'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trustSection() => Container(
    margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Shop with Laz B Empire', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _TrustItem(Icons.local_shipping_outlined, 'Pickup & delivery')),
            Expanded(child: _TrustItem(Icons.support_agent_outlined, 'WhatsApp support')),
            Expanded(child: _TrustItem(Icons.verified_outlined, 'Order confirmation')),
          ],
        ),
      ],
    ),
  );

  Widget _cart() {
    if (cart.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_cart_outlined, size: 82, color: Color(0xFFFF1744)),
              const SizedBox(height: 15),
              const Text('Your cart is empty', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 7),
              const Text('Add products and send the full order to Laz B Empire on WhatsApp.', textAlign: TextAlign.center),
              const SizedBox(height: 18),
              FilledButton(onPressed: () => setState(() => tab = 0), child: const Text('Start shopping')),
            ],
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.fromLTRB(16, 18, 16, 5), child: Text('Shopping Cart', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)))),
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('${cart.length} item(s) • Price confirmed by store', style: const TextStyle(color: Colors.black54)))),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final p = cart[index];
              return Card(
                margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                elevation: 0,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: SizedBox(width: 60, height: 60, child: _networkImage(p.image))),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${p.category}\nPrice on request'),
                  isThreeLine: true,
                  trailing: IconButton(onPressed: () => removeFromCart(index), icon: const Icon(Icons.delete_outline)),
                ),
              );
            },
            childCount: cart.length,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Checkout', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                    SizedBox(height: 6),
                    Text('Send your cart to the store. Laz B Empire will confirm price, stock and delivery details before payment.'),
                  ]),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: FilledButton.icon(
                    onPressed: () {
                      final items = cart.map((p) => '• ${p.name}').join('\n');
                      whatsapp('Hello Laz B Empire, I would like to order:\n$items\n\nPlease confirm current prices, availability and pickup/delivery options.');
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Checkout on WhatsApp'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _store() => ListView(
    padding: const EdgeInsets.fromLTRB(14, 18, 14, 30),
    children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF171717), Color(0xFF3A3A3A)]),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.storefront, color: Colors.white, size: 42),
          SizedBox(height: 12),
          Text('Laz B Empire', style: TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900)),
          SizedBox(height: 4),
          Text('Fashion accessories • Choba, Port Harcourt', style: TextStyle(color: Colors.white70)),
        ]),
      ),
      const SizedBox(height: 12),
      Card(elevation: 0, child: ListTile(leading: const Icon(Icons.location_on_outlined), title: const Text('Store location'), subtitle: const Text(storeAddress), trailing: const Icon(Icons.open_in_new), onTap: () => openUrl(mapsUrl))),
      Card(elevation: 0, child: ListTile(leading: const Icon(Icons.phone_outlined), title: const Text('0814 049 9272'), subtitle: const Text('Call the store'), onTap: call)),
      Card(elevation: 0, child: ListTile(leading: const Icon(Icons.chat_outlined), title: const Text('WhatsApp'), subtitle: const Text('Chat about products and orders'), onTap: whatsapp)),
      Card(elevation: 0, child: const ListTile(leading: Icon(Icons.schedule_outlined), title: Text('Opening hours'), subtitle: Text('Monday–Friday: 7:30am–9:30pm\nSaturday: 7:30am–8:00pm\nSunday: Closed'))),
      const SizedBox(height: 8),
      const Text('Ordering', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
      const SizedBox(height: 6),
      const Text('For the live catalogue, Laz B Empire confirms the actual product, current price, stock and delivery details before payment.'),
    ],
  );
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TrustItem(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, size: 24, color: const Color(0xFFFF1744)),
      const SizedBox(height: 5),
      Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
    ],
  );
}
