import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Webview Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.black, // Siyah renk
        scaffoldBackgroundColor: Color(0xFF6096B4), // #6096B4 mavi renk
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final List<String> _urls = [
    'https://gorkemnet.com/benceanket/',
    'https://gorkemnet.com/benceanket/UserPanel/Anasayfa',
    'https://gorkemnet.com/benceanket/UserPanel/Anketler',
  ];
  late WebViewController _webViewController;
  bool _isLoading = true;
  bool _showLogo = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _startLogoAnimation();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  void _startLogoAnimation() async {
    await Future.delayed(Duration(milliseconds: 1000)); // Logo görünme süresi
    setState(() {
      _showLogo = false;
    });
  }

  void _handleWebResourceError(WebResourceError error) {
    setState(() {
      _errorMessage = 'Web sayfasında bir hata oluştu.';
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyWidget;

    if (_errorMessage.isNotEmpty) {
      bodyWidget = Center(
        child: Text(
          _errorMessage,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
      );
    } else {
      bodyWidget = WebView(
        initialUrl: _urls[_currentIndex],
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) async {
          _webViewController = controller;
        },
        onPageStarted: (url) {
          setState(() {
            _isLoading = true;
            _errorMessage = '';
          });
        },
        onPageFinished: (url) {
          setState(() {
            _isLoading = false;
          });
        },
        navigationDelegate: (NavigationRequest request) {
          if (request.url.startsWith('https://gorkemnet.com/benceanket/')) {
            return NavigationDecision.navigate;
          }
          return NavigationDecision.prevent;
        },
        onWebResourceError: _handleWebResourceError,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            bodyWidget,
            if (_isLoading)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Yükleniyor...'),
                  ],
                ),
              ),
            if (_showLogo)
              Positioned.fill(
                child: Container(
                  color: Colors.white, // Logo arka plan rengi
                  child: Center(
                    child: Image.asset(
                      'assets/ureticimaliyet.png', // Logo yolunu güncelleyin
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _webViewController.loadUrl(_urls[_currentIndex]);
            _showLogo = true;
            _startLogoAnimation();
            _errorMessage = '';
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.web),
            label: 'Anasayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Anasayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.wallet_sharp),
            label: 'Anketler',
          ),
        ],
      ),
    );
  }
}
