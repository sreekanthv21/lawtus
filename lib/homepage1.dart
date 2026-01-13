

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lawtus/card.dart';
import 'package:lawtus/provider.dart';
import 'package:lawtus/searchpage.dart';
import 'package:provider/provider.dart';

class homepage1 extends StatefulWidget {

  const homepage1({super.key});

  @override
  State<homepage1> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<homepage1> {
  final userbox=Hive.box('user');
  ValueNotifier selectedalert=ValueNotifier(0);
  PageController pagecontroller=PageController();

  

  @override
  Widget build(BuildContext context) {
        return ChangeNotifierProvider.value(
          value: generator1(userbox.get('batch')),
          child: ChangeNotifierProvider.value(
            value: generator2(),
            child: Builder(
              builder: (context) {
                return Scaffold(
                  backgroundColor: Color.fromARGB(255, 255, 255, 255),
                  body: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 0,bottom: 0,right: 16,left: 16),
                      child: RefreshIndicator.adaptive(
                        backgroundColor: Colors.white,
                        color: Color(0xFF7A0045),
                        elevation: 0.5,
                        displacement: 10,
                        onRefresh: () async{
                          setState(() {
                            
                          });
                        },
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 30,),
                                  Text('Hello,',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w400,color: Color(0xFF3C3A36),letterSpacing:-0.5 ),),
                                  SizedBox(height: 3,),
                                  Text(userbox.get('username'),style: TextStyle(fontSize: 32,fontWeight: FontWeight.w700,color: Color(0xFF333333),letterSpacing:-1 ),),                 
                                  SizedBox(height: 15,)
                                ],
                              ),
                              TextField(
                                readOnly: true,
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ChangeNotifierProvider.value(value: generator2(),child: searchpage())));
                                },
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16,vertical: 20),
                                  hintText: 'Search lectures',
                                  
                                  hintStyle: TextStyle(letterSpacing: 0,fontSize: 14,color: Color(0xFF78746D)),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: Color(0xFFBEBAB3)
                                    ),
                                    borderRadius: BorderRadius.circular(12)
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: Color(0xFFBEBAB3)
                                    ),
                                    borderRadius: BorderRadius.circular(12)
                                  ),
                                  suffixIcon: Padding(
                                    padding: const EdgeInsets.only(left: 5,right: 16,),
                                    child: SvgPicture.asset(
                                      width: 24,
                                      height: 24,
                                      'lib/assets/icons/search.svg'
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 25,),
                              Text('Popular Mentors',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w400,color: Color(0xFF3C3A36),letterSpacing:0 ),),
                              SizedBox(height: 10,),
                              SizedBox(
                                height: 110,
                                child: LayoutBuilder(
                                  builder: (context,constraints) {
                                    final containerwidth = constraints.maxWidth;
                                    final eachone = (containerwidth-44)/5;
                                    return ValueListenableBuilder(
                                      valueListenable: context.read<generator1>().alertinfoUpdated,
                                      builder: (context, value, child) {
                                        if(context.read<generator1>().isloading){
                                          return ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: 5,
                                            itemBuilder: (context, index) {
                                              return Row(
                                                children: [
                                                  tutors(false, false, eachone),
                                                  SizedBox(width: 11,)
                                                ],
                                              );
                                            },
                                          );
                                        }

                                        Map facultyinfo=context.read<generator1>().facultyinfo;

                                        List facultykeys=facultyinfo.keys.toList();

                                        return ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: facultykeys.length,
                                          itemBuilder: (context, index) {
                                            return Row(
                                              children: [
                                                tutors(facultyinfo[facultykeys[index]], facultykeys[index], eachone),
                                                SizedBox(width: 11,)
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    );
                                  }
                                ),
                              ),
                              
                              ValueListenableBuilder(
                                valueListenable: context.read<generator2>().videoinfoUpdated,
                                builder: (context, value, child) {
                                  List selectedvids=[];
                                  Map videos= context.read<generator2>().gotinfo;
                                  Map recwatched= context.read<generator2>().recwatchedinfo;
                                  for(int i=0;i<videos.length;i++){
                                    if(videos[(i+1).toString()]['showinnew'] && videos[(i+1).toString()]['batch'].contains(userbox.get('batch')) ){
                                      selectedvids.add(videos[(i+1).toString()]);
                                    }
                                  }
                                  List reversedselvids=selectedvids.reversed.toList();
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: reversedselvids.length,
                                    itemBuilder: (context,index) {
                                      
                                      return Container(
                                        margin: EdgeInsets.symmetric(vertical: 10),
                                        child: card1(each: reversedselvids[index], recwatchedinfo: recwatched['recwatched'],forlecturepage: 0,)
                                      );
                                    }
                                  );
                                }
                              )
                                          
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                );
              }
            ),
          ),
        );
      }

  
    
  }


  