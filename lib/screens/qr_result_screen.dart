import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class QrResultScreen extends StatelessWidget {
  final String result;

  const QrResultScreen({
    super.key,
    required this.result,
  });

  bool get isUrl {
    final uri = Uri.tryParse(result);
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Future<void> openUrl(BuildContext context) async {
    final uri = Uri.tryParse(result);

    if (uri == null) return;

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open this link'),
        ),
      );
    }
  }

  void copyResult(BuildContext context) {
    Clipboard.setData(
      ClipboardData(text: result),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied successfully'),
      ),
    );
  }

  Future<void> shareResult() async {
    await SharePlus.instance.share(
      ShareParams(
        text: result,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Result'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            const Icon(
              Icons.qr_code_2,
              size: 90,
              color: Colors.blue,
            ),

            const SizedBox(height: 25),

            const Text(
              'Scanned Result',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey.shade100,
              ),
              child: SelectableText(
                result,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => copyResult(context),
                icon: const Icon(Icons.copy),
                label: const Text('Copy'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: shareResult,
                icon: const Icon(Icons.share),
                label: const Text('Share'),
              ),
            ),

            if (isUrl) ...[
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () => openUrl(context),
                  icon: const Icon(Icons.open_in_browser),
                  label: const Text('Open Link'),
                ),
              ),
            ],

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}