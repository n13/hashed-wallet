// ignore_for_file: always_put_control_body_on_new_line, prefer_const_constructors, prefer_final_in_for_each, missing_whitespace_between_adjacent_strings, unawaited_futures, duplicate_ignore

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hashed/domain-shared/app_constants.dart';
import 'package:hashed/screens/profile_screens/switch_network/interactor/viewdata/network_data.dart';

extension PlatformExtension on Platform {
  static bool isIos14OrAbove() {
    if (Platform.isIOS) {
      final versionString = Platform.operatingSystemVersion;
      double? version;
      // iOS version string looks like this: "Version 15.5 (Build 0xFC10A)"
      versionString.split(" ").forEach((element) {
        version = version ?? double.tryParse(element);
      });
      //print("iOS version: $version");
      if (version != null) {
        return version! >= 14;
      } else {
        // cannot parse version string - must be > 15
        return true;
      }
    } else {
      return false;
    }
  }

  static bool canRunWasm() {
    if (Platform.isIOS) {
      return PlatformExtension.isIos14OrAbove();
    } else {
      return true;
    }
  }
}

class WebViewRunner {
  HeadlessInAppWebView? _web;
  Function? _onLaunched;

  late String _jsCode;
  Map<String, Function> _msgHandlers = {};
  Map<String, Completer> _msgCompleters = {};
  int _evalJavascriptUID = 0;

  bool webViewLoaded = false;
  int jsCodeStarted = -1;
  Timer? _webViewReloadTimer;

  // For direct JS execution - we don't get the wrapper here
  InAppWebViewController? get webViewController => _web?.webViewController;

  Function? socketDisconnectedAction;

  Future<void> launch(
    Function? onLaunched, {
    Function? socketDisconnectedAction,
  }) async {
    // Get the operating system as a string.
    if (!PlatformExtension.canRunWasm()) {
      // TODO(n13): There's a way to make the API run without WASM
      throw Exception("This platform cannot run WASM code, polka API cannot run here");
    }

    /// reset state before webView launch or reload
    _msgHandlers = {};
    _msgCompleters = {};
    _evalJavascriptUID = 0;
    _onLaunched = onLaunched;
    webViewLoaded = false;
    jsCodeStarted = -1;

    this.socketDisconnectedAction = socketDisconnectedAction;

    _jsCode = await rootBundle.loadString('assets/polkadot/sdk/js_api/dist/main.js');
    print('js file loaded ${_jsCode.length}');

    if (_web == null) {
      print("creating web view");
      // await _startLocalServer();
      //print("NOT starting web server since we already have inapp web server");
      final String homeUrl = "http://localhost:$inappLocalHostPort/assets/polkadot/sdk/assets/index.html";

      _web = HeadlessInAppWebView(
        // initialUrlRequest: URLRequest(url: Uri.parse(homeUrl)),
        initialSettings: InAppWebViewSettings(),
        onWebViewCreated: (controller) {
          print('HeadlessInAppWebView created!');
        },

        onConsoleMessage: (controller, message) async {
          if (kDebugMode) {
            print("CONSOLE MESSAGE: ${message.message}");
          }
          if (jsCodeStarted < 0) {
            if (message.message.contains('js loaded')) {
              jsCodeStarted = 1;
            } else {
              jsCodeStarted = 0;
            }
          }
          if (message.message.contains("API-WS: disconnected from") && this.socketDisconnectedAction != null) {
            // abnormal close
            this.socketDisconnectedAction!();
          }
          if (message.message.contains("WebSocket is not connected") && this.socketDisconnectedAction != null) {
            // normal disconnect - this often happens temporarily
            this.socketDisconnectedAction!();
          }

          if (message.messageLevel != ConsoleMessageLevel.LOG) {
            return;
          }

          try {
            final msg = jsonDecode(message.message);

            final String? path = msg['path'];
            if (_msgCompleters[path!] != null) {
              final Completer handler = _msgCompleters[path]!;

              final error = msg['error'];

              if (error != null) {
                handler.completeError(error);
              } else {
                handler.complete(msg['data']);
              }

              if (path.contains('uid=')) {
                _msgCompleters.remove(path);
              }
            }
            if (_msgHandlers[path] != null) {
              final Function handler = _msgHandlers[path]!;
              handler(msg['data']);
            }
          } catch (error) {
            // any console log that's not JSON format will trigger this
            // since we want normal console logs too, we ignore this
            // print("web view runner error: $error");
          }
        },
        onLoadStart: (controller, url) {
          print("onloadstart $url");
        },
        onLoadStop: (controller, url) async {
          print('webview loaded');
          if (webViewLoaded) {
            return;
          }

          _handleReloaded();
          await _startJSCode();
        },
      );

      await _web!.run();
      _web!.webViewController.loadUrl(urlRequest: URLRequest(url: WebUri(homeUrl)));
    } else {
      throw "Web view initiated already";
    }
  }

