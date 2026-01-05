import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:lawtus/card.dart';
import 'package:lawtus/items.dart';
import 'package:lawtus/provider.dart';
import 'package:lawtus/quizquestionspage.dart';
import 'package:lawtus/resultpage.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class quiztoppage extends StatefulWidget {
  
  const quiztoppage({super.key});

  @override
  State<quiztoppage> createState() => _quiztoppageState();
}

class _quiztoppageState extends State<quiztoppage>with TickerProviderStateMixin {
  late AnimationController controller;
  late List <AnimationController> controller2=[];
  late Animation <double> clicking;
  late Animation <double> containerfade;

  late List <Animation <double>>containerclickradius=[];
  late List <Animation <double>>containerclickoffset=[];
  late List <Animation <double>> size=[];
  late List <Animation >containercolor=[];

  var studnetsnapshots=[];
  final timebox=Hive.box('time');
 
  int selectedfilter=1;
  var startedquizlist=[];
  
  final userbox=Hive.box('user');
  final answerbox= Hive.box('answers');
  var gotinfo=[];
  var filtereddata=[];
  var submittedquizlist=[];

  bool isLoadingDialogOpen=false;

  var startedtime;

  void showLoading() {
    
    if (isLoadingDialogOpen) return;

    isLoadingDialogOpen = true;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => PopScope(
        canPop: false,
        child: const Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(color: Color(0xFF7A0045)),
          ),
        ),
      ),
    );
  }
  

  void hideLoading() {
    if (!isLoadingDialogOpen || !mounted) return;

    Navigator.of(context, rootNavigator: true).pop();
    isLoadingDialogOpen = false;
  }

  @override
  void initState(){
    super.initState();
    controller=AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120)
    );
    containerfade=Tween<double>(begin: 0,end: 1).animate(controller);
    
  }
  @override
  void dispose(){
    
    super.dispose();
  }

  void createanimations(){
    containerclickradius=[];
    controller2=[];
    containerclickoffset=[];
    containercolor=[];
    size=[];
    for(int i=0;i<filtereddata.length;i++){
      final controllereach=AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 120)
      );
      controller2.add(controllereach);
      containerclickradius.add(Tween<double>(begin: 0.5,end: 0).animate(CurvedAnimation(parent: controllereach, curve: Curves.easeInOutCubic)));
      containerclickoffset.add(Tween<double>(begin: 1,end: 0).animate(CurvedAnimation(parent: controllereach, curve: Curves.easeInOutCubic)));
      containercolor.add(ColorTween(begin:  Color.fromARGB(255, 235, 241, 241),end: Colors.white).animate(controllereach));
      size.add(Tween<double>(begin: 0,end: 30).animate(CurvedAnimation(parent: controllereach, curve: Curves.easeInOutCubic)));
    }
   
  }
  
  Future<bool> servertimegette1r(snap) async {
  try {
    final res = await http.get(
      Uri.parse('https://lawtusbackend.onrender.com/functogetlivetime'),
    );

    if (res.statusCode != 200) {
      return false;
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final serverTimeStr = data['time'] as String;

    startedtime = DateTime.parse(serverTimeStr);
    timebox.put('startedtime', startedtime);

    final DateTime snapEndTime = snap['endtime'].toDate();
    final int durationMinutes = snap['duration'];

    if (snapEndTime.difference(startedtime) < Duration(minutes: durationMinutes)) {
      timebox.put('endtime', snapEndTime);
    } else {
      final calculatedEndTime =
          startedtime.add(Duration(minutes: durationMinutes));
      timebox.put('endtime', calculatedEndTime);
    }
    return true;
  } catch (e) {
    timebox.clear();
    return false;
  }
}

  Future submissionscheduler(String quizid,initialanswers)async{
    
    final url = Uri.parse('https://lawtusbackend.onrender.com/scheduleWritestudent');
    final payload = {'data':{'quizid':quizid,'uid':FirebaseAuth.instance.currentUser!.uid,'time':timebox.get('endtime').toIso8601String()},'startedtime':startedtime.toIso8601String(),'initialset':initialanswers};
    try{
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if(res.statusCode!=200){
        return false;
      }
    
      return true;
    }catch(e){
     
      return false;
    }
    
  }
  
  Text availabilitytext(snap,snapshotsnap,index){
    if(selectedfilter==0){
      if (startedquizlist.isEmpty){
        if (snap['status']=='available'){
          return Text('Available',style: TextStyle(color: const Color.fromARGB(255, 54, 244, 98),fontSize: 11),);
        }
        else{
          return Text('Not available',style: TextStyle(color: Colors.red,fontSize: 11),);
        }
      }
      if (startedquizlist.isNotEmpty){
        if (filtereddata[index].id==startedquizlist[0].id){
          return Text('In progress',style: TextStyle(fontSize: 12,color: const Color.fromARGB(255, 255, 196, 19)),);
        }
        else{
          return Text('Not Available',style: TextStyle(color: Colors.red,fontSize: 11));
        }
      }
    }
    else if(selectedfilter==1){
      if(snapshotsnap.isNotEmpty)
    {  return Text(convertteddate(timestamp: snapshotsnap[0]['startedtime'].toDate(),),style: TextStyle(color: Color(0xFF3C3A36),fontWeight: FontWeight.bold,fontSize: 12),);}
    }
    else{
      
      return Text(convertteddate(timestamp: snap['endtime'].toDate()),style: TextStyle(color: Color(0xFF3C3A36),fontWeight: FontWeight.bold,fontSize: 12),);
    }
    return Text('');
    
    
  }

  

  void filteringfunc(snapshot){
    filtereddata=[];
    startedquizlist=[];
    submittedquizlist=[];
    var overquizlist=[];
    var gotinfocopy=List.from(gotinfo);
    
    
    submittedquizlist=snapshot.where((doc){
      return (doc.data() as Map)['status']=='submitted';
      }).toList();
    overquizlist=gotinfocopy.where((doc){return doc.data()['status']=='over';}).toList();
    
    
    if(selectedfilter==0){
      startedquizlist=snapshot.where((doc){
      return (doc.data() as Map)['status']=='started';
      }).toList();
    
      
      if(startedquizlist.isNotEmpty)
      {
        for (int i=0;i<gotinfocopy.length;i++){
          if((startedquizlist[0].id)==gotinfocopy[i].id){
            filtereddata.add(gotinfocopy[i]);
            gotinfocopy.removeAt(i);
          }
        }
        for (int i=0;i<submittedquizlist.length;i++){
          for (int j=0;j<gotinfocopy.length;j++){
            if ((submittedquizlist[i].id)==gotinfocopy[j].id){
              gotinfocopy.removeAt(j);
            }
          }
        }
        for(int i=0;i<overquizlist.length;i++){
          for(int j=0;j<gotinfocopy.length;j++){
            if(gotinfocopy[j].id==overquizlist[i].id){
              gotinfocopy.removeAt(j);
            }
          }
        }
        for(int i=0;i<gotinfocopy.length;i++){
          filtereddata.add(gotinfocopy[i]);
        }
      }
      else{
        for (int i=0;i<submittedquizlist.length;i++){
          for (int j=0;j<gotinfocopy.length;j++){
            if ((submittedquizlist[i].id)==gotinfocopy[j].id){
              gotinfocopy.removeAt(j);
            }
          }
        }
        for(int i=0;i<overquizlist.length;i++){
          for(int j=0;j<gotinfocopy.length;j++){
            if(gotinfocopy[j].id==overquizlist[i].id){
              gotinfocopy.removeAt(j);
            }
          }
        }
        for(int i=0;i<gotinfocopy.length;i++){
        filtereddata.add(gotinfocopy[i]);
        }
        
      }
    }
    else if (selectedfilter==1){
      submittedquizlist=snapshot.where((doc){
      return (doc.data() as Map)['status']=='submitted';
      }).toList();
      
      for (int i=0;i<submittedquizlist.length;i++){
        for (int j=0;j<gotinfocopy.length;j++){
          if(submittedquizlist[i].id==gotinfocopy[j].id){
            
            filtereddata.add(gotinfocopy[j]);
          }
        }
      }
      
    }
    else{
      for(int i=0;i<submittedquizlist.length;i++){
        for(int j=0;j<overquizlist.length;j++){
          if(overquizlist[j].id==submittedquizlist[i].id)
          {overquizlist.removeAt(j);}
        }
      }
      for(int i=0;i<overquizlist.length;i++){
        filtereddata.add(overquizlist[i]);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
        title: Text("Tests",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24,color: Color(0xFF3C3A36)),),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 60,
              child: LayoutBuilder(
                builder: (context,constraints) {
                  final containerwidth=constraints.maxWidth;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:List.generate(
                        
                        3,
                        (index){
                          return TextButton(
                            onPressed: () async{
                              await controller.reverse();
                              setState(() {
                             
                                                  
                              controller.forward(from: 0);
                              selectedfilter=index;
                              filteringfunc(studnetsnapshots);
                                              
                              
                            });
                            },
                            style: ButtonStyle(
                             
                              elevation: WidgetStatePropertyAll(0),
                              fixedSize: WidgetStatePropertyAll(Size((containerwidth-48)/3,50)),
                              backgroundColor: WidgetStatePropertyAll(selectedfilter==index?Color(0xFF001F3F):Colors.white),
                              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)))
                            ),
                            child: Text(filter[index],style: TextStyle(color: selectedfilter!=index? Colors.black:Colors.white,fontWeight: FontWeight.bold,fontSize: 12),),
                          
                          );
                        }
                      ) ,
                    ),
                  );
                }
              ),
            ),
            
            
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: context.read<generator>().quizUpdated,
                builder: (context, value, child) {
                  gotinfo=context.read<generator>().gotinfo;
                  studnetsnapshots=context.read<generator>().studnetsnapshots;
                  filteringfunc(studnetsnapshots);
                  createanimations();
                  if(filtereddata.isEmpty){
                    return Center(
                      child: Text('Nothing here'),
                    );
                  }
                  
                  
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount:filtereddata.length ,
                    itemBuilder: (context, index) {
                      var snap=filtereddata[index].data();
                      List extractedsubs=[];
                      for(int i=0;i<snap['questions'].keys.length;i++){
                        extractedsubs.add(snap['questions'][(i+1).toString()]['subject']);
                      }
                      extractedsubs=extractedsubs.toSet().toList();
                   
                      controller.forward();
                      return GestureDetector(
                        onTapDown: (details) {
                          controller2[index].forward();
                        },
                        onTapCancel: () {
                          controller2[index].reverse();
                        },
                        onTap: () async{
                          await Future.delayed(Duration(milliseconds: 150));
                          await controller2[index].forward();
                          controller2[index].reverse();
                          await Future.delayed(Duration(milliseconds: 80));
                          
                          if(selectedfilter==0)
                          {if(startedquizlist.isNotEmpty){
                                  
                                  if(startedquizlist[0].id!=filtereddata[index].id){
                                    dialogs(
                                      context,
                                      content: 'Another quiz is going on',
                                      title: 'Sorry',
                                      buttontext: 'Close',
                                      onpressfunc: () {
                                        Navigator.pop(context);
                                      },
                                    );
                                  }
                                  else{
                                    if(context.mounted){
                                      dialogs(
                                      context,
                                      content: 'Click the button below to continue the quiz',
                                      title: 'Continue quiz',
                                      buttontext: 'Continue',
                                      onpressfunc: () {
                                        Navigator.pop(context);
                                        Navigator.push(context, MaterialPageRoute(builder: (context)=>questionspage(questionslist:snap['questions'],quizid: filtereddata[index].id,startedtime: timebox.get('startedtime'),)));
                                      },
                                     );
                                    }
                                  }
                                }
                                if(startedquizlist.isEmpty){
                                  if(snap['status']=='available'){
                                    if(context.mounted){
                                      dialogs(
                                        context,
                                        title: 'Confirmation',
                                        content: 'Click below to start.',
                                        buttontext: 'Start',
                                        onpressfunc: () async{
                                          
                                          showLoading();
                                      
                                          // quiz confirm + error handling
                                          bool timegetterbool=await servertimegette1r(snap);
                                          bool schedulerbool=false;

                                          Map initialanswers={};
                                          for(int i=0;i<snap['questions'].entries.length;i++){
                                            initialanswers[(i+1).toString()]=null;
                                          }
                               
                                          if(timegetterbool==true){
                                            schedulerbool=await submissionscheduler(filtereddata[index].id,initialanswers);
                                          }
                                          else{
                                            hideLoading();
                                            if(context.mounted){
                                              Navigator.pop(context);
                                            }
                                            if(context.mounted){
                                              dialogs(
                                                context,
                                                content: 'Check network',
                                                title: 'Error',
                                                buttontext: 'Close',
                                                onpressfunc: () {
                                                  Navigator.pop(context);
                                                },
                                              );
                                            }
                                          
                                            return;
                                          }

                                          if(schedulerbool==true){
                                            
                                            hideLoading();
                                            
                                            if(context.mounted){
                                              Navigator.pop(context);
                                            }
                                            
                                            answerbox.clear();
                                            if(context.mounted){
                                              Navigator.push(context, MaterialPageRoute(builder: (context)=>questionspage(questionslist: snap['questions'],quizid: filtereddata[index].id,startedtime: timebox.get('startedtime'),)));
                                            }
                                            
                                          } 
                                          else{
                                            hideLoading();
                                            if(context.mounted){
                                              Navigator.pop(context);
                                            }
                                            if(context.mounted){
                                              dialogs(
                                                context,
                                                content: 'Check network',
                                                title: 'Error',
                                                buttontext: 'Close',
                                                onpressfunc: () {
                                                  Navigator.pop(context);
                                                },
                                              );
                                            }
                                          
                                            return;
                                          }
                                          
                                     
                                          
                                        },
                                      );
                                    }
                                    
                                  }
                                else if(snap['status']=='missed'){
                                }
                                else{
                                  if(context.mounted){
                                    dialogs(
                                      context,
                                      content: 'Quiz not available yet!',
                                      title: 'Sorry',
                                      buttontext: 'Close',
                                      onpressfunc: () {
                                        if(context.mounted){
                                          Navigator.pop(context);
                                        }
                                      },
                                    );
                                  }
                                }
                                }}
                                else if(selectedfilter==1){
                                  if(snap['showresult']==true){
                                    if(context.mounted){
                                      dialogs(
                                        context,
                                        title: 'Results',
                                        content: 'Results Available',
                                        buttontext: 'Show result',
                                        onpressfunc:() {
                                          Navigator.pop(context);
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=>results(submittedpage: 1,totaltime: snap['duration'],studenttimetaken:(studnetsnapshots.firstWhere((doc){ return doc.id==filtereddata[index].id;})) , questioninfo: snap['questions'],negative: snap['negmark'],quizid: filtereddata[index].id,)));
                                        },
                                      );
                                    }
                                    
                                  }
                                  else{
                                    if(context.mounted){
                                      dialogs(
                                        context,
                                        title: 'Results',
                                        content: 'Results will be available soon',
                                        buttontext: 'Close',
                                        onpressfunc: () {
                                          Navigator.pop(context);
                                        },
                                      );
                                    }
                                  }
                                }
                                else if(selectedfilter==2){
                                  if(context.mounted){
                                    dialogs(
                                      context,
                                      title: 'Answer Key',
                                      content: 'Check answer key',
                                      buttontext: 'Open',
                                      onpressfunc: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>results(submittedpage: 0,totaltime: null,studenttimetaken:null , questioninfo: snap['questions'],negative: null, quizid: filtereddata[index].id,)));

                                      },
                                    );
                                  }
                                }
                                
                        },
                        child: FadeTransition(
                          opacity: containerfade,
                          child: AnimatedBuilder(
                            animation:controller2[index] ,
                            builder: (context,child) {
                    
                              return Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001) // perspective
                                  ..translate(0.0, 0.0, size[index].value),
                                child: Container(
                                  
                                  padding: EdgeInsets.symmetric(horizontal: 22,vertical: 15),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: Color(0xFFCDCDCD)
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Color.fromARGB(255, 255, 255, 255)
                                  ),
                                  margin: EdgeInsets.symmetric(vertical: 5,horizontal: 16),
                                  child: Column(
                                    children: [
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                flex: 6,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(snap['quizname'],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,color: Color.fromARGB(255, 26, 25, 23)),),
                                                    SizedBox(height: 4,),
                                                    
                                                        
                                                    if(extractedsubs.length==1)
                                                    Container(
                                                        
                                                        decoration: BoxDecoration(
                                                          color: const Color.fromARGB(255, 255, 255, 255),
                                                          borderRadius: BorderRadius.circular(10)
                                                        ),
                                                        child: Text(extractedsubs[0],style: TextStyle(color: const Color(0xFF001F3F),fontWeight: FontWeight.w500,fontSize: 14),),
                                                      ),
                                                    
                                                    if(extractedsubs.length!=1)
                                                    Container(
                                                      
                                                      decoration: BoxDecoration(
                                                        color: const Color.fromARGB(255, 255, 255, 255),
                                                        borderRadius: BorderRadius.circular(10)
                                                      ),
                                                      child: Text('Mock test',style: TextStyle(color: const Color(0xFF001F3F),fontWeight: FontWeight.w500,fontSize: 14),),
                                                    ),
                                                        
                                                      
                                                    SizedBox(height: 5,),
                                                    
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  Container(
                                                    
                                                    alignment: Alignment.center,
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: const Color.fromARGB(255, 255, 255, 255),
                                                      borderRadius: BorderRadius.circular(10)
                                                    ),
                                                    child: availabilitytext(
                                                      snap,
                                                      studnetsnapshots.where((doc){return doc.id==filtereddata[index].id;}).toList(),
                                                      index
                                                                        
                                                    )
                                                    
                                                  ),
                                                  
                                                ],
                                              ),
                                              
                                              
                                                  
                                            ],
                                          ),
                                          SizedBox(height: 10,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF7A0045),
                                                  borderRadius: BorderRadius.circular(10)
                                                ),
                                                child: Text(converttedtime(timestamp: snap['starttime'].toDate()),style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 12),),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                                  height: 1,
                                                  
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey,
                                                    
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF7A0045),
                                                  borderRadius: BorderRadius.circular(10)
                                                ),
                                                child: Text(converttedtime(timestamp: snap['endtime'].toDate()),style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 12),),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10,),
                                                
                                          Container(
                                            margin: EdgeInsets.symmetric(horizontal: 0),
                                            width: double.infinity,
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(255, 255, 237, 224),
                                              borderRadius: BorderRadius.circular(10)
                                            ),
                                            child: Text('${snap['duration']} minutes',style: TextStyle(fontSize: 12,color: Color(0xFF3C3A36),fontWeight: FontWeight.bold),)
                                            
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          ),
                        ),
                      );
                    },
                    ),
                  );
                }
              ),
            )
                
              
            
          ],
        ),
      ),
    );
  }
}