import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_proxy/shelf_proxy.dart';
import 'package:tesla_proxy/tesla_proxy.dart' as tesla;

void main(List<String> args) {
  CommandRunner('proxy', 'Tesla API proxy')
    ..addCommand(Run())
    ..run(args);
}

class Run extends Command {
  final name = 'run';
  final description = 'Runs the proxy server.';

  Run() {
    argParser.addOption('port',
        help: 'Proxy port', defaultsTo: '8080', callback: int.parse);
    argParser.addOption('host', help: 'Proxy host', defaultsTo: 'localhost');
    argParser.addOption('token', abbr: 't');
  }

  @override
  FutureOr run() async {
    final port = int.parse(argResults['port']);
    final host = argResults['host'];
    final handler = const shelf.Pipeline()
        .addMiddleware(shelf.logRequests())
        .addMiddleware(tesla.authBlocker())
        .addMiddleware(tesla.proxy((u, r) => argResults['token']))
        .addHandler(proxyHandler('https://owner-api.teslamotors.com'));

    io.serve(handler, host, port);
    print('Tesla API proxy is listening at $host:$port');
  }
}
