import 'package:sass/sass.dart' as sass;
import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';

sass.Syntax syntaxFromFormat(Uint8List format) {
  var strFormat = utf8.decode(format, allowMalformed: false);

  if (strFormat == "sass") {
    return sass.Syntax.sass;
  } else if (strFormat == "scss") {
    return sass.Syntax.scss;
  }

  throw ("invalid format $strFormat");
}

// https://stackoverflow.com/questions/54844119/how-to-get-bytes-of-a-string-in-dart
List<int>? toCSS(String source, {sass.Syntax syntax = sass.Syntax.scss}) {
  try {
    var result = sass.compileStringToResult(source,
        syntax: syntax,
        logger: sass.Logger.quiet,
        quietDeps: true,
        verbose: false,
        sourceMap: false);

    if (result.css.isEmpty == false) {
      return utf8.encode(result.css);
    }
  }
  on sass.SassException {}
  catch (error) {}
  return null;
}

// https://stackoverflow.com/questions/57536300/convert-int32-to-bytes-list-in-dart
Uint8List toBytesList(int value) {
  return Uint8List(4)..buffer.asByteData().setUint32(0, value, Endian.big);
}

void main(List<String> arguments) {
  var packet = 4;

  while (true) {
    var buffer = BytesBuilder();

    while (buffer.length < packet) {
      var byte = stdin.readByteSync();
      if (byte < 0) throw("invalid byte while reading packet size $byte");
      buffer.addByte(byte);
    }

    // parse 4 byte packet size as uint32
    var packetSize = ByteData.sublistView(buffer.takeBytes()).getUint32(0, Endian.big);

    // format is 4 bytes
    while (buffer.length < packet) {
      var byte = stdin.readByteSync();
      if (byte < 0) throw("invalid byte while reading format $byte");
      buffer.addByte(byte);
    }

    var syntax = syntaxFromFormat(buffer.takeBytes());

    while (buffer.length < (packetSize - packet))
    {
      var byte = stdin.readByteSync();
      if (byte < 0) throw("invalid byte while reading body $byte");
      buffer.addByte(byte);
    }

    var body = utf8.decode(buffer.takeBytes(), allowMalformed: false);
    var result = toCSS(body, syntax: syntax);

    if (result != null) {
      var encodedLength = toBytesList(result.length);
      stdout.add(encodedLength);
      stdout.add(result);
    } else {
      stdout.add(toBytesList(0)); // send empty str to indicate failure
    }
  }
}
