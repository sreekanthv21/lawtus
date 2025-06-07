import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


Future addtoDB({required String name,required String username })async{
  try{
    await FirebaseFirestore.instance.collection('students').doc(username).set({
      'username':username,
      'name':name,
      
    });
  }catch(e){
    print(e);
  }
}

class addpage extends StatefulWidget {
  const addpage({super.key});

  @override
  State<addpage> createState() => _addpageState();
}

class _addpageState extends State<addpage> {
  TextEditingController cont1 =TextEditingController();
  TextEditingController cont2 =TextEditingController();
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Name'
              ),
              controller: cont1,
        
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Username'
              ),
              controller: cont2,
            ),
            
            TextButton(
              onPressed:() {
                addtoDB(name: cont1.text, username:cont2.text, );
                setState(() {
                  cont1.clear();
                  cont2.clear();
               
                });
              },
              child: Text('add'),
            )
          ],
        ),
      ),
    );
  }
}