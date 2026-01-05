
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:hive_flutter/adapters.dart';
import 'package:lawtus/History.dart';

import 'package:lawtus/coursespage.dart';



import 'package:lawtus/homepage1.dart';
import 'package:lawtus/items.dart';
import 'package:lawtus/profilepage.dart';


class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {

  PageController pagecontroller=PageController();

  late Animation<Color?> coloranim1;
  late Animation<Color?> coloranim2;

  late Animation<Color?> iconcoloranim1;
  late Animation<Color?> iconcoloranim2;
 
  late AnimationController controller1;

  final ValueNotifier selectedpage=ValueNotifier(0);
  
  String? Name;
  late final pref;
  @override
  void initState(){
    super.initState();

    controller1=AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400)
    );
   
    coloranim1=ColorTween(begin: const Color.fromARGB(255, 0, 0, 0),end: Colors.white).animate(controller1);
    coloranim2=ColorTween(begin: Colors.white,end: const Color.fromARGB(255, 0, 0, 0)).animate(controller1);
    
    iconcoloranim1=ColorTween(begin: const Color.fromARGB(255, 255, 255, 255),end: const Color.fromARGB(255, 0, 0, 0)).animate(controller1);
    iconcoloranim2=ColorTween(begin: const Color.fromARGB(255, 0, 0, 0),end: const Color.fromARGB(255, 255, 255, 255)).animate(controller1);
    
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

 
  
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('user').listenable(),
      builder: (context, value, child) {
        if(Hive.box('user').get('username')==null || Hive.box('user').get('batch')==null){
          return Scaffold(backgroundColor: Colors.white,);
        }
        return Scaffold(
          key: _scaffoldKey,
          
          
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              
              
              decoration: BoxDecoration(
                
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 164, 164, 164),
                    spreadRadius: 1,
                    offset: Offset(0, 15),
                    blurRadius: 30
                  )
                ],
                color:Color(0xFF7A0045),
                borderRadius: BorderRadius.circular(16)
              ),
              child: ValueListenableBuilder(
                valueListenable: selectedpage,
                builder: (context, value, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index){
                        return GestureDetector(
                          onTap: () {
                            selectedpage.value=index;
                            pagecontroller.jumpToPage(index);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: SvgPicture.asset(icons[index],color: selectedpage.value==index?Colors.white:const Color.fromARGB(152, 255, 255, 255),),
                          ));
                      }
                    )
                  );
                }
              ),
            ),
          ),
          
        body: PageView(
          controller: pagecontroller,
          pageSnapping: true,
          onPageChanged: (pgno) {
            selectedpage.value=pgno;
            
          },
          children: [
            homepage1(),
            historypage(),
            coursespage(),
            profilepage(),
          ],
        ),
        
        );
      }
    );
  }

  

  
  

  
}