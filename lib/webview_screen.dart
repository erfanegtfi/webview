// ignore_for_file: must_be_immutable

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'constants.dart';

import 'alert_dialog.dart';
import 'utils.dart';

class WebviewScreen extends StatefulWidget {
  const WebviewScreen();

  @override
  _WebviewScreenState createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  late ThemeData theme;
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  final GlobalKey webViewKey = GlobalKey();
  String url = baseUrl;
  InAppWebViewController? webViewController;
  InAppWebViewSettings? settings;
  PullToRefreshController? pullToRefreshController;
  bool _isError = false;
  _WebviewScreenState();

  @override
  void initState() {
    super.initState();
    // checkPhotoPermissions();
    settings = InAppWebViewSettings(
        isInspectable: kDebugMode,
        mediaPlaybackRequiresUserGesture: false,
        allowsInlineMediaPlayback: true,
        iframeAllow: "camera; microphone",
        javaScriptEnabled: true,
        javaScriptCanOpenWindowsAutomatically: true,
        iframeAllowFullscreen: true);

    pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(color: Colors.blue),
      onRefresh: () async {
        if (_isError) {
          webViewController?.loadUrl(
            urlRequest: URLRequest(url: WebUri(url)),
          );
          await webViewController?.clearHistory();
        } else {
          if (defaultTargetPlatform == TargetPlatform.android) {
            webViewController?.reload();
          } else if (defaultTargetPlatform == TargetPlatform.iOS) {
            webViewController?.loadUrl(urlRequest: URLRequest(url: await webViewController?.getUrl()));
          }
        }
      },
    );
    addFileSelectionListener();
  }

  void addFileSelectionListener() async {
    if (Platform.isAndroid) {
      final androidController = webViewController?.platform as AndroidWebViewController;
      await androidController.setOnShowFileSelector(_androidFilePicker);
    }
  }

  Future<List<String>> _androidFilePicker(FileSelectorParams params) async {
    if (params.acceptTypes.any((type) => type == 'image/*')) {
      final picker = ImagePicker();
      final photo = await picker.pickImage(source: ImageSource.camera);

      if (photo == null) {
        return [];
      }
      return [Uri.file(photo.path).toString()];
    } else if (params.acceptTypes.any((type) => type == 'video/*')) {
      final picker = ImagePicker();
      final vidFile = await picker.pickVideo(source: ImageSource.camera, maxDuration: const Duration(seconds: 10));
      if (vidFile == null) {
        return [];
      }
      return [Uri.file(vidFile.path).toString()];
    } else {
      try {
        if (params.mode == FileSelectorMode.openMultiple) {
          final attachments = await FilePicker.platform.pickFiles(allowMultiple: true);
          if (attachments == null) return [];

          return attachments.files.where((element) => element.path != null).map((e) => File(e.path!).uri.toString()).toList();
        } else {
          final attachment = await FilePicker.platform.pickFiles();
          if (attachment == null) return [];
          File file = File(attachment.files.single.path!);
          return [file.uri.toString()];
        }
      } catch (e) {
        return [];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => _onWillPop(context),
      child: Scaffold(backgroundColor: theme.scaffoldBackgroundColor, body: SafeArea(child: getScreenBody())),
    );
  }

  Widget getScreenBody() {
    return Stack(
      children: [
        InAppWebView(
          key: webViewKey,
          initialUrlRequest: URLRequest(url: WebUri(url)),
          initialSettings: settings,
          pullToRefreshController: pullToRefreshController,
          onWebViewCreated: (InAppWebViewController controller) {
            webViewController = controller;

            webViewController?.addJavaScriptHandler(
              handlerName: "testFuncArgs",
              callback: (args) async {
                webViewController?.loadUrl(
                  urlRequest: URLRequest(url: WebUri(baseUrl)),
                );
                await webViewController?.clearHistory();
              },
            );
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            return NavigationActionPolicy.ALLOW; // Continue navigation
          },
          onLoadStop: (controller, url) {
            pullToRefreshController?.endRefreshing();
          },
          onReceivedError: (controller, request, error) async {
            if (couldNotOpenUrl(error)) {
              await pullToRefreshController?.endRefreshing();

              // webViewController?.loadUrl( urlRequest: URLRequest(url: WebUri('about:blank'))); // A way to reset history
              String base64Image = await getBase64Resource('assets/images/error.png');
              if (networkError(error)) base64Image = await getBase64Resource('assets/images/no_internet.png');

              String base64Font = await getBase64Resource('assets/fonts/Vazir_Medium.ttf');
              webViewController?.loadData(
                data:
                    customErrorPage.replaceAll("BASE64_ENCODED_IMAGE_HERE", base64Image).replaceAll("BASE64_ENCODED_FONT_HERE", base64Font),
                mimeType: "text/html",
                encoding: "utf-8",
              );
              await webViewController?.clearHistory();
              _isError = true;
            }
          },
          onLoadStart: (controller, url) {
            // print("=======================");
            // print(url?.rawValue);
            // print("=======================");
          },
          onUpdateVisitedHistory: (controller, url, isReload) {
            if (url?.rawValue.contains("google") == true) this.url = url?.rawValue ?? baseUrl;
          },
          onProgressChanged: (controller, progress) async {
            if (progress == 100) {
              WebUri? s = await controller.getUrl();
              pullToRefreshController?.endRefreshing();
              // if (!_isError) {
              webViewController?.evaluateJavascript(
                  source: "document.documentElement.style.height = document.documentElement.clientHeight + 1 + 'px';");
              // }
              if (s?.host.isNotEmpty == true) {
                _isError = false;
              }

              isLoading.value = false;
            }
          },
          onPermissionRequest: (controller, request) async {
            return PermissionResponse(resources: request.resources, action: PermissionResponseAction.GRANT);
          },
        ),
        ValueListenableBuilder<bool>(
          valueListenable: isLoading,
          builder: (BuildContext context, bool value, child) {
            return value ? const Center(child: CircularProgressIndicator()) : const SizedBox();
          },
        ),
      ],
    );
  }

  bool couldNotOpenUrl(WebResourceError error) =>
      error.type.toValue() == "HOST_LOOKUP" ||
      error.type.toValue() == "CONNECT" ||
      error.type.toValue() == "IO" ||
      // error.type.toValue() == "TIMEOUT" ||
      error.type.toValue() == "FAILED_SSL_HANDSHAKE";

  bool networkError(WebResourceError error) => error.type.toValue() == "HOST_LOOKUP"; //|| error.type.toValue() == "TIMEOUT"

  Future<List<String>> getUrlHostList() async {
    WebHistory? history = await webViewController?.getCopyBackForwardList();
    List<String> urls = history?.list?.map((item) => item.url?.host ?? "").toList() ?? [];
    return urls;
  }

  Future<void> removeEmptyUrls(InAppWebViewController? controller) async {
    WebHistory? webh = await controller?.getCopyBackForwardList();
    List<WebHistoryItem> urls = webh?.list ?? [];
   
    if (urls.isNotEmpty) {
      for (int i = urls.length - 1; i >= 0; i--) {
        // if ((urls[i].url?.host.isEmpty == true || (i != 0 && urls[i - 1].url?.host.isEmpty == true)) ||
        //     (urls[i].title == "Webpage not available" || (i != 0 && urls[i - 1].title == "Webpage not available"))) {
        if (i != 0 && (urls[i - 1].url?.host.isEmpty == true || urls[i - 1].title == "Webpage not available")) {
          if (await webViewController?.canGoBack() == true) await controller?.goBack();
        } else
          break;
      }
    }
  }

  
  Future<bool> _onWillPop(BuildContext context) async {
    await removeEmptyUrls(webViewController);

    if (await webViewController?.canGoBack() == true) {
      webViewController?.goBack();

      return Future.value(false);
    } else {
      _showExitDialog();
      return Future.value(true);
    }
  }

  _showExitDialog() {
    showDialog(
        context: context,
        builder: (context) => MyAlertDialog(
            content: 'میخواهید خارج شوید؟',
            yesOnPressed: () {
              SystemNavigator.pop();
            },
            noOnPressed: () {
              Navigator.of(context).pop();
            },
            yes: 'بله',
            no: 'خیر'));
  }

  checkPhotoPermissions() async {
    if (Platform.isAndroid) {
      await _androidPermissions();
    } else if (Platform.isIOS) {
      await _iosPermissions();
    }
  }

  Future<void> _iosPermissions() async {
    Map<Permission, PermissionStatus> status = await [
      Permission.camera,
      Permission.storage,
    ].request();

    if (status[Permission.camera]?.isDenied == true) {
      await Permission.camera.shouldShowRequestRationale;
    }

    // if (status[Permission.storage]?.isDenied == true) {
    //   await Permission.microphone.shouldShowRequestRationale;
    // }
  }

  Future<void> _androidPermissions() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;

    Map<Permission, PermissionStatus> status = await [
      Permission.camera,
      Permission.microphone,
      if (androidInfo.version.sdkInt <= 32) Permission.storage,
      if (androidInfo.version.sdkInt > 32) Permission.photos,
    ].request();

    if (status[Permission.camera]?.isDenied == true) {
      await Permission.camera.shouldShowRequestRationale;
    }

    if (status[Permission.microphone]?.isDenied == true) {
      await Permission.microphone.shouldShowRequestRationale;
    }

    // if (androidInfo.version.sdkInt <= 32 && status[Permission.storage]?.isDenied == true) {
    //   await Permission.storage.shouldShowRequestRationale;
    // } else if (androidInfo.version.sdkInt > 32 && status[Permission.photos]?.isDenied == true) {
    //   await Permission.photos.shouldShowRequestRationale;
    // }
  }

  @override
  dispose() {
    super.dispose();
  }
}
