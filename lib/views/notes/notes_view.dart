import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as devtools show log;

import '../../constants/routes.dart';
import '../../enums/menu_action.dart';
import '../../services/auth/auth_service.dart';
import '../../services/auth/bloc/auth_bloc.dart';
import '../../services/auth/bloc/auth_events.dart';
import '../../services/cloud/cloud_note.dart';
import '../../services/cloud/firebase_cloud_storage.dart';
import '../../utilities/dialogs/logout_dialog.dart';
import '../../extensions/buildcontext/loc.dart';
import '../notes/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _notesService = FirebaseCloudStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.notes),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
            },
          ),
          PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                devtools.log(value.toString());
                switch (value) {
                  case MenuAction.logout:
                    final shouldLogout = await showLogoutDialog(context);
                    devtools.log(shouldLogout.toString());

                    if (shouldLogout) {
                      context.read<AuthBloc>().add(const AuthEventLogout());
                    }
                }
              },
              itemBuilder: (context) => const [
                    PopupMenuItem<MenuAction>(
                      value: MenuAction.logout,
                      child: Text('Log out'),
                    )
                  ]),
        ],
      ),
      body: StreamBuilder(
        stream: _notesService.allNotes(userId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allNotes = snapshot.data as Iterable<CloudNote>;
                return NotesListView(
                  notes: allNotes,
                  onTapNote: (CloudNote note) async {
                    Navigator.of(context).pushNamed(
                      createOrUpdateNoteRoute,
                      arguments: note,
                    );
                  },
                  onDeleteNote: (note) async {
                    await _notesService.deleteNote(docId: note.id);
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      ),
    );
  }
}
