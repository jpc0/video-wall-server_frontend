import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var images = ["image1.jpeg", "image2.jpeg", "image3.jpg", "image4.jpg"];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: images.map(_buildItem).toList(),
              ),
            ),
            Container(
              color: Colors.blueAccent,
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    color: Colors.white,
                    onPressed: () => {},
                    child: const Text("Upload"),
                  )
                ],
              ),
            )
          ],
        ));
  }

  Widget _buildItem(image) {
    return ExpansionTile(
      title: Center(child: Text(image)),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              onPressed: () => {},
              child: const Text("Display"),
            ),
            MaterialButton(
              onPressed: () => {},
              child: const Text("View"),
            ),
            MaterialButton(
              onPressed: () => {},
              child: const Text("Delete"),
            ),
          ],
        )
      ],
    );
  }
}
