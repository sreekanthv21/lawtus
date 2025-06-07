import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lawtus/chewie.dart';
import 'package:lawtus/firebase.dart';
import 'package:video_player/video_player.dart';

class videopage extends StatelessWidget {
  final String videourl;
  final String name;
  final String topic;
  final String videoid;
  const videopage({required this.name,required this.videourl,required this.topic,required this.videoid, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              videoplayer(
                  videoplayercontroller: VideoPlayerController.networkUrl(Uri.parse(videourl)),
                  looping: true,
                  videoid: videoid,
          
              ),
              SizedBox(height: 20,),
              Text(topic,style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold)),
              SizedBox(height: 15,),
              Text(name,style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),)
              
            ],
          ),
        ),
      ),
    );
  }
}