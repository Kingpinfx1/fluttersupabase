import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    getMyFiles();
    super.initState();
  }

  Future getMyFiles() async {
    final List<FileObject> result = await supabase.storage
        .from('user-images')
        .list(path: supabase.auth.currentUser!.id);

    List<Map<String, String>> myImages = [];

    for (var image in result) {
      final getUrl = supabase.storage
          .from('user-images')
          .getPublicUrl("${supabase.auth.currentUser!.id}/${image.name}");
      myImages.add({
        'name': image.name,
        'url': getUrl,
      });
    }
    return myImages;
  }

  Future uploadFile() async {
    var pickedFile = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.image,
    );
    if (pickedFile != null) {
      try {
        File file = File(pickedFile.files.first.path!);
        String fileName = pickedFile.files.first.name;
        await supabase.storage.from('user-images').upload(
              "${supabase.auth.currentUser!.id}/$fileName",
              file,
            );

        Fluttertoast.showToast(
            msg: "Image uploaded",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
      } catch (e) {
        Fluttertoast.showToast(
            msg: e.toString(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }
  }

  Future<void> deleteFile(String fileName) async {
    try {
      // Delete the file from Supabase storage
      await supabase.storage
          .from('user-images')
          .remove(["${supabase.auth.currentUser!.id}/$fileName"]);

      Fluttertoast.showToast(
          msg: "Image deleted successfully",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);

      // Refresh the page by calling setState
      setState(() {});
    } catch (e) {
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload photo'),
      ),
      // body: FutureBuilder(
      //   future: getMyFiles(),
      //   builder: (context, snapshot) {
      //     if (snapshot.hasData) {
      //       if (snapshot.data.length == 0) {
      //         return Center(
      //           child: Text('No images available'),
      //         );
      //       }
      //       ListView.separated(
      //           separatorBuilder: (context, index) {
      //             return const Divider(
      //               thickness: 2,
      //               color: Colors.black,
      //             );
      //           },
      //           itemCount: snapshot.data.length,
      //           itemBuilder: (context, index) {
      //             Map imageData = snapshot.data[index];

      //             return Row(
      //               mainAxisAlignment: MainAxisAlignment.center,
      //               children: [
      //                 SizedBox(
      //                   height: 200,
      //                   width: 200,
      //                   child: Image.network(
      //                     imageData['url'],
      //                     fit: BoxFit.cover,
      //                   ),
      //                 ),
      //                 IconButton(
      //                   onPressed: null,
      //                   icon: Icon(Icons.delete),
      //                 )
      //               ],
      //             );
      //           });
      //     }
      //     return Center(
      //       child: CircularProgressIndicator(),
      //     );
      //   },
      // ),
      body: FutureBuilder(
        future: getMyFiles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text('No images available'));
          }
          if (snapshot.hasData) {
            return ListView.separated(
              separatorBuilder: (context, index) => const Divider(thickness: 2),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Map imageData = snapshot.data![index];

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 300,
                      width: 300,
                      child: Image.network(
                        imageData['url']!,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // IconButton(
                    //   onPressed: () async {
                    //     // Add delete functionality here
                    //   },
                    //   icon: const Icon(Icons.delete),
                    // ),
                    IconButton(
                      onPressed: () async {
                        // Confirm before deleting
                        bool? confirmDelete = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Confirm Delete"),
                            content: const Text(
                                "Are you sure you want to delete this image?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );

                        // Perform delete if confirmed
                        if (confirmDelete == true) {
                          await deleteFile(imageData['name']);
                        }
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                );
              },
            );
          }
          return const Center(child: Text('No data'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: uploadFile,
        child: Icon(
          Icons.add_a_photo,
        ),
      ),
    );
  }
}
