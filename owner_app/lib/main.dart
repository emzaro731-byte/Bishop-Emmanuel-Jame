import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const red=Color(0xFFFF1744);

Future<void> main()async{
 WidgetsFlutterBinding.ensureInitialized();
 const u=String.fromEnvironment('SUPABASE_URL'),k=String.fromEnvironment('SUPABASE_ANON_KEY');
 if(u.isEmpty||k.isEmpty){runApp(const MaterialApp(home:Scaffold(body:Center(child:Text('Supabase configuration is required.')))));return;}
 await Supabase.initialize(url:u,anonKey:k);runApp(const OwnerApp());
}
class OwnerApp extends StatelessWidget{const OwnerApp({super.key});@override Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false,title:'Laz B Empire Owner',theme:ThemeData(useMaterial3:true,colorScheme:ColorScheme.fromSeed(seedColor:red)),home:const Login());}

class Login extends StatefulWidget{const Login({super.key});@override State<Login>createState()=>_LoginState();}
class _LoginState extends State<Login>{
 final e=TextEditingController(),p=TextEditingController();bool busy=false;
 Future<void> login()async{setState(()=>busy=true);try{await Supabase.instance.client.auth.signInWithPassword(email:e.text.trim(),password:p.text);if(mounted)Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const Dashboard()));}catch(x){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Login failed: '+x.toString())));}finally{if(mounted)setState(()=>busy=false);}}
 @override Widget build(BuildContext c)=>Scaffold(body:Center(child:SingleChildScrollView(padding:const EdgeInsets.all(24),child:Column(children:[
 const CircleAvatar(radius:42,backgroundColor:red,child:Icon(Icons.storefront,color:Colors.white,size:42)),const SizedBox(height:14),
 const Text('Laz B Empire Owner',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)),const Text('Upload products • Manage orders'),
 const SizedBox(height:24),TextField(controller:e,decoration:const InputDecoration(labelText:'Owner email',prefixIcon:Icon(Icons.email_outlined))),
 const SizedBox(height:10),TextField(controller:p,obscureText:true,decoration:const InputDecoration(labelText:'Password',prefixIcon:Icon(Icons.lock_outline))),
 const SizedBox(height:18),SizedBox(width:double.infinity,height:52,child:FilledButton(onPressed:busy?null:login,child:Text(busy?'Signing in...':'Owner login')))
 ])));
}

class Dashboard extends StatefulWidget{const Dashboard({super.key});@override State<Dashboard>createState()=>_DashboardState();}
class _DashboardState extends State<Dashboard>{
 final picker=ImagePicker();int tab=0;

