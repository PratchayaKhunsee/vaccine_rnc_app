// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'src/webservice.dart';
import 'src/widgets.dart';
// import 'src/js.dart';
import 'app/modules.dart';

class _LoadingScreenState extends State<_LoadingScreen> {
  bool completed = false;
  String initialRoute = '/';
  @override
  Widget build(BuildContext context) {
    if (!completed) {
      Future<void> preLoginAuth() async {
        try {
          await VaccineRNCDatabaseWS.preLoginAuthentication();
        } catch (e) {
          throw false;
        }
      }

      void changeState(bool bypassLogin) {
        setState(() {
          completed = true;
          initialRoute = bypassLogin ? '/home' : '/login';
        });
      }

      preLoginAuth().then((_) {
        changeState(true);
      }).catchError((_) {
        changeState(false);
      });

      return Material(
        color: Colors.white,
        child: Container(
          child: Center(
            child: SimpleProgressIndicator(
              size: ProgressIndicatorSize.extraLarge,
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      initialRoute: initialRoute,
      routes: <String, Widget Function(BuildContext context)>{
        '/': (context) => Container(),
        '/login': (context) => Login(),
        '/home': (context) => Home(),
        '/signup': (context) => SignUp(),
        '/user': (context) => User(),
        '/parenting': (context) => Parenting(),
        '/record': (context) => Record(),
        '/certificate': (context) => Certificate(),
      },
    );
  }
}

/// Use it when
class _LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _LoadingScreen();
  }
}
