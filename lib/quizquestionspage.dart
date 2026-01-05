import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lawtus/card.dart';
import 'package:lawtus/items.dart';
import 'package:slide_countdown/slide_countdown.dart';
import 'package:http/http.dart' as http;

class questionspage extends StatefulWidget {
  final questionslist;
  final quizid;
  final startedtime;
  

  const questionspage({required this.startedtime,required this.questionslist,required this.quizid,super.key});

  @override
  State<questionspage> createState() => _questionspageState();
}

class _questionspageState extends State<questionspage> with WidgetsBindingObserver{
  final answerbox= Hive.box('answers');
  final PageController pagecontroller=PageController();
  final timebox= Hive.box('time');
 
  var duration=null;
  var selectedquestion;
  late final connectionstate;
  void write(int q,int a){
    answerbox.put(q, a);
    setState(() {
      
    });
  }
  bool isLoadingDialogOpen=false;
  
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
  Future setduration()async{
    final data1=await FirebaseFunctions.instance.httpsCallable('functogetlivetime').call();
    
    duration=(timebox.get('endtime')).difference(DateTime.parse(data1.data['time']));
    
    setState(() {
      
    });
  }

  void questiononpageselectorfrombottomsheet(page){
    pagecontroller.jumpToPage(page);
    selectedquestion=page;
    setState(() {
      
    });
  }

  void questiononpageselectorfrompageview(page){
    selectedquestion=page;
    setState(() {
      
    });
  }