 Future<void> addProduct()async{
  final n=TextEditingController(),cat=TextEditingController(),price=TextEditingController(),stock=TextEditingController(),desc=TextEditingController();
  Uint8List? bytes;String? file;
  await showDialog(context:context,builder:(_)=>StatefulBuilder(builder:(c,setD)=>AlertDialog(title:const Text('Upload product'),content:SingleChildScrollView(child:Column(children:[
   TextField(controller:n,decoration:const InputDecoration(labelText:'Product name')),
   TextField(controller:cat,decoration:const InputDecoration(labelText:'Category')),
   TextField(controller:price,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Price ₦')),
   TextField(controller:stock,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Stock quantity')),
   TextField(controller:desc,maxLines:3,decoration:const InputDecoration(labelText:'Description')),
   const SizedBox(height:12),
   OutlinedButton.icon(onPressed:()async{final x=await picker.pickImage(source:ImageSource.gallery,imageQuality:85);if(x!=null){bytes=await x.readAsBytes();file=x.name;setD((){});}},icon:const Icon(Icons.photo_library),label:Text(file??'Choose product photo'))
 ])),actions:[
   TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Cancel')),
   FilledButton(onPressed:()async{
    if(n.text.trim().isEmpty||cat.text.trim().isEmpty)return;
    try{
     String? image;
     if(bytes!=null){final path='products/'+DateTime.now().millisecondsSinceEpoch.toString()+'_'+(file??'photo.jpg');await Supabase.instance.client.storage.from('product-images').uploadBinary(path,bytes!,fileOptions:const FileOptions(upsert:true));image=Supabase.instance.client.storage.from('product-images').getPublicUrl(path);}
     await Supabase.instance.client.from('products').insert({'name':n.text.trim(),'category':cat.text.trim(),'price':double.tryParse(price.text)??0,'stock':int.tryParse(stock.text)??0,'description':desc.text.trim(),'image_url':image});
     if(c.mounted)Navigator.pop(c);if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Product published to the customer app.')));
    }catch(x){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Publish failed: '+x.toString())));}
   },child:const Text('Publish product'))
 ])));
 }

 Widget productList()=>StreamBuilder<List<Map<String,dynamic>>>(stream:Supabase.instance.client.from('products').stream(primaryKey:['id']).order('created_at',ascending:false),builder:(c,s){
  if(s.hasError)return Center(child:Text('Products error: '+s.error.toString()));final r=s.data??[];
  if(r.isEmpty)return const Center(child:Text('No products yet. Tap Upload product.'));
  return ListView.builder(padding:const EdgeInsets.all(12),itemCount:r.length,itemBuilder:(_,i){final p=r[i];return Card(child:ListTile(
   leading:p['image_url']==null?const CircleAvatar(child:Icon(Icons.image)):CircleAvatar(backgroundImage:NetworkImage(p['image_url'].toString())),
   title:Text(p['name'].toString(),style:const TextStyle(fontWeight:FontWeight.w800)),
   subtitle:Text(p['category'].toString()+' • ₦'+p['price'].toString()+' • Stock '+p['stock'].toString()),
   trailing:IconButton(onPressed:()async{await Supabase.instance.client.from('products').delete().eq('id',p['id']);},icon:const Icon(Icons.delete_outline))
  ));});
 });

 Widget orderList()=>StreamBuilder<List<Map<String,dynamic>>>(stream:Supabase.instance.client.from('orders').stream(primaryKey:['id']).order('created_at',ascending:false),builder:(c,s){
  if(s.hasError)return Center(child:Text('Orders error: '+s.error.toString()));final r=s.data??[];
  if(r.isEmpty)return const Center(child:Text('No customer orders yet.'));
  return ListView.builder(padding:const EdgeInsets.all(12),itemCount:r.length,itemBuilder:(_,i){final o=r[i];return Card(child:ExpansionTile(
   title:Text(o['customer_name'].toString(),style:const TextStyle(fontWeight:FontWeight.w800)),
   subtitle:Text('₦'+o['total'].toString()+' • '+o['status'].toString()),
   children:[
    ListTile(leading:const Icon(Icons.phone),title:Text(o['phone'].toString()),subtitle:Text(o['address']?.toString()??'Pickup')),
    Padding(padding:const EdgeInsets.all(12),child:DropdownButtonFormField<String>(value:o['status'].toString(),items:['pending','confirmed','processing','ready','delivered','cancelled'].map((x)=>DropdownMenuItem(value:x,child:Text(x.toUpperCase()))).toList(),onChanged:(x)async{if(x!=null)await Supabase.instance.client.from('orders').update({'status':x}).eq('id',o['id']);setState((){});},decoration:const InputDecoration(labelText:'Order status')))
   ]
  ));});
 });

 @override Widget build(BuildContext c){final pages=[productList(),orderList(),const Center(child:Text('Laz B Empire Owner Centre'))];return Scaffold(
  appBar:AppBar(title:const Text('Laz B Empire Owner',style:TextStyle(fontWeight:FontWeight.w900)),actions:[IconButton(onPressed:()async{await Supabase.instance.client.auth.signOut();if(mounted)Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>const Login()));},icon:const Icon(Icons.logout))]),
  body:pages[tab],floatingActionButton:tab==0?FloatingActionButton.extended(onPressed:addProduct,icon:const Icon(Icons.add),label:const Text('Upload product')):null,
  bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(i)=>setState(()=>tab=i),destinations:const[
   NavigationDestination(icon:Icon(Icons.inventory_2_outlined),selectedIcon:Icon(Icons.inventory_2),label:'Products'),
   NavigationDestination(icon:Icon(Icons.receipt_long_outlined),selectedIcon:Icon(Icons.receipt_long),label:'Orders'),
   NavigationDestination(icon:Icon(Icons.store_outlined),selectedIcon:Icon(Icons.store),label:'Store')
  ])
 );}
}
