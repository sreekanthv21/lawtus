import 'dart:convert';
import 'dart:io';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class videopage extends StatefulWidget {
  final String pathid;
  final String pathdir;
  final Map each;
  final List recwatchedinfo;

  const videopage({
    required this.pathid,
    required this.pathdir,
    required this.recwatchedinfo,
    required this.each,
    super.key,
  });

  @override
  State<videopage> createState() => _videopageState();
}

class _videopageState extends State<videopage> {
  BetterPlayerController? _controller;
  Duration endpos = Duration.zero;
  String? _debugInfo;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() async {
    // Properly URL-encode the path parameters
    final encodedId = Uri.encodeComponent(widget.pathid);
    final encodedDir = Uri.encodeComponent(widget.pathdir);
    final videoUrl =
        'https://cdn.lawtusprep.org/get-m3u8?id=$encodedId&dir=$encodedDir';

    // Debug: Print the URL being loaded
    print('========== VIDEO DEBUG INFO ==========');
    print('Original Path ID: ${widget.pathid}');
    print('Original Path Dir: ${widget.pathdir}');
    print('Encoded Video URL: $videoUrl');
    print('=======================================');

    // Fetch and print m3u8 content for debugging
    try {
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(videoUrl));
      final response = await request.close();
      if (response.statusCode == 200) {
        final content = await response.transform(utf8.decoder).join();
        //print('========== M3U8 CONTENT ==========');
        //print(content);
        //print('===================================');
      } else {
        //print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      //print('Debug fetch error: $e');
    }

    BetterPlayerDataSource datasource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      videoUrl,
      useAsmsTracks: false,
      videoFormat: BetterPlayerVideoFormat.hls,
      useAsmsSubtitles: false,
      liveStream: false,
    );

    final controller = BetterPlayerController(
      betterPlayerDataSource: datasource,
      BetterPlayerConfiguration(
        autoPlay: true,
        autoDispose: true,
        aspectRatio: 16 / 9,
        fit: BoxFit.contain,
        errorBuilder: (context, errorMessage) {
          //print("BetterPlayer errorBuilder called: $errorMessage");
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error, color: Colors.red, size: 48),
                SizedBox(height: 8),
                Text(
                  'Video unavailable',
                  style: TextStyle(color: Colors.white),
                ),
                if (_debugInfo != null)
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      _debugInfo!,
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );

    // Assign controller first, then add event listener
    _controller = controller;

    // Add event listener to log ALL events for debugging
    controller.addEventsListener((event) async {
      print('BetterPlayer Event: ${event.betterPlayerEventType}');
      if (event.parameters != null) {
        print('Event Parameters: ${event.parameters}');
      }

      if (_controller == null) return;

      if (event.betterPlayerEventType == BetterPlayerEventType.progress) {
        final endpostemp = await _controller?.videoPlayerController?.position;
        if (endpostemp != null) {
          endpos = endpostemp;
        }
      }
      if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
        print('Video initialized successfully!');
        int check = widget.recwatchedinfo.indexWhere((element) {
          return element['uuid'] == widget.each['uuid'];
        });
        if (check != -1) {
          _controller?.seekTo(
            Duration(seconds: widget.recwatchedinfo[check]['time']),
          );
        }
      }
      if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
        print('BetterPlayer EXCEPTION Event: ${event.parameters}');
        setState(() {
          _debugInfo = 'Player exception: ${event.parameters}';
        });
      }
    });

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    int check = widget.recwatchedinfo.indexWhere((element) {
      return element['uuid'] == widget.each['uuid'];
    });

    if (check != -1) {
      widget.recwatchedinfo.removeAt(check);
      widget.recwatchedinfo.insert(0, {
        'time': endpos.inSeconds,
        'uuid': widget.each['uuid'],
      });
    } else {
      if (widget.recwatchedinfo.length > 5) {
        widget.recwatchedinfo.removeLast();
        widget.recwatchedinfo.insert(0, {
          'time': endpos.inSeconds,
          'uuid': widget.each['uuid'],
        });
      } else {
        widget.recwatchedinfo.insert(0, {
          'time': endpos.inSeconds,
          'uuid': widget.each['uuid'],
        });
      }
    }

    FirebaseFirestore.instance
        .collection('students')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({'recwatched': widget.recwatchedinfo}, SetOptions(merge: true));

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
              if (_controller != null)
                ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(20),
                  child: BetterPlayer(controller: _controller!),
                )
              else
                Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
