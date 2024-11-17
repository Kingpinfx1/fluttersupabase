import 'package:flutter/material.dart';
import 'package:flutter_supabase/auth/login_page.dart';
import 'package:flutter_supabase/screens/addnote.dart';
import 'package:flutter_supabase/screens/editnote.dart';
import 'package:flutter_supabase/screens/upload_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  late Stream<List<Map<String, dynamic>>> _readStream;

  // @override
  // void initState() {
  //   _readStream = supabase
  //       .from('note')
  //       .stream(primaryKey: ['id'])
  //       .eq('user_id', supabase.auth.currentUser!.id)
  //       .order('id', ascending: false);
  //   super.initState();
  // }
  @override
  void initState() {
    super.initState();
    _loadStream();
  }

  void _loadStream() {
    _readStream = supabase
        .from('note')
        .stream(primaryKey: ['id'])
        .eq('user_id', supabase.auth.currentUser!.id)
        .order('id', ascending: false);
  }

  Future<void> _refreshPage() async {
    setState(() {
      _loadStream(); // Re-initialize the stream to fetch fresh data
    });
  }
  // Future<List> readData() {
  //   final notesdata = supabase
  //       .from('note')
  //       .select()
  //       .eq('user_id', supabase.auth.currentUser!.id)
  //       .order('id', ascending: false);
  //   return notesdata;
  // }

  @override
  Widget build(BuildContext context) {
    final SupabaseClient supabase = Supabase.instance.client;
    final User dbuser = Supabase.instance.client.auth.currentUser!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(dbuser.email.toString()),
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => UploadPage(),
                  fullscreenDialog: true,
                ),
              );
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                  )),
              child: Icon(Icons.person),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final navcontext = Navigator.of(context);
              try {
                await supabase.auth.signOut();
                navcontext.pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                );
              } catch (error) {
                Fluttertoast.showToast(msg: 'Signout failed');
              }
            },
            icon: Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: StreamBuilder(
            stream: _readStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
              if (snapshot.hasData) {
                if (snapshot.data!.isEmpty) {
                  return Center(
                    child: Text('No note available'),
                  );
                }
                return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var data = snapshot.data![index];

                      return ListTile(
                        title: Text(data['title']),
                        subtitle: Text(data['description']),
                        trailing: IconButton(
                          onPressed: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditNote(
                                  noteId: data['id'],
                                  title: data['title'],
                                  description: data['description'],
                                ),
                                fullscreenDialog: true,
                              ),
                            );
                          },
                          icon: Icon(Icons.edit),
                        ),
                      );
                    });
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const AddNote(),
            fullscreenDialog: true,
          ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
