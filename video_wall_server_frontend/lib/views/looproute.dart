import 'dart:collection';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:video_wall_server_frontend/blocs/server_bloc.dart';
import 'package:video_wall_server_frontend/common/theme.dart';

class LoopRoute extends StatefulWidget {
  final VideoWallBloc? bloc;
  LoopRoute({Key? key, this.bloc}) : super(key: key);
  final selectedImages = [];
  int loopTime = 5;

  @override
  State<LoopRoute> createState() => _LoopRouteState();
}

class _LoopRouteState extends State<LoopRoute> {
  void startLoop() async {
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
    var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
    if (decodedResponse["message"] == "Loop initiated") {
      Navigator.of(context).pop();
      loopSuccess(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          label: Text("Start loop",
              style: TextStyle(
                  decoration: (widget.selectedImages.length < 2)
                      ? TextDecoration.lineThrough
                      : null,
                  fontSize: 16)),
          tooltip: (widget.selectedImages.length < 2)
              ? "Please select at least 2 images"
              : "Start loop",
          backgroundColor:
              (widget.selectedImages.length < 2) ? Colors.grey : null,
          onPressed: (widget.selectedImages.length < 2) ? null : startLoop,
          icon: const Icon(
            Icons.loop,
          ),
        ),
        appBar: AppBar(
          title: const Text("Loop Setup"),
        ),
        body: Column(
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
                FilteringTextInputFormatter(RegExp("^[0-9]*\$"), allow: true)
              ],
            ),
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
          ],
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
    );
  }
}
