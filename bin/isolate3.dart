import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

void main(List<String> args) async {
  final Responder responder = await Responder.create();
  do {
    stdout.write('say something:  ');
    final line = stdin.readLineSync(encoding: utf8);
    switch (line?.trim().toLowerCase()) {
      case null:
        continue;
      case 'exit':
        exit(0);
      default:
        final msg = await responder.getMessage(line!);
        print(msg);
    }
  } while (true);
}

class Responder {
  final ReceivePort rp;
  final SendPort sp;
  final Stream<dynamic> broadcast;

  Responder(this.rp, this.sp, this.broadcast);
  static Future<Responder> create() async {
    final rp = ReceivePort();
    Isolate.spawn(_communicator, rp.sendPort);
    final broadCastRp = rp.asBroadcastStream();
    final SendPort sp = await broadCastRp.first;
    return Responder(rp, sp, broadCastRp);
  }

  Future<String> getMessage(String userInput) async {
    sp.send(userInput);
    return broadcast
        .takeWhile((element) => element is String)
        .cast<String>()
        .take(1)
        .first;
  }
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