  // void _tryReload() {
  //   if (!webViewLoaded) {
  //     _web?.webViewController.reload();
  //   }
  // }

  Future<void> dispose() async {
    socketDisconnectedAction = null;
    _msgHandlers = {};
    _msgCompleters = {};

    await _web?.dispose();
    _web = null;
  }

  void _handleReloaded() {
    _webViewReloadTimer?.cancel();
    webViewLoaded = true;
  }

  Future<void> _startJSCode() async {
    // inject js file to webView
    print("STARTING JS CODE ${_jsCode.length}");
    await _web!.webViewController.evaluateJavascript(source: _jsCode);

    _onLaunched!();
  }

  int getEvalJavascriptUID() {
    return _evalJavascriptUID++;
  }

  Future<dynamic> evalJavascript(
    String code, {
    String? transformer,
    bool wrapPromise = true,
    bool allowRepeat = true,
  }) async {
    if (_web == null) {
      print("not ready - can't run JS code yet");
      return;
    }

    transformer ??= "res";

    // check if there's a same request loading
    if (!allowRepeat) {
      for (String i in _msgCompleters.keys) {
        final String call = code.split('(')[0];
        if (i.contains(call)) {
          print('request $call loading');
          return _msgCompleters[i]!.future;
        }
      }
    }

    if (!wrapPromise) {
      final res = await _web!.webViewController.evaluateJavascript(source: code);
      return res;
    }

    final c = Completer();

    final uid = getEvalJavascriptUID();
    final method = 'uid=$uid;${code.split('(')[0]}';
    _msgCompleters[method] = c;

    final script = '''
        $code.then(function(res) {
          const finalResult = ${transformer.trim()};
          console.log(JSON.stringify({ path: "$method", data: finalResult }));
          finalResult + "";
        }).catch(function(err) {
          console.log(JSON.stringify({ path: "$method", error: err.message }));
          "error";
        });
        "done";
      ''';

    // print("SCRIPT: $script");
    final res = await _web!.webViewController.evaluateJavascript(source: script);

    if (res == null) {
      /// res will be "done" if there is no error and all libraries have been loaded
      /// res will be null if the script has a JS error and won't even run at all
      ///
      /// The latter happens when the libraries are not loaded correctly and for example
      /// "api" is undefined.
      ///
      c.completeError("JavaScript Error.");
    }

    return c.future;
  }

  Future<String?> connectNode(NetworkData chain) async {
    try {
      print("connectNode connecting...");
      final List<String> endpoints = chain.endpointsToUse;
      print('----> settings.connect(${jsonEncode(endpoints)})');
      final res = await evalJavascript('settings.connect(${jsonEncode(endpoints)})');
      if (res != null) {
        final index = endpoints.indexWhere((e) => e.trim() == res.trim());
        final endpoint = endpoints[index > -1 ? index : 0];
        print("endpoint: $endpoint");
        return endpoint;
      } else {
        print("connectNode failed");
      }
      print("connectNode done...");

      return null;
    } catch (error) {
      print("connectNode error: $error");
      rethrow;
    }
  }

  Future<void> subscribeMessage(
    String code,
    String channel,
    Function callback,
  ) async {
    addMsgHandler(channel, callback);
    evalJavascript(code);
  }

  void unsubscribeMessage(String channel) {
    print('unsubscribe $channel');
    final unsubCall = 'unsub$channel';
    _web!.webViewController.evaluateJavascript(source: 'window.$unsubCall && window.$unsubCall()');
  }

  void addMsgHandler(String channel, Function onMessage) {
    _msgHandlers[channel] = onMessage;
  }

  void removeMsgHandler(String channel) {
    _msgHandlers.remove(channel);
  }
}
