import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddNote extends StatefulWidget {
  const AddNote({super.key});

  @override
  State<AddNote> createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
  }

  Future addNote() async {
    String userId = supabase.auth.currentUser!.id;
    final popthecurrentscreen = Navigator.pop(context);
    try {
      await supabase.from("note").insert({
        'title': titleController.text,
        'description': descriptionController.text,
        'user_id': userId,
      });
      popthecurrentscreen;
      Fluttertoast.showToast(
          msg: 'Note added successfully',
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
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              addNote();
            },
            icon: const Icon(
              Icons.note_add,
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
