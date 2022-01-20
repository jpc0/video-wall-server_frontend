import 'dart:collection';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:video_wall_server_frontend/blocs/server_bloc.dart';

class ImageListRoute extends StatefulWidget {
  final VideoWallBloc? bloc;

  const ImageListRoute({Key? key, required this.title, this.bloc})
      : super(key: key);

  final String title;

  @override
  State<ImageListRoute> createState() => _ImageListRouteState();
}

class _ImageListRouteState extends State<ImageListRoute> {
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
            BottomNavigationBar(
              onTap: (value) async {
                if (value == 0) {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(type: FileType.image);
                  if (result != null) {
                    PlatformFile file = result.files.first;
                    await uploadimage(
                        "http://backend.woordenlewe.com/upload", file);
                    widget.bloc?.updateImages.add('');
                  }
                }
                if (value == 1) {
                  Navigator.pushNamed(context, '/loop');
                }
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.upload), label: 'Upload'),
                BottomNavigationBarItem(icon: Icon(Icons.loop), label: 'Loop'),
              ],
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
