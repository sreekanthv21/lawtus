import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:lawtus/lecturepage.dart';
import 'package:lawtus/provider.dart';
import 'package:lawtus/quiz.dart';
import 'package:provider/provider.dart';

class subjectspage extends StatefulWidget {
  const subjectspage({super.key});

  @override
  State<subjectspage> createState() => _subjectspageState();
}

class _subjectspageState extends State<subjectspage> with TickerProviderStateMixin{
  final userbox=Hive.box('user');
  late  List<Animation<double>> size=[];
  late  List<AnimationController> controller=[];
  

  void animationmaker(List subinfo){
    size=[];
    controller=[];
    for(int i=0;i<subinfo.length+1;i++){
      final controllereach=AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 100)
      );
      controller.add(controllereach);
      size.add(Tween<double>(begin: 0,end:30).animate(controllereach));
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              padding: EdgeInsets.all(0),
              style: IconButton.styleFrom(
                shape: CircleBorder(),
                side: BorderSide(width: 1,color: const Color.fromARGB(255, 177, 177, 177))
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              icon: SvgPicture.asset('lib/assets/icons/Goback.svg'),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text('Contents',style: TextStyle(fontSize: 24,color: Color(0xFF3C3A36),fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: ValueListenableBuilder(
        valueListenable: context.read<generator1>().alertinfoUpdated,
        builder: (context, value, child) {
          final subjectsinfo=context.read<generator1>().subjectnameinfo;
          final locationinfo=context.read<generator1>().locationinfo;
          animationmaker(subjectsinfo);
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: (subjectsinfo.length)+1 ,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTapCancel: () {
                    controller[index].reverse();
                  },
                  onTapDown: (details) {
                    controller[index].forward();
                  },
                  onTapUp: (details)async {
                    await Future.delayed(Duration(milliseconds: 150));
                    await controller[index].reverse();
                    if(index!=subjectsinfo.length)
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>lecturepage(subject: subjectsinfo[index],location: locationinfo[subjectsinfo[index]] ,)));
                    else
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ChangeNotifierProvider.value( value: generator(FirebaseAuth.instance.currentUser!.uid, userbox.get('batch')),child: quiztoppage())));
                  },
                  child: AnimatedBuilder(
                    animation: controller[index],
                    builder: (context,child) {
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // perspective
                          ..translate(0.0, 0.0, size[index].value),
                        child: Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          height: 100,
                          decoration: BoxDecoration(
                            color: index!=subjectsinfo.length? Colors.white:Color(0xFFFFF5EE),
                            border: Border.all(
                              color: index!=subjectsinfo.length? Color(0xFFCDCDCD):Color(0xFF7A0045),
                              width: 1
                            ),
                            borderRadius: BorderRadius.circular(10)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              if(index!=subjectsinfo.length)
                              Text(subjectsinfo[index],style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18,color: Color(0xFF3C3A36)),),
                              if(index==subjectsinfo.length)
                              Text('Tests',style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18,color: Color(0xFF3C3A36)),)
                            ],
                          ),
                        ),
                      );
                    }
                  ),
                );
              },
            ),
          );
        }
      ),
    );
  }
}