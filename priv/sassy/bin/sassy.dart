import 'package:sass/sass.dart' as sass;
import 'dart:io' as io;

void myPrinter(List <int> event) {
  for (var i = 0; i < event.length; i ++) {
    print(event[i]);
  }
}

void main(List<String> arguments) {
  final subscription = io.stdin.listen(myPrinter);
}