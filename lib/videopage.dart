import 'package:better_player_plus/better_player_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';




class videopage extends StatefulWidget {
  final String pathid;
  final String pathdir;
  final Map each;
  final List recwatchedinfo;
  
  const videopage({required this.pathid,required this.pathdir,required this.recwatchedinfo,required this.each, super.key});

  @override
  State<videopage> createState() => _videopageState();
}

class _videopageState extends State<videopage> {
  late BetterPlayerController controller1;
  Duration endpos=Duration.zero;
  @override
  void initState(){
    super.initState();
    
    BetterPlayerDataSource datasource=BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      'https://cdn.lawtusprep.org/get-m3u8?id=${widget.pathid}&dir=${widget.pathdir}',
      useAsmsTracks: false,
      videoFormat: BetterPlayerVideoFormat.hls,
      useAsmsSubtitles: false,
      liveStream: false,
      
       
      
      

    );

     controller1=BetterPlayerController(
      betterPlayerDataSource: datasource,
      
      
      BetterPlayerConfiguration(
        eventListener: (p0) async{
          if(p0.betterPlayerEventType==BetterPlayerEventType.progress){
            final endpostemp=await controller1.videoPlayerController!.position ;
            if(endpostemp!=null){
              endpos=endpostemp;
            }
          }
          if(p0.betterPlayerEventType==BetterPlayerEventType.initialized){
            int check=widget.recwatchedinfo.indexWhere((element){
              return element['uuid']==widget.each['uuid'];
            },);
            if(check!=-1){
              controller1.seekTo(Duration(seconds:widget.recwatchedinfo[check]['time']));
            }
          }
        },
        autoPlay: true,
        autoDispose: true,
        aspectRatio: 16/9,
        fit: BoxFit.contain,
        errorBuilder: (context, errorMessage) {
           print("BetterPlayer error: $errorMessage");
           return Text('sdv');},
         
        
        
      )
    );
    
    
  }

  @override
  void dispose(){

    int check=widget.recwatchedinfo.indexWhere((element){
      return element['uuid']==widget.each['uuid'];
    },);

    if(check!=-1){
        
        widget.recwatchedinfo.removeAt(check);
        widget.recwatchedinfo.insert(0, {'time':endpos.inSeconds,'uuid':widget.each['uuid']});
        
      }
      else{
        if(widget.recwatchedinfo.length>5){
          widget.recwatchedinfo.removeLast();
          widget.recwatchedinfo.insert(0, {'time':endpos.inSeconds,'uuid':widget.each['uuid']});
        }
        else{
          widget.recwatchedinfo.insert(0, {'time':endpos.inSeconds,'uuid':widget.each['uuid']});
        }
      }
      
      
      FirebaseFirestore.instance.collection('students').doc(FirebaseAuth.instance.currentUser!.uid).set({'recwatched':widget.recwatchedinfo},SetOptions(merge: true));


    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(borderRadius: BorderRadiusGeometry.circular(20),child: BetterPlayer(controller: controller1))
            ],
          ),
        ),
      ),
    );
  }
}