An implementation of `dart:io`'s [ServerSocket][] that wraps multiple servers
and forwards methods to all of them. It's useful for listening on multiple
network interfaces while still having a unified way of controlling the servers.
In particular, it supports serving on both the IPv4 and IPv6 loopback addresses
using [MultiServerSocket.loopback][].

```dart
import 'package:multi_server_socket/multi_server_socket.dart';

main() async {
  // Sockets connecting to either http://127.0.0.1:8080 and http://[::1]:8080
  // will be emitted by [server].
  var server = await MultiServerSocket.loopback(8080);

  server.listen((socket) {
    // Communicate with [socket].
  });
}
```

[ServerSocket]: https://api.dart.dev/stable/dart-io/ServerSocket-class.html

[MultiServerSocket.loopback]: https://pub.dev/documentation/multi_server_socket/latest/multi_server_socket/MultiServerSocket-class.html
