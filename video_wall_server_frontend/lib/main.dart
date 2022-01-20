import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:video_wall_server_frontend/common/theme.dart';

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
      theme: appTheme,
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
          title: Text(
            widget.title,
            style: Theme.of(context).textTheme.headline1,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<UnmodifiableListView<dynamic>>(
                stream: widget.bloc?.images,
                initialData: UnmodifiableListView<dynamic>([]),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView(
                      children: snapshot.data!.map(_buildItem).toList(),
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
            ),
            Container(
              color: Theme.of(context).primaryColor,
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
                        await uploadimage(
                            "http://backend.woordenlewe.com/upload", file);
                        widget.bloc?.updateImages.add('');
                      }
                    },
                    child: const Text("Upload"),
                  ),
                  MaterialButton(
                    color: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoopRoute(bloc: widget.bloc)),
                      );
                    },
                    child: const Text("Loop"),
                  )
                ],
              ),
            )
          ],
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
                var request = http.Request(
                    "GET",
                    Uri.parse(
                        "http://backend.woordenlewe.com/display/${image["id"]}"));
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
                var request = http.Request(
                    "GET",
                    Uri.parse(
                        "http://backend.woordenlewe.com/delete/${image["id"]}"));
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

class LoopRoute extends StatefulWidget {
  final VideoWallBloc? bloc;
  LoopRoute({Key? key, this.bloc}) : super(key: key);
  final selectedImages = [];
  int loopTime = 5;
  @override
  State<LoopRoute> createState() => _LoopRouteState();
}

class _LoopRouteState extends State<LoopRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Loop Setup"),
        ),
        body: StreamBuilder<UnmodifiableListView<dynamic>>(
          stream: widget.bloc?.images,
          initialData: UnmodifiableListView<dynamic>([]),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  TextField(
                    decoration: const InputDecoration(
                        hintText: "Enter a loop time in seconds, default is 5"),
                    onChanged: (text) {
                      setState(() {
                        widget.loopTime = int.parse(text);
                      });
                    },
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter(RegExp("^[0-9]*\$"),
                          allow: true)
                    ],
                  ),
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
                            if (widget.selectedImages.length < 2) {
                              popupNoItemSelected(context);
                            } else {
                              var ids = "";
                              for (var id in widget.selectedImages) {
                                if (widget.selectedImages.last == id) {
                                  ids = '$ids${id.toString()}';
                                } else {
                                  ids = '$ids${id.toString()},';
                                }
                              }
                              var response = await http.get(Uri.parse(
                                  "http://backend.woordenlewe.com/display_many?ids=$ids&time=${widget.loopTime.toString()}"));
                              var decodedResponse =
                                  jsonDecode(utf8.decode(response.bodyBytes))
                                      as Map;
                              if (decodedResponse["message"] ==
                                  "Loop initiated") {
                                Navigator.of(context).pop();
                                loopSuccess(context);
                              }
                            }
                          },
                          child: const Text("Start Loop"),
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

  Future<dynamic> loopSuccess(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text("Loop started sucessfully."),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> popupNoItemSelected(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text("Please select at least two images"),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildItem(image) {
    return ListTile(
      leading: (widget.selectedImages.contains(image["id"]))
          ? const Icon(Icons.check)
          : null,
      title: Center(child: Text(image["file_path"])),
      onTap: () {
        setState(() {
          (widget.selectedImages.contains(image["id"]))
              ? widget.selectedImages.remove(image["id"])
              : widget.selectedImages.add(image["id"]);
        });
      },
      selectedColor: Colors.blue,
    );
  }
}
