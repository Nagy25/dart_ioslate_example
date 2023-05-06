import 'dart:isolate';

void main(List<String> arguments) async {
  await for (final msg in getMessages().take(10)) {
    print(msg);
  }
}

Stream<String> getMessages() {
  final rp = ReceivePort();
  final data = Isolate.spawn(_getMessages, rp.sendPort);
  final stream = data.asStream().asyncExpand((event) => rp);
  return stream.cast();
}

Future<void> _getMessages(SendPort sp) async {
  await for (final now in Stream.periodic(const Duration(milliseconds: 300),
      (_) => DateTime.now().toIso8601String())) {
    sp.send(now);
  }
}
