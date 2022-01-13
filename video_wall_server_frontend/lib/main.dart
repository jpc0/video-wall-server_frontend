import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import 'server_bloc.dart';

void main() async {
  final videowallBlock = VideoWallBloc();
  runApp(MyApp(bloc: videowallBlock));
}

class MyApp extends StatelessWidget {
  final VideoWallBloc? bloc;
  MyApp({
    Key? key,
    this.bloc,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Wall Server',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Video Wall Server', bloc: bloc),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final VideoWallBloc? bloc;

  MyHomePage({Key? key, required this.title, this.bloc}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> uploadimage(String url, PlatformFile image) async {
    var uploadurl = Uri.parse(url);
    var request = http.MultipartRequest("POST", uploadurl);
    request.files.add(http.MultipartFile.fromBytes(
        "file", image.bytes!.toList(),
        filename: image.name));
    var response = await http.Response.fromStream(await request.send());
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: StreamBuilder<UnmodifiableListView<dynamic>>(
          stream: widget.bloc?.images,
          initialData: UnmodifiableListView<dynamic>([]),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: snapshot.data!.map(_buildItem).toList(),
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
                          onPressed: () async {
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles(type: FileType.image);

                            if (result != null) {
                              PlatformFile file = result.files.first;
                              await uploadimage("/upload", file);
                              widget.bloc?.updateImages.add('');
                            }
                          },
                          child: const Text("Upload"),
                        )
                      ],
                    ),
                  )
                ],
              );
            }
            return const CircularProgressIndicator();
          },
        ));
  }

  Widget _buildItem(image) {
    return ExpansionTile(
      title: Center(child: Text(image["file_path"])),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              onPressed: () async {
                var request =
                    http.Request("GET", Uri.parse("/display/${image["id"]}"));
                var response = await request.send();
                widget.bloc?.updateImages.add('');
              },
              child: const Text("Display"),
            ),
            // MaterialButton(
            //   onPressed: () => {},
            //   child: const Text("View"),
            // ),
            MaterialButton(
              onPressed: () async {
                var request =
                    http.Request("GET", Uri.parse("/delete/${image["id"]}"));
                var response = await request.send();
                widget.bloc?.updateImages.add('');
              },
              child: const Text("Delete"),
            ),
          ],
        )
      ],
    );
  }
}
