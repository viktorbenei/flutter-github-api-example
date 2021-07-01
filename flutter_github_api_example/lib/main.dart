import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

// !!! Don't store your client ID and Secret in the code in an actual production app!
// Generate your own GitHub OAuth App at https://github.com/settings/developers
// Related docs: https://docs.github.com/en/developers/apps/building-oauth-apps/creating-an-oauth-app
const githubExampleClientID = '44e3e830d78863129ec2';
const githubExampleClientSecret = '811750ccf65c2d4872adaf86c27c59ca1d9b0d52';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      // routes: {
      //   '/': (context) => MyHomePage(title: 'Flutter Demo Home Page'),
      //   // '/oauth-redirect-callback': (context) => OAuthCallbackPage(),
      // },
      // initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(
            builder: (context) => MyHomePage(title: 'Flutter Demo Home Page'),
          );
        }

        // // If you push the PassArguments route
        // if (settings.name == PassArgumentsScreen.routeName) {
        //   // Cast the arguments to the correct
        //   // type: ScreenArguments.
        //   final args = settings.arguments as ScreenArguments;

        //   // Then, extract the required data from
        //   // the arguments and pass the data to the
        //   // correct screen.
        //   return MaterialPageRoute(
        //     builder: (context) {
        //       return PassArgumentsScreen(
        //         title: args.title,
        //         message: args.message,
        //       );
        //     },
        //   );
        // }

        // The code only supports
        // PassArgumentsScreen.routeName right now.
        // Other values need to be implemented if we
        // add them. The assertion here will help remind
        // us of that higher up in the call stack, since
        // this assertion would otherwise fire somewhere
        // in the framework.
        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
      onUnknownRoute: (settings) {
        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
    );
  }
}

class OAuthCallbackPage extends StatelessWidget {
  OAuthCallbackPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub OAuth Callback'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'GitHub OAuth callback was successful!',
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  /// Based on https://github.com/Anmol92verma/FlutterGithubClient/blob/master/lib/network/Github.dart
  static Future<Stream<String>> _server() async {
    final StreamController<String> onCode = new StreamController();
    HttpServer server =
        await HttpServer.bind(InternetAddress.loopbackIPv4, 8080, shared: true);
    server.listen((HttpRequest request) async {
      final String? code = request.uri.queryParameters["code"];
      if (code == null) {
        throw 'No code query param found';
      }
      request.response
        ..statusCode = 200
        ..headers.set("Content-Type", ContentType.html.mimeType)
        ..write("<html><h1>You can now close this window</h1></html>");
      await request.response.close();
      await server.close(force: true);
      onCode.add(code);
      await onCode.close();
    });
    return onCode.stream;
  }

  void _login() async {
    Stream<String> onCode = await _server();

    // Scopes documentation: https://docs.github.com/en/developers/apps/building-oauth-apps/scopes-for-oauth-apps
    var flow = new OAuth2Flow(
      githubExampleClientID,
      githubExampleClientSecret,
      scopes: ['user:email'],
    );
    var authUrl = flow.createAuthorizeUrl();
    print("DEBUG: authUrl: $authUrl");
    await url_launcher.launch(
      authUrl,
    );

    final String code = await onCode.first;
    print("Received code " + code);
    try {
      await url_launcher.closeWebView();
    } catch (error) {
      // closeWebView isn't implemented yet for some platforms (macOS, Windows)
      // but we can safely ignore this and the page is opened
      // in the browser.
      print("Failed to close webview: $error");
    }

    try {
      var response = await flow.exchange(code);
      var github =
          new GitHub(auth: new Authentication.withToken(response.token));
      // Use the GitHub Client
      var currentUser = await github.users.getCurrentUser();
      print("Current user email: ${currentUser.email}");
    } catch (error) {
      print("Failed to exchange code with GitHub: $error");
    }
    // setState(() {
    //   // This call to setState tells the Flutter framework that something has
    //   // changed in this State, which causes it to rerun the build method below
    //   // so that the display can reflect the updated values. If we changed
    //   // _counter without calling setState(), then the build method would not be
    //   // called again, and so nothing would appear to happen.
    //   _counter++;
    // });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _login,
        tooltip: 'Login',
        child: Icon(Icons.login),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