  Color colorseteachtile(index){
    if (read(index+1)==null){
      return const Color.fromARGB(255, 255, 255, 255);
    }
    else
    {return  Color.fromARGB(255, 255, 215, 186);}
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state==AppLifecycleState.resumed){
      duration=null;
      setduration();
      setState(() {
        
      });
      
    }
  }
  int? read(int q){
    return answerbox.get(q);
  }

    Future submitteranddeleter()async{
    
    final url = Uri.parse('https://lawtusbackend.onrender.com/deletecloudtaskstudent');
    final payload = {'uid':FirebaseAuth.instance.currentUser!.uid,'quizid':widget.quizid};
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

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    duration=null;
    setduration();
   
  }

  @override
  void dispose(){
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
 
  
  @override
  Widget build(BuildContext context) {
    if(duration==null)
    {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7A0045),
              ),
            ),
          ),
        ],
      ),
    );}
    if(duration!=null)
    {return Scaffold(
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
        title: Text('Questions',style: TextStyle(fontWeight: FontWeight.bold,color: Color(0xFF3C3A36),fontSize: 24),),centerTitle: true,backgroundColor: Colors.white,surfaceTintColor: Colors.white,),
      body: Stack(
        children: [SafeArea(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: SlideCountdownSeparated(
                 
                  onDone: () async{
                    var maptoupload={};
                    for(int i=0;i<widget.questionslist.length;i++){
                      maptoupload[(i+1).toString()]=answerbox.get(i+1);
                      
                    }
                    await FirebaseFirestore.instance.collection("students").doc(FirebaseAuth.instance.currentUser!.uid).collection('tests').doc(widget.quizid).update({'answer':maptoupload,'status':'submitted','endtime':FieldValue.serverTimestamp()});
                    
                    if(context.mounted){
                      Navigator.pop(context);
                    }
                    
                  },
                  duration: duration,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(5)
                  ),
                  separator: ':',
                ),
              ),
              
              Expanded(
                child: PageView.builder(
                  onPageChanged: (value) {
                    questiononpageselectorfrompageview(value);
                  },
                  controller: pagecontroller,
                  
                  
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.questionslist.length,
                  itemBuilder: (context, index) {
                    if(widget.questionslist.isEmpty){
                      return Center(child: Text('not yet'),);
                    }
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 30,),
                            Container(
                              alignment: Alignment.center,
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(widget.questionslist['${index+1}']['question'],style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600,color: Color(0xFF3C3A36)),textAlign: TextAlign.center,softWrap: true,),
                              ),
                            ),
                            SizedBox(
                              child: ValueListenableBuilder(
                                valueListenable: answerbox.listenable(),
                                builder: (context, value, child) {
                                  var maptoupload={};
                                  for(int i=0;i<widget.questionslist.length;i++){
                                    maptoupload[(i+1).toString()]=answerbox.get(i+1);
                                   
                                    
                                  }
                                  
                                   try{
                                    FirebaseFirestore.instance.collection("marks").doc(FirebaseAuth.instance.currentUser!.uid).set({ widget.quizid:{'answers': maptoupload,'startedtime':widget.startedtime}},SetOptions(merge: true));
                                  }catch(e){
                                    dialogs(
                                      context,
                                      content: "Check internet connection",
                                      buttontext: 'Close',
                                      title: 'Error',
                                      onpressfunc: () {
                                        Navigator.pop(context);
                                      },
                                    );
                                  }
                                  return Column(
                                    children: List.generate(
                                      4,
                                      (index1){
                                        return GestureDetector(
                                          onTap: () {
                                            write(index+1, index1+1);
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width:  read(index+1)==index1+1?2:1,
                                                color: read(index+1)!=index1+1? Color(0xFFCDCDCD):Color(0xFF7A0045)
                                              ),
                                              color:  read(index+1)==index1+1? Color(0xFFFFF5EE):Colors.white,
                                              
                                              borderRadius: BorderRadius.circular(8)
                                            ),
                                            
                                            margin: EdgeInsets.symmetric(vertical: 8,horizontal: 8),
                                            padding: EdgeInsets.symmetric(vertical: 22,horizontal: 20),
                                            child: Row(
                                              children: [
                                                Text('${optionabcd[index1]} . ',style: TextStyle(color: Color(0xFF3C3A36),fontSize: 16),),
                                                SizedBox(width: 5,),
                                                Text(widget.questionslist['${index+1}'][(index1+1).toString()],style: TextStyle(color: Color(0xFF3C3A36)),),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    ),
                                  );
                                }
                              ),
                            ),
                            
                            SizedBox(height: 15,),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: TextButton(
                                style: ButtonStyle(
                                  
                                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                  backgroundColor: WidgetStatePropertyAll(Color(0xFF7A0045)),
                                  minimumSize: WidgetStatePropertyAll(Size(double.infinity,60))
                                ),
                                onPressed: () {
                                  answerbox.delete(index+1);
                                  setState(() {
                                    
                                  });
                                },
                                child: Text('Clear',style: TextStyle(color: Colors.white),),
                              ),
                            ),
                            Container(
                              height: 300,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          child: DraggableScrollableSheet(
            shouldCloseOnMinExtent: true,
            minChildSize: 0.1,
            snap: true,
            snapAnimationDuration: Duration(milliseconds: 100),
            initialChildSize: 0.1,
            maxChildSize: 0.5,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(25),topRight: Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(74, 199, 199, 199),
                      blurStyle: BlurStyle.normal,
                      spreadRadius: 0.1,
                      blurRadius: 4,
                      offset: Offset(0, -2)
                    )
                  ],
                  color: const Color.fromARGB(255, 255, 255, 255)
                ),
                
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 70, 70, 70),
                          borderRadius: BorderRadius.circular(40)
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GridView.count
                          ( crossAxisCount: 5,
                          shrinkWrap: true,
                            children:List.generate(
                            widget.questionslist.length,
                            (index){
                              return GestureDetector(
                                onTap: () {
                                  questiononpageselectorfrombottomsheet(index);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color:colorseteachtile(index),
                                    border: selectedquestion==index? BoxBorder.all(width: 2,color: Color(0xFF7A0045)):BoxBorder.all(style: BorderStyle.none),
                                    borderRadius: BorderRadius.circular(8)
                                  ),
                                  margin: EdgeInsets.all(10),
                                  child: Text('${index+1}',style: TextStyle(color: Color(0xFF3C3A36)),),
                                                      
                                ),
                              );
                            }
                            
                          ),)
                        
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextButton(
                          style: ButtonStyle(
                            minimumSize: WidgetStatePropertyAll(Size(double.infinity,60)),
                            shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10))),
                            backgroundColor: WidgetStatePropertyAll(Color(0xFF7A0045)),
                            
                          ),
                          onPressed: () {
                            var maptoupload={};
                            for(int i=0;i<widget.questionslist.length;i++){
                              maptoupload[(i+1).toString()]=answerbox.get(i+1);
                             
                              
                            }
                            dialogs(
                              context,
                              content: 'Click below to confirm\n submission',
                              title: 'Confirmation',
                              buttontext: 'Confirm',
                              onpressfunc: ()async {
                                showLoading();
                                try{
                                  final submitterres=await submitteranddeleter();
                                  if(submitterres==false){
                                    hideLoading();
                                    if(context.mounted){
                                      Navigator.pop(context);
                                    }
                                    if(context.mounted){
                                      dialogs(
                                        context,
                                        content: "Couldn't submit",
                                        buttontext: 'Close',
                                        title: 'Error',
                                        onpressfunc: () {
                                          Navigator.pop(context);
                                        },
                                      );
                                    }
                                    return;
                                  }
                                  
                                 
                                  if(context.mounted){
                                    Navigator.pop(context);
                                  }
                                  if(context.mounted){
                                    Navigator.pop(context);
                                  }
                                  if(context.mounted){
                                    Navigator.pop(context);
                                  }
                                }catch(e){
                                  hideLoading();
                                  if(context.mounted){
                                    Navigator.pop(context);
                                  }
                                  if(context.mounted){
                                    dialogs(
                                      context,
                                      content: "Couldn't submit",
                                      buttontext: 'Close',
                                      title: 'Error',
                                      onpressfunc: () {
                                        Navigator.pop(context);
                                      },
                                    );
                                  }
                                  
                                }

                              },
                            );
                            
                            
                          },
                          child: Text('Submit',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ]));}
    return Scaffold();
  }
}