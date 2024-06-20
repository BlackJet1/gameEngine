import 'package:flutter/material.dart';

import 'engine/engine.dart';
import 'screens/game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Engine.setSize(720, 1280);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        initialRoute: '/jgame',
        routes: {
          //'/jsplash': (BuildContext context) => JSplash(),
          '/jgame': (BuildContext context) => const JGame(),
          //'/jmenu': (BuildContext context) => JMenu(),
        },
        title: 'Space Delivery Boy',
        debugShowCheckedModeBanner: false,
      );
}
