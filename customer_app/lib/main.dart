import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const red=Color(0xFFFF1744);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const url=String.fromEnvironment('SUPABASE_URL');
  const key=String.fromEnvironment('SUPABASE_ANON_KEY');
  if(url.isEmpty||key.isEmpty){runApp(const MaterialApp(home:Scaffold(body:Center(child:Text('Supabase configuration is required.')))));return;}
  await Supabase.initialize(url:url,anonKey:key);
  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget{
  const CustomerApp({super.key});
  @override Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false,title:'Laz B Empire',theme:ThemeData(useMaterial3:true,colorScheme:ColorScheme.fromSeed(seedColor:red)),home:const Shop());
}

class Shop extends StatefulWidget{const Shop({super.key});@override State<Shop> createState()=>_ShopState();}
class _ShopState extends State<Shop>{
  String q=''; String cat='All'; final Map<String,int> cart={}; List<Map<String,dynamic>> latest=[];
  Stream<List<Map<String,dynamic>>> get products=>Supabase.instance.client.from('products').stream(primaryKey:['id']).order('created_at',ascending:false);

  List<Map<String,dynamic>> filter(List<Map<String,dynamic>> rows)=>rows.where((p){
    final text=(p['name'].toString()+' '+p['category'].toString()).toLowerCase();
    return (cat=='All'||p['category']==cat)&&(q.isEmpty||text.contains(q.toLowerCase()));
  }).toList();

  void add(String id){setState(()=>cart[id]=(cart[id]??0)+1);}

