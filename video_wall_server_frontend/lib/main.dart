import 'package:flutter/material.dart';

import 'package:video_wall_server_frontend/common/theme.dart';
import 'package:video_wall_server_frontend/views/imagelistroute.dart';
import 'package:video_wall_server_frontend/views/looproute.dart';

import 'blocs/server_bloc.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final VideoWallBloc? bloc = VideoWallBloc();
  MyApp({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Wall Server',
      theme: appTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => ImageListRoute(
              title: "Video Wall Server",
              bloc: bloc,
            ),
        '/loop': (context) => LoopRoute(
              bloc: bloc,
            )
      },
    );
  }
}
