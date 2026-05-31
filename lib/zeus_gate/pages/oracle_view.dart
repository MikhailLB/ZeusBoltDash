import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../infra/zeus_agent.dart';
import '../infra/flash_vault.dart';
import '../infra/volt_relay.dart';
import '../infra/olympus_probe.dart';
import 'exile_screen.dart';

class OracleView extends StatefulWidget {
  final String destination;
  final FlashVault vault;
  final VoltRelay relay;
  final OlympusProbe probe;
  final VoidCallback? onFirstPaint;
  final bool layoutSettle;

  const OracleView({
    super.key,
    required this.destination,
    required this.vault,
    required this.relay,
    required this.probe,
    this.onFirstPaint,
    this.layoutSettle = false,
  });

  @override
  State<OracleView> createState() => _OracleViewState();
}

class _OracleViewState extends State<OracleView> with WidgetsBindingObserver {
  late final WebViewController _wv;
  StreamSubscription<List<ConnectivityResult>>? _connSub;
  bool _offlineRouted = false;
  String? _lastMainFrameUrl;
  int _redirectRetries = 0;
  bool _firstPaintFired = false;
  bool _showWebView = false;
  Widget? _fullscreenOverlay;
  void Function()? _hideOverlay;

  void _applyImmersive() =>
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) { _applyImmersive(); _drainStash(); }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp, DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight,
    ]);
    _applyImmersive();

    late final PlatformWebViewControllerCreationParams params;
    if (Platform.isIOS) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else if (Platform.isAndroid) {
      params = AndroidWebViewControllerCreationParams();
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _wv = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(zeusAgent.userAgent)
      ..setBackgroundColor(Colors.black)
      ..enableZoom(false)
      ..setNavigationDelegate(_buildDelegate());

    _configurePlatform();

    if (widget.layoutSettle && Platform.isIOS) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _deferredMount());
    } else {
      _showWebView = true;
      _wv.loadRequest(Uri.parse(widget.destination));
    }

    widget.relay.onPushUrl = (url) {
      if (!mounted) return;
      try {
        final uri = Uri.parse(url);
        if (uri.hasScheme) _wv.loadRequest(uri);
      } catch (_) {}
    };

    _connSub = widget.probe.onChange.listen((statuses) {
      if (statuses.every((s) => s == ConnectivityResult.none)) _maybeRouteOffline();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _drainStash());
  }

  Future<void> _deferredMount() async {
    _applyImmersive();
    await WidgetsBinding.instance.endOfFrame;
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _showWebView = true);
    _wv.loadRequest(Uri.parse(widget.destination));
  }

  void _scheduleViewportNudges() {
    for (final ms in const [350, 750, 1150, 1750]) {
      Future.delayed(Duration(milliseconds: ms), () {
        if (!mounted) return;
        _wv.runJavaScript(
          "try{window.dispatchEvent(new Event('resize'));"
          "if(window.visualViewport)window.visualViewport.dispatchEvent(new Event('resize'));"
          "if(typeof window.zqVeReflow==='function')window.zqVeReflow();}catch(e){}");
      });
    }
  }

  Future<void> _drainStash() async {
    final url = await widget.vault.consumeOneShotUrl();
    if (url != null && url.isNotEmpty && mounted) {
      try {
        final uri = Uri.parse(url);
        if (uri.hasScheme) _wv.loadRequest(uri);
      } catch (_) {}
    }
  }

  NavigationDelegate _buildDelegate() {
    return NavigationDelegate(
      onPageStarted: (_) {},
      onPageFinished: (_) {
        _redirectRetries = 0;
        _tuneViewport();
        _clampFontScale();
        _followCaret();
        _armMediaPlayback();
        _scheduleViewportNudges();
        if (!_firstPaintFired) {
          _firstPaintFired = true;
          Future.delayed(const Duration(milliseconds: 600), () {
            try { widget.onFirstPaint?.call(); } catch (_) {}
          });
        }
      },
      onWebResourceError: (err) {
        if (err.errorCode == -999) return;
        if (err.isForMainFrame != true) return;
        final desc = err.description.toLowerCase();
        final loop = desc.contains('too_many_redirects') ||
            desc.contains('too many redirects') ||
            err.errorCode == -1007 || err.errorCode == -9;
        if (loop && _lastMainFrameUrl != null && _redirectRetries < 3) {
          _redirectRetries++;
          _wv.loadRequest(Uri.parse(_lastMainFrameUrl!));
          return;
        }
        _maybeRouteOffline();
      },
      onHttpError: (_) {},
      onNavigationRequest: (req) {
        final uri = Uri.tryParse(req.url);
        if (uri == null) return NavigationDecision.prevent;
        final s = uri.scheme;
        if (s == 'http' || s == 'https' || s == 'about' || s == 'data' || s == 'blob') {
          if (req.isMainFrame) _lastMainFrameUrl = req.url;
          return NavigationDecision.navigate;
        }
        _launchExternal(uri);
        return NavigationDecision.prevent;
      },
    );
  }

  void _configurePlatform() {
    if (Platform.isIOS && _wv.platform is WebKitWebViewController) {
      (_wv.platform as WebKitWebViewController)
          .setAllowsBackForwardNavigationGestures(true);
    }
    if (Platform.isAndroid && _wv.platform is AndroidWebViewController) {
      final android = _wv.platform as AndroidWebViewController;
      android.setMediaPlaybackRequiresUserGesture(false);
      android.setOnShowFileSelector(_pickFiles);
      android.setCustomWidgetCallbacks(
        onShowCustomWidget: (w, hide) {
          _hideOverlay = hide;
          if (mounted) setState(() => _fullscreenOverlay = w);
        },
        onHideCustomWidget: () {
          _hideOverlay = null;
          if (mounted) setState(() => _fullscreenOverlay = null);
        },
      );
      final cookies = AndroidWebViewCookieManager(
        AndroidWebViewCookieManagerCreationParams
            .fromPlatformWebViewCookieManagerCreationParams(
          const PlatformWebViewCookieManagerCreationParams(),
        ),
      );
      cookies.setAcceptThirdPartyCookies(android, true);
    }
  }

  Future<List<String>> _pickFiles(FileSelectorParams p) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: p.mode == FileSelectorMode.openMultiple,
        type: FileType.any,
      );
      if (result == null) return const [];
      return result.files.where((f) => f.path != null)
          .map((f) => Uri.file(f.path!).toString()).toList();
    } catch (_) { return const []; }
  }

  Future<void> _maybeRouteOffline() async {
    if (_offlineRouted) return;
    final ok = await widget.probe.isOnline();
    if (ok || !mounted) return;
    _offlineRouted = true;
    final current = await _wv.currentUrl() ?? widget.destination;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => ExileScreen(
        probe: widget.probe,
        retryBuilder: (_) => OracleView(
          destination: current, vault: widget.vault,
          relay: widget.relay, probe: widget.probe,
        ),
      ),
    ));
  }

  void _launchExternal(Uri uri) async {
    try { await launchUrl(uri, mode: LaunchMode.externalApplication); } catch (_) {}
  }

  void _tuneViewport() {
    _wv.runJavaScript(r'''
(function(){
  var W=window; if(W.zqVe)return; W.zqVe=1;
  var TAG='zq-ve-style';
  var rules=[
    ':root{--safe-area-inset-top:0px!important;--safe-area-inset-right:0px!important;',
    '--safe-area-inset-bottom:0px!important;--safe-area-inset-left:0px!important;',
    '--sat:0px!important;--sar:0px!important;--sab:0px!important;--sal:0px!important;}',
    'html,body{padding-top:0!important;margin-top:0!important;}'
  ].join('');
  function caretUp(){
    var vv=W.visualViewport;
    return vv ? vv.height < W.innerHeight*0.75 : false;
  }
  function reflow(){
    if(caretUp())return;
    var head=document.head||document.documentElement; if(!head)return;
    var meta=document.querySelector('meta[name=viewport]');
    if(meta){
      var content=meta.getAttribute('content')||'';
      if(!/viewport-fit\s*=\s*contain/i.test(content)){
        var base=content.replace(/,?\s*viewport-fit\s*=\s*\w+/ig,'').trim();
        meta.setAttribute('content', base + (base?', ':'') + 'viewport-fit=contain');
      }
    }
    var node=document.getElementById(TAG);
    if(!node){node=document.createElement('style');node.id=TAG;head.appendChild(node);}
    if(node.textContent!==rules)node.textContent=rules;
    if(head.lastElementChild!==node)head.appendChild(node);
  }
  W.zqVeReflow=reflow;
  reflow();
  var nav=W.history;
  ['pushState','replaceState'].forEach(function(m){
    var src=nav[m];
    nav[m]=function(){var out=src.apply(this,arguments);setTimeout(reflow,150);setTimeout(reflow,600);return out;};
  });
  W.addEventListener('popstate',function(){setTimeout(reflow,150);});
  setInterval(reflow,2500);
})();
''');
  }

  void _followCaret() {
    _wv.runJavaScript(r'''
(function(){
  var W=window; if(W.zqCp)return; W.zqCp=1;
  function editable(n){ if(!n)return false; var t=n.tagName; return t==='INPUT'||t==='TEXTAREA'||n.isContentEditable===true; }
  function bring(){
    var el=document.activeElement; if(!editable(el))return;
    var vv=W.visualViewport;
    if(vv){
      var box=el.getBoundingClientRect();
      var below=box.bottom>vv.offsetTop+vv.height-20;
      var above=box.top<vv.offsetTop;
      if(below||above)el.scrollIntoView({behavior:'auto',block:'nearest'});
    } else {
      el.scrollIntoView({behavior:'auto',block:'nearest'});
    }
  }
  document.addEventListener('focusin',function(ev){ if(editable(ev.target))setTimeout(bring,350); });
  var vv=W.visualViewport;
  if(vv){
    var last=vv.height;
    vv.addEventListener('resize',function(){ var h=vv.height; if(h<last)setTimeout(bring,120); last=h; });
  }
})();
''');
  }

  void _clampFontScale() {
    if (!Platform.isIOS) return;
    _wv.runJavaScript(r'''
(function(){
  var W=window; if(W.zqFs)return; W.zqFs=1;
  var st=document.createElement('style'); st.id='zq-fs';
  st.appendChild(document.createTextNode('input,textarea,select,[contenteditable=true]{font-size:16px!important;}'));
  (document.head||document.documentElement).appendChild(st);
})();
''');
  }

  void _armMediaPlayback() {
    _wv.runJavaScript(r'''
(function(){
  var W=window; if(W.zqMp)return; W.zqMp=1;
  function arm(v){
    try{
      v.setAttribute('playsinline','');
      v.setAttribute('webkit-playsinline','');
      v.playsInline=true; v.muted=true; v.defaultMuted=true; v.autoplay=true;
      var pr=v.play&&v.play();
      if(pr&&pr.catch)pr.catch(function(){});
    }catch(e){}
  }
  function scan(scope){
    try{
      var vids=(scope||document).getElementsByTagName('video');
      for(var k=0;k<vids.length;k++)arm(vids[k]);
    }catch(e){}
  }
  scan(document);
  document.addEventListener('touchend',function(){scan(document);},{passive:true});
  var mo=new MutationObserver(function(list){
    for(var k=0;k<list.length;k++){
      var added=list[k].addedNodes||[];
      for(var j=0;j<added.length;j++){
        var node=added[j]; if(!node||node.nodeType!==1)continue;
        if(node.tagName==='VIDEO')arm(node); scan(node);
      }
    }
  });
  mo.observe(document.documentElement,{childList:true,subtree:true});
  setInterval(function(){scan(document);},1500);
})();
''');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connSub?.cancel();
    widget.relay.onPushUrl = null;
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual, overlays: SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp, DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safe = MediaQuery.of(context).viewPadding;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && _fullscreenOverlay != null) _hideOverlay?.call();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: safe.top, bottom: safe.bottom,
                left: safe.left, right: safe.right,
              ),
              child: _showWebView
                  ? WebViewWidget(controller: _wv)
                  : const ColoredBox(color: Colors.black),
            ),
            if (_fullscreenOverlay != null)
              Positioned.fill(child: _fullscreenOverlay!),
          ],
        ),
      ),
    );
  }
}
