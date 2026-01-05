import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lawtus/provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class popuppages extends StatefulWidget {
  final dir;

  const popuppages({required this.dir,super.key});

  @override
  State<popuppages> createState() => _popuppagesState();
}

class _popuppagesState extends State<popuppages> with AutomaticKeepAliveClientMixin {

  var fetcheddata=[];
  bool isLoading = true; // Initial loading state
  Set<String> expandedFolders = {}; // Track which folders are expanded
  Map<String, List<String>> folderContents = {}; // Cache folder contents
  Map<String, bool> folderLoading = {}; // Track loading state for each folder
  List recdocsinfo=[];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState(){
    super.initState();
    
    fetchinfo();
  }

  void recdocsupload(Map each)async{
    try{
      int check=recdocsinfo.indexWhere((element){
        return each['path']==element['path'];
      });

      if(check!=-1){
        recdocsinfo.removeAt(check);
        recdocsinfo.insert(0, each);
      }
      else{
        if(recdocsinfo.length>6){
          recdocsinfo.removeLast();
          recdocsinfo.insert(0, each);
        }
        else{
          recdocsinfo.insert(0, each);
        }
      }
      await FirebaseFirestore.instance.collection('students').doc(FirebaseAuth.instance.currentUser!.uid).set({'recdocs':recdocsinfo},SetOptions(merge: true));
      
    }catch(e){
      return;
    }
  }
  
  Future<void> toggleFolder(String folderPath, String folderName) async {
    // Construct full path: if folderPath is empty, use widget.dir + folderName, otherwise folderPath/folderName
    String fullPath;
    if (folderPath.isEmpty) {
      if (widget.dir.isEmpty) {
        fullPath = folderName;
      } else {
        fullPath = '${widget.dir}/$folderName';
      }
    } else {
      fullPath = '$folderPath/$folderName';
    }
    
    setState(() {
      if (expandedFolders.contains(fullPath)) {
        // Collapse folder
        expandedFolders.remove(fullPath);
      } else {
        // Expand folder
        expandedFolders.add(fullPath);
        // If contents not cached, fetch them
        if (!folderContents.containsKey(fullPath)) {
          folderLoading[fullPath] = true;
        }
      }
    });
    
    // Fetch folder contents if not cached
    if (expandedFolders.contains(fullPath) && !folderContents.containsKey(fullPath)) {
      await fetchFolderContents(fullPath);
    }
  }
  
  Future<void> fetchFolderContents(String folderPath) async {
    final fetchedjson = await http.get(
      Uri.parse('https://lawtusbackend.onrender.com/list-filename?dir=$folderPath')
    );

    if (mounted) {
      if (fetchedjson.statusCode == 200) {
        List<String> contents = jsonDecode(fetchedjson.body).cast<String>();
        setState(() {
          folderContents[folderPath] = contents;
          folderLoading[folderPath] = false;
        });
      } else {
        setState(() {
          folderLoading[folderPath] = false;
        });
       
      }
    }
  }
  
  void fetchinfo()async{
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    
    final fetchedjson=await http.get(
      Uri.parse('https://lawtusbackend.onrender.com/list-filename?dir=${widget.dir}')
    );

    if (mounted) {
      if(fetchedjson.statusCode==200){
        fetcheddata=jsonDecode(fetchedjson.body).cast<String>();
        setState(() {
          isLoading = false;
        });
      }
      else{
        setState(() {
          isLoading = false;
        });
        
      }
    }
  }
  Future fetchurl(localdir)async{
   
    final urlbulk=await http.get(
      Uri.parse('https://lawtusbackend.onrender.com/getsignedurl?dir=${localdir}')
    );
   
    
    return urlbulk.body;
  }
  IconData iconreturn(String file){
    if(file.endsWith('/')){
      return Icons.folder;
    }
    else if(file.endsWith('.pdf')){
      return Icons.file_copy;
    }
    else if(file.endsWith('.jpeg')||file.endsWith('.jpg')||file.endsWith('.png')){
      return Icons.image;
    }
    else if(file.endsWith('.txt')){
      return Icons.notes;
    }
    return Icons.error;
  }
  String filenamereturn(String file){
    
    if(file.endsWith('.pdf')||file.endsWith('.jpg')||file.endsWith('.png')||file.endsWith('.txt')){
      return file.substring(0,file.length-4);
    }
    else if(file.endsWith('.jpeg')){
      return file.substring(0,file.length-5);
    }
    return file;
  }

