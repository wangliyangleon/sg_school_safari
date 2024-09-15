import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'sss_app_state.dart';

class LikedSchoolPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<SssAppState>();

    if (appState.savedSchool.isEmpty) {
      return Center(
        child: Text('No saved schools yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have saved '
              '${appState.savedSchool.length} schools:'),
        ),
        for (var name in appState.savedSchool)
          ListTile(
            leading: Icon(Icons.collections),
            title: Text(name),
          ),
      ],
    );
  }
}
