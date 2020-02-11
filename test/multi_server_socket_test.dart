// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:multi_server_socket/multi_server_socket.dart';
import 'package:multi_server_socket/src/utils.dart';

import 'package:test/test.dart';

void main() {
  group('with multiple ServerSockets', () {
    ServerSocket multiServer;
    ServerSocket subServer1;
    ServerSocket subServer2;
    ServerSocket subServer3;
    setUp(() async {
      subServer1 = await ServerSocket.bind('127.0.0.1', 0);
      subServer2 = await ServerSocket.bind('127.0.0.1', 0);
      subServer3 = await ServerSocket.bind('127.0.0.1', 0);
      multiServer = MultiServerSocket([subServer1, subServer2, subServer3]);
    });

    tearDown(() => multiServer.close());

    test('listen listens to all servers', () async {
      multiServer.listen((socket) {
        socket.add([1, 2, 3, 4]);
        socket.close();
      });

      expect(
          (await _connect(subServer1)).first, completion(equals([1, 2, 3, 4])));
      expect(
          (await _connect(subServer2)).first, completion(equals([1, 2, 3, 4])));
      expect(
          (await _connect(subServer3)).first, completion(equals([1, 2, 3, 4])));
    });

    test('close closes all servers', () async {
      await multiServer.close();

      expect(
          () => _connect(subServer1), throwsA(TypeMatcher<SocketException>()));
      expect(
          () => _connect(subServer2), throwsA(TypeMatcher<SocketException>()));
      expect(
          () => _connect(subServer3), throwsA(TypeMatcher<SocketException>()));
    });
  });

  group('MultiServerSocket.loopback', () {
    ServerSocket server;
    setUp(() async {
      server = await MultiServerSocket.loopback(0);
    });

    tearDown(() => server.close());

    test('listens on all localhost interfaces', () async {
      server.listen((socket) {
        socket.add([1, 2, 3, 4]);
        socket.close();
      });

      if (await supportsIPv4) {
        var socket = await Socket.connect('127.0.0.1', server.port);
        expect(socket.first, completion(equals([1, 2, 3, 4])));
      }

      if (await supportsIPv6) {
        var socket = await Socket.connect('::1', server.port);
        expect(socket.first, completion(equals([1, 2, 3, 4])));
      }
    });
  });
}

/// Connects a socket to [server].
Future<Socket> _connect(ServerSocket server) =>
    Socket.connect(server.address.host, server.port);
