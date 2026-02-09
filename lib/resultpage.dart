import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lawtus/items.dart';


class results extends StatefulWidget {

  final questioninfo;
  final negative;
  final studenttimetaken;
  final totaltime;
  final quizid;
  final submittedpage;
  const results({required this.submittedpage,required this.quizid,required this.negative,required this.questioninfo,super.key,required this.studenttimetaken,required this.totaltime});

  @override
  State<results> createState() => _resultsState();
}

class _resultsState extends State<results> {
  final gotinfo=[];
  ValueNotifier selectedquestion=ValueNotifier(1);
  ValueNotifier currentsubpage=ValueNotifier(0);

  @override
  void initState(){
    super.initState();

  }

  Color setcolor(index,studentanswer){
    int? correctanswer=widget.questioninfo[index.toString()]['answer'];
    int? selectedanswer=studentanswer[index.toString()];
    if(selectedanswer!=null)
    {if(correctanswer==selectedanswer){
      return const Color.fromARGB(255, 237, 255, 237);
    }
    else{
      return const Color.fromARGB(255, 255, 239, 237);
    }
    }else{
      return const Color.fromARGB(255, 255, 255, 255);
    }

  }
  String timeoutput(time){
    
    String subreturn(each){
      if(each.length==1){
        return '0'+each;
      }
      else if(each.length==2){
        return each;
      }
      return each;
    }

    String hh=subreturn((time.inHours).toString());
    String mm=subreturn((time.inMinutes%60).toString());
    String ss=subreturn((time.inSeconds%60).toString());

    return '${hh}:${mm}:${ss}';
  }

  int correctanswers(studentanswer){
    int count=0;
    for (int i=1;i<=widget.questioninfo.length;i++){
      if(widget.questioninfo[i.toString()]['answer']==studentanswer[i.toString()]){
        count++;
      }
    }
    return count;
  }

  double marks(studentanswer){
    double marks=0;
    for (int i=0;i<studentanswer.length;i++){
      if(studentanswer[(i+1).toString()]==widget.questioninfo[(i+1).toString()]['answer']){
        marks+=(widget.questioninfo[(i+1).toString()]['mark']);
      }
      else if(studentanswer[(i+1).toString()]==null){

      }
      else if(studentanswer[(i+1).toString()]!=widget.questioninfo[(i+1).toString()]['answer']){
        marks-=widget.negative;
      }
    }
    return marks;
  }

  double total(){
    double total=0;
    for(int i=0;i<widget.questioninfo.length;i++){
      total+=widget.questioninfo[(i+1).toString()]['mark'];
    }
    return total;
  }