  Widget buildFileItem(String item, String parentPath, int indentLevel) {
    bool isFolder = item.endsWith('/');
    String itemName;
    if (isFolder) {
      itemName = item.substring(0, item.length - 1);
    } else {
      itemName = item;
    }
    // Construct full path: if parentPath is empty, use widget.dir + itemName, otherwise parentPath/itemName
    String fullPath;
    if (parentPath.isEmpty) {
      if (widget.dir.isEmpty) {
        fullPath = itemName;
      } else {
        fullPath = '${widget.dir}/$itemName';
      }
    } else {
      fullPath = '$parentPath/$itemName';
    }
    bool isExpanded = expandedFolders.contains(fullPath);
    bool isLoading;
    if (folderLoading.containsKey(fullPath)) {
      bool? loadingValue = folderLoading[fullPath];
      if (loadingValue != null) {
        isLoading = loadingValue;
      } else {
        isLoading = false;
      }
    } else {
      isLoading = false;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 5,bottom: 5,left: indentLevel*15),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () async {
              if (isFolder) {
                await toggleFolder(parentPath, itemName);
              } else if (item.endsWith('.pdf')) {
                String filePath;
                if (parentPath.isEmpty) {
                  if (widget.dir.isEmpty) {
                    filePath = item;
                  } else {
                    filePath = '${widget.dir}/$item';
                  }
                } else {
                  filePath = '$parentPath/$item';
                }
                final url = await fetchurl(filePath);
                recdocsupload({'path':filePath,'name':item,'displayname':filenamereturn(item)});
                await Future.delayed(Duration(milliseconds: 350));
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Scaffold(
                  appBar: AppBar(
                    surfaceTintColor: Colors.white,
                    shape: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20))
                    ),
                    elevation: 0,
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    title: Text(filenamereturn(item), style: TextStyle(color:const Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold, fontSize: 20),),
                  ),
                  backgroundColor: Colors.white,
                  body: SafeArea(child: SfPdfViewer.network(url)),
                )));
              } else if (item.endsWith('.png') || item.endsWith('.jpg') || item.endsWith('.jpeg')) {
                String filePath;
                if (parentPath.isEmpty) {
                  if (widget.dir.isEmpty) {
                    filePath = item;
                  } else {
                    filePath = '${widget.dir}/$item';
                  }
                } else {
                  filePath = '$parentPath/$item';
                }
                final url = await fetchurl(filePath);
                recdocsupload({'path':filePath,'name':item,'displayname':filenamereturn(item)});
                await Future.delayed(Duration(milliseconds: 350));
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    surfaceTintColor: Colors.white,
                    shape: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20))
                    ),
                    elevation: 0,
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    title: Text(item, style: TextStyle(color:const Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold, fontSize: 20),),
                  ),
                  body: SafeArea(
                    child: PhotoView(
                      imageProvider: NetworkImage(url),
                    ),
                  ),
                )));
              }
            },
            child: Ink(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 15 ,
                vertical: isFolder ? 27 : 18
              ),
              
              decoration: BoxDecoration(
                color: isFolder ? const Color(0xFFFFF5EE) : const Color.fromARGB(0, 255, 255, 255),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Color(0xFFBEBAB3)
                ),
               
              ),
              child: Row(
                children: buildRowChildren(isFolder, isExpanded, item, itemName, isLoading),
              ),
            ),
          ),
        ),
        // Show expanded folder contents
        buildExpandedFolderContents(isFolder, isExpanded, fullPath, indentLevel),
      ],
    );
  }

  List<Widget> buildRowChildren(bool isFolder, bool isExpanded, String item, String itemName, bool isLoading) {
    List<Widget> children = [];
    
    if (isFolder) {
      IconData arrowIcon;
      if (isExpanded) {
        arrowIcon = Icons.keyboard_arrow_down;
      } else {
        arrowIcon = Icons.keyboard_arrow_right;
      }
      children.add(Icon(
        arrowIcon,
        color: const Color(0xFF3C3A36),
        size: 20,
      ));
      children.add(SizedBox(width: 5));
    }
    
    Color iconColor;
    if (isFolder) {
      iconColor = const Color(0xFF3C3A36);
    } else {
      iconColor = const Color(0xFF3C3A36);
    }
    children.add(Icon(
      iconreturn(item),
      color: iconColor,
    ));
    
    children.add(SizedBox(width: 10));
    
    String displayText;
    if (isFolder) {
      displayText = itemName;
    } else {
      displayText = filenamereturn(item);
    }
    
    Color textColor;
    if (isFolder) {
      textColor = const Color(0xFF3C3A36);
    } else {
      textColor = const Color(0xFF3C3A36);
    }
    
    children.add(Flexible(
      child: Text(
        displayText,
        style: TextStyle(
          
          color: textColor,
        ),
      ),
    ));
    
    if (isLoading) {
      Color progressColor;
      if (isFolder) {
        progressColor = Colors.black;
      } else {
        progressColor = Colors.black;
      }
      children.add(Padding(
        padding: EdgeInsets.only(left: 10),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ));
    }
    
    return children;
  }
  
  Widget buildExpandedFolderContents(bool isFolder, bool isExpanded, String fullPath, int indentLevel) {
    if (isFolder && isExpanded && folderContents.containsKey(fullPath)) {
      List<Widget> folderChildren = [];
      List<String>? contentsNullable = folderContents[fullPath];
      if (contentsNullable != null) {
        List<String> contents = contentsNullable;
        for (int i = 0; i < contents.length; i++) {
          String subItem = contents[i];
          folderChildren.add(buildFileItem(subItem, fullPath, indentLevel + 1));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: folderChildren,
        );
      } else {
        return SizedBox.shrink();
      }
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return ValueListenableBuilder(
      valueListenable: context.read<generator3>().recdocsinfoUpdated,
      builder: (context, value, child) {
       
        if (isLoading || context.read<generator3>().isLoading) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Color(0xFF7A0045),),
            ),
          );
        }
        
        if (fetcheddata.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'No documents',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
              ),
            ),
          );
        }
        
        recdocsinfo=context.read<generator3>().recdocsinfo;
        List<Widget> columnChildren = [];
        for (int i = 0; i < fetcheddata.length; i++) {
          String item = fetcheddata[i];
          columnChildren.add(buildFileItem(item, '', 0));
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: columnChildren,
            ),
          ),
        );
      },
    );
    
    
  }
}