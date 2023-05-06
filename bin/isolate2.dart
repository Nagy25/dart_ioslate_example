import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

void main(List<String> arguments) async {
  do {
    stdout.write('say something:  ');
    final line = stdin.readLineSync(encoding: utf8);
    switch (line?.trim().toLowerCase()) {
      case null:
        continue;
      case 'exit':
        exit(0);
      default:
        final msg = await getMessage(line!);
        print(msg);
    }
  } while (true);
}

Future<String> getMessage(String userInput) async {
  final rp = ReceivePort();
  Isolate.spawn(_communicator, rp.sendPort);

  final broadcast = rp.asBroadcastStream();
  final SendPort communicatorSendPort = await broadcast.first;
  communicatorSendPort.send(userInput);
  return broadcast
      .takeWhile((element) => element is String)
      .cast<String>()
      .take(1)
      .first;
}

void _communicator(SendPort sp) async {
  final rp = ReceivePort();
  sp.send(rp.sendPort);
  final messages = rp.takeWhile((element) => element is String).cast<String>();
  await for (final message in messages) {
    for (final entry in map.entries) {
      if (entry.key.trim().toLowerCase() == message.trim().toLowerCase()) {
        sp.send(entry.value);
        continue;
      }
    }
    sp.send('no have response for that ');
  }
}

const map = {
  "hello": "hi",
  "nagy": "hero",
};