  Color setcolorforoptions(index,studentanswer){
    
  
    if(widget.questioninfo[selectedquestion.value.toString()]['answer']==index){
      return const Color.fromARGB(198, 229, 255, 230);
    }
    else if(index==studentanswer[selectedquestion.value.toString()]){
      return const Color.fromARGB(255, 255, 240, 240);
    }
    else{
      return const Color.fromARGB(255, 255, 255, 255);
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
        surfaceTintColor: Colors.white,
        title: Text(widget.submittedpage==1? 'Results' : 'Answer key',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24,color: Color(0xFF3C3A36)),),centerTitle: true,),
      body: FutureBuilder(
        future: widget.submittedpage==1? FirebaseFirestore.instance.collection('marks').doc(FirebaseAuth.instance.currentUser!.uid).get():null,
        builder: (context, snapshot) {
          Map studentanswer={};
          if(snapshot.connectionState==ConnectionState.waiting){
            return Center(child: SizedBox(width: 30,height: 30,child: CircularProgressIndicator(color: Color(0xFF7A0045),)),);
          }
          else if(snapshot.hasError){
            return Center(child: Text('Check internet connection'),);
          }
          else if(snapshot.hasData){
            studentanswer=snapshot.data!.data()![widget.quizid]['answers'];
          }
          else{
            for(int i = 0;i<widget.questioninfo.keys.toList().length;i++){
              studentanswer[(i+1).toString()]=null;
            }
          }
          
          

          return SingleChildScrollView(
            child: ValueListenableBuilder(
              valueListenable: selectedquestion,
              builder: (context, value, child) {
                return Column(
                  children: [
                    if(widget.submittedpage==1)
                    Container(
                      width: double.infinity,
                      height: 200,
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1,color:Color(0xFFBEBAB3) ),
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(8),
                        
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Column(
                          children: [
                           
                            Expanded(
                              child: PageView(
                                onPageChanged: (value) {
                                  currentsubpage.value=value;
                                },
                                scrollDirection: Axis.horizontal,
                                children: [
                                  analysiscont('Total Marks',marks(studentanswer).toString().toString(),(total().toString()).toString()),
                                  analysiscont('Correct',correctanswers(studentanswer).toString(),(widget.questioninfo.length).toString()),
                                  analysiscont('Attended',((studentanswer.entries.where((e)=>e.value!=null)).length).toString(),(widget.questioninfo.length).toString()),
                                  analysiscont('Unattended',((widget.questioninfo.length)-((studentanswer.entries.where((e)=>e.value!=null)).length)).toString(),(widget.questioninfo.length).toString()),
                                  analysiscont('Wrong',(((studentanswer.entries.where((e)=>e.value!=null)).length)-correctanswers(studentanswer)).toString(),(widget.questioninfo.length).toString()),
                                  Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          
                                          color: Color(0xFF001F3F),
                                  
                                        ),
                                        child: Text('Time Taken',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.w600),)),
                                     
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 25),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  
                                                  Text(timeoutput((widget.studenttimetaken.data()['endtime'].toDate()).difference((widget.studenttimetaken.data()['startedtime'].toDate()))<Duration(minutes:widget.totaltime)?(widget.studenttimetaken.data()['endtime'].toDate()).difference((widget.studenttimetaken.data()['startedtime'].toDate())):Duration(minutes: widget.totaltime)),style: TextStyle(fontSize: 18,color: Color(0xFF3C3A36)),),
                                                  Text(timeoutput(Duration(minutes: widget.totaltime)),style: TextStyle(fontSize: 18,color: Color(0xFF3C3A36)),),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 5,),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 20),
                                              child: LinearProgressIndicator(
                                                value:((widget.studenttimetaken.data()['endtime'].toDate()).difference((widget.studenttimetaken.data()['startedtime'].toDate())).inSeconds)/(widget.totaltime*60) ,
                                                minHeight: 11,
                                                borderRadius: BorderRadius.circular(15),
                                                color: Color(0xFF7A0045),
                                                backgroundColor: Color(0xFFFFF5EE),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  
                                ],
                                
                              ),
                            ),
                            ValueListenableBuilder(
                              valueListenable: currentsubpage,
                              builder: (context, value, child) {
                                return Container(
                                  alignment: Alignment.center,
                                  width: double.infinity,
                                  height: 10,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      6,
                                      (index){
                                        return Container(
                                          margin: EdgeInsets.all(3),
                                          width: 3,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: currentsubpage.value==index?Colors.black:Colors.grey
                                          ),
                                        );
                                      }
                                    ),
                                  ),
                                );
                              }
                            )
                          ],
                        ),
                      ),
                    ),
                          
                    if(widget.submittedpage==0)
                    SizedBox(height: 20,),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                      child: GridView.count(
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        crossAxisCount: 5,
                        shrinkWrap: true,
                        children: List.generate(
                          
                          widget.questioninfo.length,
                          growable: false,
                          (index){
                            return GestureDetector(
                              onTap: () {
                                selectedquestion.value=index+1;
                                
                              },
                              child: Container(
                                
                                alignment: Alignment.center,
                                
                                decoration: BoxDecoration(
                                  border: BoxBorder.all(color: selectedquestion.value==index+1?Color(0xFF7A0045):Color(0xFFBEBAB3),width: selectedquestion.value==index+1?2:1),
                                  borderRadius: BorderRadius.circular(8),
                                  color: setcolor(index+1,studentanswer)
                                ),
                                child: Text((index+1).toString(),style: TextStyle(color: Color(0xFF3C3A36),fontSize: 18),),
                              ),
                            );
                          }
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                   
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 0),
                      child: Container(
                        
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(10)
                        ),
                        
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              
                              children: [
                                
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.center,
                                    
                                    padding: const EdgeInsets.symmetric(horizontal: 0,vertical: 0),
                                    child: Text(widget.questioninfo[selectedquestion.value.toString()]['question'],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24,color: Color(0xFF3C3A36)),overflow: TextOverflow.visible,maxLines: 5,textAlign: TextAlign.center,),),
                                )
                              ],
                            ),
                            SizedBox(height: 10,),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: List.generate(
                                4,
                                (index){
                                  return Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Color(0xFFCDCDCD)
                                      ),
                                      color: setcolorforoptions(index+1,studentanswer),
                                      borderRadius: BorderRadius.circular(8)
                                    ),
                                    
                                    margin: EdgeInsets.symmetric(vertical: 8,horizontal: 0),
                                    padding: EdgeInsets.symmetric(vertical: 22,horizontal: 20),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${optionabcd[index]} . ',style: TextStyle(color: Color(0xFF3C3A36),fontSize: 16),),
                                        SizedBox(width: 5,),
                                        Expanded(child: Text(widget.questioninfo[selectedquestion.value.toString()][(index+1).toString()],style: TextStyle(color: Color(0xFF3C3A36)),overflow: TextOverflow.visible,)),
                                      ],
                                    ),
                                  );
                                }
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                );
              }
            ),
          );
        }
      ),
    );
  }

  Container analysiscont(title,topfunc,bottomfunc) {
    return Container(
        alignment: Alignment.topLeft,
        padding: EdgeInsets.all(0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
               
                
                color: Color(0xFF001F3F),
              ),
              child: Text(title,style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255),fontWeight: FontWeight.bold,fontSize: 20),),
            ),
            
            SizedBox(height: 5,),
            Expanded(
              child: Container(
                
                child: Column(
                  
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(topfunc,style: TextStyle(fontSize: 30),),
                    Container(height: 2,width: 50,color: Colors.black,),
                    Text(bottomfunc,style: TextStyle(fontSize: 30),)
                  ],
                ),
                
              ),
            ),
            
          ],
        ),
      );
  }
}