
import 'package:extended_image/extended_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:lawtus/videopage.dart';




class card1 extends StatefulWidget {
  final each;
  final recwatchedinfo;
  final forlecturepage;

  const card1({super.key,required this.each,required this.recwatchedinfo,required this.forlecturepage });

  @override
  State<card1> createState() => _card1State();
}

class _card1State extends State<card1> with TickerProviderStateMixin{
  late final Animation elevation;
  late final Animation offsetx;
  late final Animation offsety;
  late final Animation blurraduis;
  late final Animation size;
  late AnimationController controller;

  void initState(){
    super.initState();
    controller=AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100)
    );
    elevation=Tween<double>(begin: 1,end:0 ).animate(controller);
    offsetx=Tween<double>(begin: 0,end: 0).animate(controller);
    offsety=Tween<double>(begin: 2,end:0 ).animate(controller);
    blurraduis=Tween<double>(begin: 10,end: 2).animate(controller);
    size=Tween<double>(begin: 0,end: 30).animate(controller);
    
    
  }

  String timeoutput(Duration time){

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


  @override
  Widget build(BuildContext context) {
  return GestureDetector(
    onTapCancel: () {
      controller.reverse();
    },
    onTapDown: (details) {
      controller.forward();
    },
    onTapUp: (details)async {
      await Future.delayed(Duration(milliseconds: 150));
      await controller.reverse();

      
      Navigator.push(context, MaterialPageRoute(builder: (context)=>videopage(each: widget.each,recwatchedinfo: widget.recwatchedinfo,pathid: (widget.each['pathid']),pathdir: (widget.each['pathdir']),)));
      
    },
    child: AnimatedBuilder(
      animation: controller,
      builder: (context,child) {
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..translate(0.0, 0.0, size.value),
              
        child: Container(
            margin: EdgeInsets.symmetric(vertical: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(width: 1,color: Color(0xFFBEBAB3)),
              color: Colors.white,
              
            ),
            
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                
                  
                  padding: EdgeInsets.symmetric(vertical: 0,horizontal: 0),
                  
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                    
                    child: AspectRatio(
                      aspectRatio: 16/10,
                      child: ExtendedImage.network(
                        fit: BoxFit.cover,
                        cache: false,
                        'https://lawtusbackend.onrender.com/getimg?dir=${widget.each['img']}',
                        loadStateChanged: (state) {
                          switch(state.extendedImageLoadState){
                            case LoadState.loading:
                            return Center(child: SizedBox(width: 30,height: 30,child: CircularProgressIndicator(color: Color(0xFF7A0045),)));
                            case LoadState.completed:
                            return null;
                            case LoadState.failed:
                            return Center(child: Icon(Icons.error),);
                          }
                        },
                        
                      
                      ),
                    )
                        
                      
                    ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      
                      SizedBox(height: 15,),
                      if(widget.forlecturepage!=0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: (widget.forlecturepage-32)*0.7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(timeoutput(Duration(seconds: widget.each['duration'])),style: TextStyle(fontWeight: FontWeight.w600,fontSize: 12,color: Color(0xFF5BA092)),),
                                SizedBox(height: 3,),
                                Text(widget.each['name'],style: TextStyle(fontSize: 24,fontWeight: FontWeight.w600,height: 0),),
                                SizedBox(height: 3,),
                                Text(widget.each['faculty'],style: TextStyle(fontSize: 15,height: 0,color: Color(0xFF3C3A36)),),
                              ],
                            ),
                          ),
                          SvgPicture.asset(
                            width: (widget.forlecturepage-32)*0.1,
                            'lib/assets/icons/play.svg'
                          )

                        ]
                      ),

                      if(widget.forlecturepage==0)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(timeoutput(Duration(seconds: widget.each['duration'])),style: TextStyle(fontWeight: FontWeight.w600,fontSize: 12,color: Color(0xFF5BA092)),),
                          SizedBox(height: 3,),
                          Text(widget.each['name'],style: TextStyle(fontSize: 24,fontWeight: FontWeight.w600,height: 0),),
                          SizedBox(height: 3,),
                          Text(widget.each['faculty'],style: TextStyle(fontSize: 15,height: 0,color: Color(0xFF3C3A36)),),
                        ],
                      ),

                      SizedBox(height: 25,),
                      
                      
                    ],
                  ),
                )
              ],
            ),
          ),
      );
      }
    ),
  );
        
    }
}

Future<dynamic> dialogs(BuildContext context,{required String title,required String content,required String buttontext,required VoidCallback onpressfunc}) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.white,
          titlePadding: EdgeInsets.all(0),
          
          title: Container(
            decoration: BoxDecoration(
              color: Color(0xFF7A0045),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              border:Border.all(width: 2,color: Color(0xFF7A0045))
            ),
            height: 50,
            alignment: Alignment.center,
            child: Text(title,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Color.fromARGB(255, 255, 255, 255)),),
          ),
          content: Container(
            
            
            child: Text(content,style: TextStyle(color: Color(0xFF3C3A36)),textAlign: TextAlign.center,),
          ),
          actionsPadding: EdgeInsets.only(left: 8,right: 8,bottom: 8,top: 0),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
               
                foregroundColor: WidgetStatePropertyAll(const Color.fromARGB(255, 255, 255, 255)),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),side: BorderSide(color: Color(0xFF7A0045)))),
                minimumSize: WidgetStatePropertyAll(Size(double.infinity,50)),
                backgroundColor: WidgetStatePropertyAll(Color(0xFFFFF5EE))
              ),
              onPressed: onpressfunc,
              child: Text(buttontext,style: TextStyle(fontWeight: FontWeight.w500,color: Colors.black),),
            ),
          ],
        );
      },
      
    );
  }

  Container tutors(image,name,eachone) {
    return Container(
      
      alignment: Alignment.center,
      width: eachone,
      child: Column(
        children: [
          ExtendedImage.network(
            shape: BoxShape.circle,
            fit: BoxFit.cover,
            height: eachone,
            width: eachone,
            cache: false,
            'https://lawtusbackend.onrender.com/getimg?dir=${image}',
            loadStateChanged: (state) {
              switch(state.extendedImageLoadState){
                case LoadState.loading:
                return Image.asset('lib/assets/image/loadinggrey.png');
                case LoadState.completed:
                return null;
                case LoadState.failed:
                return Image.asset('lib/assets/image/loadinggrey.png');
              }
            },
            
          
          ),
          SizedBox(height: 0,),
          if((name is String)==false)
          Container(
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color.fromARGB(142, 217, 217, 217)
            ),
          ),
          if(name is String)
          Text(name,style: TextStyle(fontSize: 16,fontFamily: 'afacad',overflow: TextOverflow.ellipsis,color: Color(0xFF333333),fontWeight: FontWeight.w400),)
        ],
      ),
    );
  }