import 'package:chewie/chewie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lawtus/firebase.dart';
import 'package:video_player/video_player.dart';

class videoplayer extends StatefulWidget {
  final VideoPlayerController videoplayercontroller;
  final bool looping;
  final String videoid;
  
  
  videoplayer({required this.videoplayercontroller,required this.looping,required this.videoid, super.key});

  @override
  State<videoplayer> createState() => _videoplayerState();
}

class _videoplayerState extends State<videoplayer> {
  ChewieController ?chewieController;
  @override
  void initState(){
      chewieController=ChewieController(
      videoPlayerController: widget.videoplayercontroller,
      
      aspectRatio: 16/9,
      autoInitialize: true
    );
    super.initState();
  }
  @override
  void dispose(){
    super.dispose();
    addtorecwatched(
      uid: FirebaseAuth.instance.currentUser!.uid,
      videoid: widget.videoid,
      field: 'lastviewed',
      data: DateTime.now()
    );
    addtorecwatched(
      uid: FirebaseAuth.instance.currentUser!.uid,
      videoid: widget.videoid,
      field: 'timestamp',
      data: widget.videoplayercontroller.value.position.toString()
    );
    widget.videoplayercontroller.dispose();
    chewieController!.dispose();
  }
  @override

  Widget build(BuildContext context) {
    return Container(
      
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),

      ),
      height: 300,

      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(20),
        child: Chewie(
            controller: chewieController!,
          
        ),
      ),
    );
  }
}