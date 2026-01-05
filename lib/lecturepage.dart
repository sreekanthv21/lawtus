import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lawtus/card.dart';
import 'package:lawtus/items.dart';
import 'package:lawtus/popupdocs.dart';
import 'package:lawtus/provider.dart';

import 'package:provider/provider.dart';

class lecturepage extends StatefulWidget {
  final subject;
  final location;
  const lecturepage({required this.subject,required this.location,super.key});
  

  @override
  State<lecturepage> createState() => _lecturepageState();
}

class _lecturepageState extends State<lecturepage> {

  ValueNotifier selectedvideo = ValueNotifier([0,0]);
  ValueNotifier selectedbutton = ValueNotifier(0);
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


  Container conttoshow(each,containerwidth,List recwatedinfo){
    int check= recwatedinfo.indexWhere((element){
      return element['uuid']==each['uuid'];
    });

    int timewatched(){
      if (check!=-1){
        return recwatedinfo[check]['time'];
      }
      else{
        return 0;
      }
    }
    if(selectedvideo.value[0]==each){
  
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: card1(each: selectedvideo.value[0], recwatchedinfo: selectedvideo.value[1],forlecturepage: containerwidth-32,),
        
      );
    }
    else{
 
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
                                                
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Color(0xFFCDCDCD)
            ),
            borderRadius: BorderRadius.circular(8)
          ),
          child: Row(
            children: [
              SizedBox(
                width:containerwidth*0.3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 16/10,
                    child: ExtendedImage.network(
                      
                      fit: BoxFit.cover,
                      'https://lawtusbackend.onrender.com/getimg?dir=${each['img']}',
                    ),
                  ),
                ),
              ),
              SizedBox(width: 20,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(each['name'],style: TextStyle(fontWeight: FontWeight.w600,fontSize: 18,color: Color(0xFF3C3A36)),),
                    SizedBox(height: 10,),
                    LinearProgressIndicator(
                      minHeight: 10,
                      backgroundColor: Color.fromARGB(255, 252, 235, 222),
                      color: Color(0xFF7A0045),
                      borderRadius: BorderRadius.circular(10),
                      value:timewatched().toDouble()/each['duration'] ,
                    )
                  ],
                ),
              ),
              SizedBox(width: 10,)
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: generator2(),
      child: Scaffold(
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
          centerTitle: true,
          surfaceTintColor: Colors.white,
          shape: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20))
          ),
          elevation: 0,
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: Text(widget.subject, style: TextStyle(color:const Color(0xFF3C3A36), fontWeight: FontWeight.bold, fontSize: 24),),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context,constraints) {
              double containerwidth=constraints.maxWidth;
              return Center(
                child: Column(
                  children: [
                    SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ValueListenableBuilder(
                        valueListenable: selectedbutton,
                        builder: (context, value, child) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              2,
                              (index){
                                return TextButton(
                                  style: ButtonStyle(
                                    fixedSize: WidgetStatePropertyAll(Size((containerwidth-40)/2,50)),
                                    backgroundColor: WidgetStatePropertyAll(selectedbutton.value==index? Color(0xFF001F3F):Colors.white),
                                    foregroundColor: WidgetStatePropertyAll(selectedbutton.value==index? Colors.white:Color(0xFF333333)),
                                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)))
                                  ),
                                  onPressed: () {
                                    selectedbutton.value=index;
                                    _pageController.animateToPage(index, duration: Duration(milliseconds: 250), curve: Curves.easeInOut);
                                  },
                                  child: Text(buttonsinlecturepage[index],style: TextStyle(fontSize: 12),),
                                );
                              }
                            )
                          );
                        }
                      ),
                    ),
                    SizedBox(height: 16,),
                    
                    Expanded(
                      child: PageView(
                        onPageChanged: (value) {
                          selectedbutton.value=value;
                        },
                        controller: _pageController,
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        children: [
                          Column(
                            children: [
                              
                              
                              Container(
                                
                                child: ValueListenableBuilder(
                                  valueListenable: selectedvideo,
                                  builder: (context, value, child) {
                                    return ValueListenableBuilder(
                                      valueListenable: context.read<generator2>().videoinfoUpdated,
                                      builder: (context, value, child) {
                                        final videoinfo=context.read<generator2>().gotinfo;
                                        final recwatchedinfo=(context.read<generator2>().recwatchedinfo)['recwatched'];
                                      
                                        List refinedvideoinfo=[];
                                        for(int i=0;i<videoinfo.length;i++){
                                          if(videoinfo[(i+1).toString()]['subject']==widget.subject && (videoinfo[(i+1).toString()]['batch']).contains(Hive.box('user').get('batch'))){
                                            
                                            refinedvideoinfo.add(videoinfo[(i+1).toString()]);
                                          }
                                        }
                                        List refinedvideoinforeversed=refinedvideoinfo.reversed.toList();

                                        if(context.read<generator2>().isLoading){
                                          return CircularProgressIndicator();
                                        }
                                        else if(refinedvideoinfo.isEmpty){
                                          return Expanded(child: Center(child: Text('No lectures',style: TextStyle(color: Color(0xFF3C3A36)),)));
                                        }
                                        return Column(
                                          children: List.generate(
                                            refinedvideoinforeversed.length,
                                            (index){
                                              Map each=refinedvideoinforeversed[index];
                                              return GestureDetector(
                                                onTap: () {
                                                  selectedvideo.value=[each,recwatchedinfo];
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 5),
                                                  child: conttoshow(each, containerwidth,recwatchedinfo),
                                                )
                                              );
                                            }
                                          ),
                                        );
                                      }
                                    );
                                  }
                                ),
                              ),
                            ],
                          ),
                        
                        ChangeNotifierProvider.value(value: generator3(),child: popuppages(dir: widget.location))
                      ],
                      ),
                    ),
                    
                  ],
                ),
              );
            }
          ),
        ),
      ),
    );
  }
}