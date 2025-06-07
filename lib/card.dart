import 'dart:ui';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class card extends StatelessWidget {
  final String img;
  final String name;
  final String topic;
  
  const card({super.key,required this.img,required this.name,required this.topic });

  @override
  Widget build(BuildContext context) {
  return Container(
        height: 300,
        
        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 10),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              spreadRadius: 0.000001,
              offset: Offset(0, 0),
              blurRadius: 3,
              blurStyle: BlurStyle.normal
            )
          ],
          borderRadius: BorderRadius.circular(20),
          color: Colors.white
        ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(20),
                child: FutureBuilder(
                  future: FirebaseStorage.instance.refFromURL(img).getDownloadURL(),
                  builder: (context, snapshot) {
                    
                    if (snapshot.hasData)
                    return Image.network(snapshot.data!,width: 170,);
                    return SizedBox(width:170);
                  }
                )),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(topic,style: TextStyle(fontWeight: FontWeight.bold),),
                  Text(name)
                ],
              ),
              
            ],
          ),
        );
        
    }
  
  }
String url='';
Future geturl(String img)async{
  url= await FirebaseStorage.instance.refFromURL(img).getDownloadURL();
}

