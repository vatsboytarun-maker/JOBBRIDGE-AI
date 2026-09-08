import 'package:flutter/material.dart';
void main()=>runApp(const JobBridge());
class JobBridge extends StatelessWidget{
 const JobBridge({super.key});
 @override Widget build(BuildContext context)=>MaterialApp(debugShowCheckedModeBanner:false,theme:ThemeData(colorSchemeSeed:Colors.indigo,useMaterial3:true),home:const Home());
}
class Home extends StatefulWidget{const Home({super.key});@override State<Home> createState()=>_HomeState();}
class _HomeState extends State<Home>{
 final tickets=<Map<String,dynamic>>[
 {'name':'Facilities & Administration','location':'Delhi NCR','keywords':'Facilities Manager, Facility Management, Administration Manager, Admin Manager, Vendor Management, AMC Management, SLA Management, Maintenance, Housekeeping, Security, Electrical Maintenance, Interior Projects','score':70,'active':true},
 {'name':'Procurement & Commercial','location':'Delhi NCR','keywords':'Procurement Manager, Purchase Manager, Commercial Manager, Vendor Manager, Contracts Manager, RFQ, Vendor Negotiation, Purchase Order, Quotation, SAP, ERP, Contract Management','score':70,'active':true}
 ];
 void addTicket(){final n=TextEditingController();final k=TextEditingController();showDialog(context:context,builder:(c)=>AlertDialog(title:const Text('Create Job Ticket'),content:Column(mainAxisSize:MainAxisSize.min,children:[TextField(controller:n,decoration:const InputDecoration(labelText:'Ticket name')),TextField(controller:k,maxLines:4,decoration:const InputDecoration(labelText:'Keywords, comma separated'))]),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Cancel')),FilledButton(onPressed:(){if(n.text.trim().isNotEmpty)setState(()=>tickets.add({'name':n.text,'location':'Delhi NCR','keywords':k.text,'score':70,'active':true}));Navigator.pop(c);},child:const Text('Save'))]));}
 @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:const Text('JOBBRIDGE AI 🎫')),floatingActionButton:FloatingActionButton.extended(onPressed:addTicket,label:const Text('Create Ticket'),icon:const Icon(Icons.add)),body:ListView(padding:const EdgeInsets.all(16),children:[const Text('Job Search Tickets',style:TextStyle(fontSize:24,fontWeight:FontWeight.bold)),const SizedBox(height:8),...tickets.map((x)=>Card(child:ExpansionTile(title:Text(x['name']),subtitle:Text('${x['location']} • ${x['score']}% minimum match'),leading:Switch(value:x['active'],onChanged:(v)=>setState(()=>x['active']=v)),children:[Padding(padding:const EdgeInsets.all(16),child:Wrap(spacing:6,runSpacing:4,children:x['keywords'].split(',').where((e)=>e.trim().isNotEmpty).map<Widget>((e)=>Chip(label:Text(e.trim()))).toList()))]))]) );
}