  Future<void> checkout(List<Map<String,dynamic>> rows) async {
    if(cart.isEmpty)return;
    final n=TextEditingController(),ph=TextEditingController(),a=TextEditingController();
    final ok=await showDialog<bool>(context:context,builder:(_)=>AlertDialog(title:const Text('Checkout'),content:Column(mainAxisSize:MainAxisSize.min,children:[
      TextField(controller:n,decoration:const InputDecoration(labelText:'Full name')),
      TextField(controller:ph,keyboardType:TextInputType.phone,decoration:const InputDecoration(labelText:'Phone number')),
      TextField(controller:a,decoration:const InputDecoration(labelText:'Pickup / delivery address')),
    ]),actions:[TextButton(onPressed:()=>Navigator.pop(context,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(context,true),child:const Text('Place order'))]));
    if(ok!=true||n.text.trim().isEmpty||ph.text.trim().isEmpty)return;
    final selected=rows.where((p)=>cart.containsKey(p['id'].toString())).toList();
    double total=0;
    for(final p in selected){total+=(double.tryParse(p['price'].toString())??0)*(cart[p['id'].toString()]??1);}
    try{
      final order=await Supabase.instance.client.from('orders').insert({'customer_name':n.text.trim(),'phone':ph.text.trim(),'address':a.text.trim(),'total':total}).select('id').single();
      for(final p in selected){final id=p['id'].toString();await Supabase.instance.client.from('order_items').insert({'order_id':order['id'],'product_id':p['id'],'product_name':p['name'],'quantity':cart[id],'unit_price':p['price']});}
      setState(()=>cart.clear());
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Order placed successfully.')));
    }catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Order failed: '+e.toString())));}
  }

  void showCart(){
    final selected=latest.where((p)=>cart.containsKey(p['id'].toString())).toList();
    showModalBottomSheet(context:context,isScrollControlled:true,builder:(_)=>Padding(padding:const EdgeInsets.all(16),child:Column(mainAxisSize:MainAxisSize.min,children:[
      const Text('Shopping Cart',style:TextStyle(fontSize:24,fontWeight:FontWeight.w900)),
      ...selected.map((p){final id=p['id'].toString();return ListTile(title:Text(p['name'].toString()),subtitle:Text('Quantity: '+cart[id].toString()),trailing:IconButton(onPressed:()=>setState(()=>cart.remove(id)),icon:const Icon(Icons.delete_outline)));}),
      if(selected.isEmpty)const Padding(padding:EdgeInsets.all(20),child:Text('Your cart is empty.')),
      if(selected.isNotEmpty)SizedBox(width:double.infinity,child:FilledButton(onPressed:(){Navigator.pop(context);checkout(latest);},child:const Text('Checkout')))
    ])));
  }

  Widget productCard(Map<String,dynamic> p){
    final price=double.tryParse(p['price'].toString())??0;
    final stock=int.tryParse(p['stock'].toString())??0;
    return Card(clipBehavior:Clip.antiAlias,child:InkWell(onTap:()=>showDetails(p),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Expanded(child:p['image_url']==null?Container(color:Colors.black12,child:const Center(child:Icon(Icons.image_outlined,size:45))):Image.network(p['image_url'].toString(),width:double.infinity,fit:BoxFit.cover,errorBuilder:(_,__,___)=>const Center(child:Icon(Icons.broken_image)))),
      Padding(padding:const EdgeInsets.all(9),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(p['name'].toString(),maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.w800)),
        Text('₦'+price.toStringAsFixed(0),style:const TextStyle(fontSize:17,fontWeight:FontWeight.w900)),
        Row(children:[Expanded(child:Text(stock>0?stock.toString()+' in stock':'Out of stock',style:TextStyle(color:stock>0?Colors.green:Colors.red,fontSize:11))),IconButton(visualDensity:VisualDensity.compact,onPressed:stock>0?()=>add(p['id'].toString()):null,icon:const Icon(Icons.add_shopping_cart,color:red))])
      ]))
    ])));
  }

  void showDetails(Map<String,dynamic> p){
    final price=double.tryParse(p['price'].toString())??0;
    final stock=int.tryParse(p['stock'].toString())??0;
    showModalBottomSheet(context:context,builder:(_)=>Padding(padding:const EdgeInsets.all(16),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
      if(p['image_url']!=null)ClipRRect(borderRadius:BorderRadius.circular(12),child:Image.network(p['image_url'].toString(),height:220,width:double.infinity,fit:BoxFit.cover)),
      const SizedBox(height:10),Text(p['name'].toString(),style:const TextStyle(fontSize:24,fontWeight:FontWeight.w900)),Text(p['category'].toString()),
      Text('₦'+price.toStringAsFixed(0),style:const TextStyle(fontSize:21,fontWeight:FontWeight.w900,color:red)),
      Text(p['description'].toString()),Text(stock>0?stock.toString()+' available':'Out of stock'),
      const SizedBox(height:10),SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:stock>0?(){add(p['id'].toString());Navigator.pop(context);}:null,icon:const Icon(Icons.add_shopping_cart),label:const Text('Add to cart')))
    ])));
  }

  @override Widget build(BuildContext c)=>Scaffold(
    appBar:AppBar(title:const Text('Laz B Empire',style:TextStyle(fontWeight:FontWeight.w900)),actions:[Badge(isLabelVisible:cart.isNotEmpty,label:Text(cart.values.fold(0,(a,b)=>a+b).toString()),child:IconButton(onPressed:showCart,icon:const Icon(Icons.shopping_cart_outlined)))]),
    body:StreamBuilder<List<Map<String,dynamic>>>(stream:products,builder:(c,s){
      latest=filter(s.data??[]);
      return CustomScrollView(slivers:[
        SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.all(12),child:TextField(onChanged:(v)=>setState(()=>q=v),decoration:InputDecoration(prefixIcon:const Icon(Icons.search),hintText:'Search Laz B Empire',filled:true,fillColor:Colors.white,border:OutlineInputBorder(borderRadius:BorderRadius.circular(12),borderSide:BorderSide.none))))),
        SliverToBoxAdapter(child:SizedBox(height:52,child:ListView(scrollDirection:Axis.horizontal,padding:const EdgeInsets.symmetric(horizontal:12),children:['All','Bags','Watches','Jewelry','Sunglasses','Accessories'].map((x)=>Padding(padding:const EdgeInsets.only(right:8),child:ChoiceChip(label:Text(x),selected:cat==x,onSelected:(_)=>setState(()=>cat=x)))).toList()))),
        SliverToBoxAdapter(child:Container(margin:const EdgeInsets.all(12),padding:const EdgeInsets.all(18),decoration:BoxDecoration(gradient:const LinearGradient(colors:[red,Color(0xFFFF6D00)]),borderRadius:BorderRadius.circular(14)),child:const Text('Shop Laz B Empire\nReal products • Live stock • Easy checkout',style:TextStyle(color:Colors.white,fontSize:23,fontWeight:FontWeight.w900)))),
        if(s.hasError)SliverToBoxAdapter(child:Padding(padding:const EdgeInsets.all(20),child:Text('Could not load catalogue: '+s.error.toString()))),
        SliverPadding(padding:const EdgeInsets.all(12),sliver:SliverGrid(delegate:SliverChildBuilderDelegate((_,i)=>productCard(latest[i]),childCount:latest.length),gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:2,crossAxisSpacing:10,mainAxisSpacing:10,childAspectRatio:.62))),
      ]);
    }),
  );
}
