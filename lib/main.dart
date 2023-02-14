import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

void main() {
  runApp(const MyApp());
  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(250, 275);
    win.minSize = initialSize;
    win.size = initialSize;
    win.maxSize = initialSize;
    win.alignment = Alignment.topRight;
    win.title = "Simple Mail";
    win.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Mail',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Simple Mail'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final cuerpoControl = TextEditingController();
  final nameControl = TextEditingController();

  late bool booleanCondition = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            WindowTitleBarBox(
              child: Row(
                children: [
                  Expanded(
                    // ignore: avoid_unnecessary_containers
                    child: Container(
                      child: MoveWindow(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "Simple Mail",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                bottom: 10,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextField(
                      controller: nameControl,
                      decoration: const InputDecoration(hintText: "Your Name"),
                    ),
                    TextField(
                      controller: cuerpoControl,
                      decoration: const InputDecoration(
                        hintText: "Your Text",
                      ),
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      maxLines: 6,
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: booleanCondition
                  ? () async {
                      await sendMyMail(
                        cuerpoControl.text
                            .replaceAll('\n', '<br>&nbsp;&nbsp;&nbsp;&nbsp;'),
                        nameControl.text,
                      );
                    }
                  : null,
              child: const Text("Send Mail"),
            ),
          ],
        ),
      ),
    );
  }

  sendMyMail(String cuerpo, String nombre) async {
    setState(() {
      booleanCondition = false;
    });

    final mensaje = Message()
      ..from = const Address('your.email@address', 'Your Name')
      ..recipients = ['destination@email']
      ..subject = 'Subject text'
      ..html =
          """Message body: <br>&nbsp;&nbsp;&nbsp;&nbsp;<b>$cuerpo</b><br><br>
          Mail sent by: <b>$nombre</b>""";

    try {
      await send(mensaje, loading('your.email@address', 'YourPassword'));

      // ignore: use_build_context_synchronously
      _showDialog(context);

      cuerpoControl.clear();

      setState(() {
        booleanCondition = true;
      });
    } on MailerException catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }
}

void _showDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Information"),
        content: const Text("Your message has been sent"),
        actions: <Widget>[
          TextButton(
            child: const Text("Ok"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

SmtpServer loading(String username, String password) =>
    SmtpServer('mail.server',
        port: 465, ssl: true, username: username, password: password);
