import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditNote extends StatefulWidget {
  final int noteId;
  final String title;
  final String description;

  const EditNote({
    super.key,
    required this.noteId,
    required this.title,
    required this.description,
  });

  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> updateNote() async {
    final popthecurrentscreen = Navigator.pop(context);
    try {
      await supabase.from('note').update({
        'title': titleController.text,
        'description': descriptionController.text,
      }).match({
        'id': widget.noteId,
      });
      Fluttertoast.showToast(
          msg: 'Updated sucessfully',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      popthecurrentscreen;
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

  Future<void> deleteNote() async {
    final popthecurrentscreen = Navigator.pop(context);
    try {
      await supabase.from('note').delete().match({
        'id': widget.noteId,
      });
      popthecurrentscreen;
      Fluttertoast.showToast(
          msg: 'Deleted sucessfully',
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

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
  }

  @override
  void initState() {
    titleController.text = widget.title;
    descriptionController.text = widget.description;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: deleteNote,
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
          IconButton(
            onPressed: updateNote,
            icon: const Icon(
              Icons.check_circle,
              color: Colors.green,
            ),
          )
        ],
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: "title",
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              autofocus: true,
            ),
            Expanded(
              child: TextField(
                controller: descriptionController,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: "enter note",
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
