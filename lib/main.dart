import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'liked_school_page.dart';
import 'sss_app_state.dart';
import 'school_explore_page.dart';
import 'setting_page.dart';

void main() async {
  runApp(const SssApp());
}

class SssApp extends StatelessWidget {
  const SssApp({super.key});

  // This widget is the root of the SgSchoolSafari.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => SssAppState(),
        child: MaterialApp(
          title: 'Sg School Safari',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
            useMaterial3: true,
          ),
          home: SssHomePage(),
        ));
  }
}

class SssHomePage extends StatefulWidget {
  const SssHomePage({super.key});

  @override
  State<SssHomePage> createState() => _SssHomePageState();
}

class _SssHomePageState extends State<SssHomePage> {
  int _currentPageIndex = 0;

  Future<void> _asyncInitializeApp(BuildContext context) async {
    var appState = context.watch<SssAppState>();
    var s = appState.reloadLocalUserSettings();
    return s;
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<SssAppState>();
    return FutureBuilder<void>(
      future: _asyncInitializeApp(context),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (!appState.settingReloadRequired && !snapshot.hasError) {
          return Scaffold(
            bottomNavigationBar: NavigationBar(
              onDestinationSelected: (int index) {
                setState(() {
                  print('selected: $index');
                  _currentPageIndex = index;
                });
              },
              indicatorColor: Colors.amber,
              selectedIndex: _currentPageIndex,
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.search),
                  label: 'Explore',
                ),
                NavigationDestination(
                  icon: Icon(Icons.favorite),
                  label: 'Liked',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings),
                  label: 'Setting',
                ),
              ],
            ),
            body: IndexedStack(
              index: _currentPageIndex,
              children: <Widget>[
                /// Explore Page
                SchoolExplorePage(),
                LikedSchoolPage(),
                SettingPage(),
              ],
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
