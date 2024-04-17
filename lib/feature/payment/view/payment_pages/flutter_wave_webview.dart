import 'package:e_com/core/core.dart';
import 'package:e_com/feature/check_out/providers/provider.dart';
import 'package:e_com/feature/payment/payment_gateway/payment_gateway.dart';
import 'package:e_com/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FlutterWaveWebviewPage extends HookConsumerWidget {
  const FlutterWaveWebviewPage({super.key, required this.url});
  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentMethod = ref.watch(
        checkoutStateProvider.select((value) => value?.paymentLog.method));

    if (paymentMethod == null) {
      return ErrorView.withScaffold('Failed to load Instamojo Information');
    }

    final flutterWaveCtrl = useCallback(
        () => ref.read(flutterWaveCtrlProvider(paymentMethod).notifier));

    final progress = useState<double?>(null);

    final webCtrl = useState<InAppWebViewController?>(null);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.3,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Flutter Wave',
          style: context.textTheme.titleLarge,
        ),
      ),
      body: Stack(
        children: [
          InAppWebView(
            shouldOverrideUrlLoading: (controller, action) async {
              final url = action.request.url;

              if (url.toString().contains(flutterWaveCtrl().redirectUrl)) {
                await flutterWaveCtrl().confirmPayment(context, url);
                return NavigationActionPolicy.CANCEL;
              }

              return NavigationActionPolicy.ALLOW;
            },
            initialUrlRequest: URLRequest(url: Uri.parse(url)),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                useShouldOverrideUrlLoading: true,
                javaScriptCanOpenWindowsAutomatically: true,
              ),
            ),
            onWebViewCreated: (controller) => webCtrl.value = controller,
            onCloseWindow: (controller) async {
              await controller.clearCache();
              await controller.clearFocus();
            },
            onProgressChanged: (controller, p) => progress.value = p / 100,
          ),
          LinearProgressIndicator(value: progress.value),
        ],
      ),
    );
  }
}
