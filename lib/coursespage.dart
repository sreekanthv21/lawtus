import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lawtus/provider.dart';
import 'package:lawtus/subjectspage.dart';
import 'package:provider/provider.dart';

class coursespage extends StatefulWidget {
  const coursespage({super.key});

  @override
  State<coursespage> createState() => _coursespageState();
}

class _coursespageState extends State<coursespage> {

  final userbox= Hive.box('user');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 0,left: 16,right: 16,bottom: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30,),
              Text('Hello,',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: Color(0xFF3C3A36),letterSpacing:-0.5 ),),
              SizedBox(height: 3,),
              Text(userbox.get('username'),style: TextStyle(fontSize: 32,fontWeight: FontWeight.w700,color: Color(0xFF333333),letterSpacing:-1 ),),                 
              SizedBox(height: 20,),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My courses',style: TextStyle(fontSize: 20,letterSpacing: 0,height: 0),),
                  Text('See All',style: TextStyle(fontSize: 16,letterSpacing: 0,height: 0,color: Color(0xFF333333)),),
                ],
              ),
              SizedBox(height: 15,),
              LayoutBuilder(
                builder: (context,constraints) {
                  final containerwidth= (constraints.maxWidth)*0.6;
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      enableFeedback: true,
                      splashColor: Color.fromARGB(255, 255, 225, 204),
                      highlightColor: Color(0xFFFFF5EE),
                      borderRadius: BorderRadius.circular(10),
                      onTap: () async{
                        await Future.delayed(Duration(milliseconds: 400));
                        HapticFeedback.mediumImpact();
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ChangeNotifierProvider.value(value: generator1(Hive.box('user').get('batch')),child: subjectspage())));
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: SizedBox(
                          width: containerwidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 10,),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: AspectRatio(
                                  aspectRatio: 16/10,
                                  child: ExtendedImage.asset(
                                    fit: BoxFit.cover,
                                    
                                    'lib/assets/image/thumbnail.jpg',
                                    clearMemoryCacheIfFailed: true,
                                    
                                  ),
                                ),
                              ),
                              SizedBox(height: 3,),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(userbox.get('batch'),style: TextStyle(color: Color(0xFF333333),fontSize: 16),),
                              ),
                              SizedBox(height: 8)
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
              )
            ],
          ),
        ),
      ),
    );
  }
}