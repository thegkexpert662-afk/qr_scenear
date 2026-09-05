import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:typed_data';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class GeneratorScreen extends StatefulWidget {
  const GeneratorScreen({super.key});

  @override
  State<GeneratorScreen> createState() => _GeneratorScreenState();
}

class _GeneratorScreenState extends State<GeneratorScreen> {
  final TextEditingController controller = TextEditingController();

  final GlobalKey qrKey = GlobalKey();
  String qrData = '';
  String selectedType = 'text';

  void generateQR() {
    String data = '';

    if (selectedType == 'upi') {
      final upiId = upiIdController.text.trim();
      final name = upiNameController.text.trim();
      final amount = upiAmountController.text.trim();
      final note = upiNoteController.text.trim();

      if (upiId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter UPI ID'),
          ),
        );
        return;
      }

      final params = <String, String>{
        'pa': upiId,
        if (name.isNotEmpty) 'pn': name,
        if (amount.isNotEmpty) 'am': amount,
        if (note.isNotEmpty) 'tn': note,
        'cu': 'INR',
      };

      data = Uri(
        scheme: 'upi',
        host: 'pay',
        queryParameters: params,
      ).toString();
    }

    else if (selectedType == 'wifi') {
      final wifiName = wifiNameController.text.trim();
      final password = wifiPasswordController.text;

      if (wifiName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter Wi-Fi name'),
          ),
        );
        return;
      }

      data =
      'WIFI:T:$wifiSecurity;S:$wifiName;P:$password;H:${wifiHidden ? 'true' : 'false'};;';
    }

    else {
      final text = controller.text.trim();

      if (text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter some information'),
          ),
        );
        return;
      }

      switch (selectedType) {
        case 'url':
          data = text.startsWith('http://') ||
              text.startsWith('https://')
              ? text
              : 'https://$text';
          break;

        case 'phone':
          data = 'tel:$text';
          break;

        case 'email':
          data = 'mailto:$text';
          break;

        case 'text':
        default:
          data = text;
      }
    }

    setState(() {
      qrData = data;
    });
  }
  Future<Uint8List?> captureQr() async {
    try {
      final boundary =
      qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);

      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  Future<void> saveQr() async {
    final bytes = await captureQr();

    if (bytes == null) return;

    await Gal.putImageBytes(bytes);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR Code saved to gallery'),
      ),
    );
  }
  String getHintText() {
    switch (selectedType) {
      case 'url':
        return 'example.com';

      case 'phone':
        return 'Enter phone number';

      case 'email':
        return 'Enter email address';

      case 'wifi':
        return 'Enter Wi-Fi name';

      case 'upi':
        return 'Enter UPI ID';

      case 'text':
      default:
        return 'Enter your text';
    }
  }

  Future<void> shareQr() async {
    final bytes = await captureQr();

    if (bytes == null) return;

    await SharePlus.instance.share(
      ShareParams(
        files: [
          XFile.fromData(
            bytes,
            mimeType: 'image/png',
            name: 'qr_code.png',
          ),
        ],
      ),
    );
  }
  final TextEditingController upiIdController = TextEditingController();
  final TextEditingController upiNameController = TextEditingController();
  final TextEditingController upiAmountController = TextEditingController();
  final TextEditingController upiNoteController = TextEditingController();
  final TextEditingController wifiNameController =
  TextEditingController();
  final TextEditingController wifiPasswordController =
  TextEditingController();


  String wifiSecurity = 'WPA';
  bool wifiHidden = false;

  @override
  void dispose() {
    controller.dispose();
    upiIdController.dispose();
    upiNameController.dispose();
    upiAmountController.dispose();
    upiNoteController.dispose();
    super.dispose();
    wifiNameController.dispose();
    wifiPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate QR'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              'Create Your QR Code',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'QR Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              value: selectedType,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'text',
                  child: Text('Text'),
                ),
                DropdownMenuItem(
                  value: 'url',
                  child: Text('Website URL'),
                ),
                DropdownMenuItem(
                  value: 'phone',
                  child: Text('Phone Number'),
                ),
                DropdownMenuItem(
                  value: 'email',
                  child: Text('Email'),
                ),
                DropdownMenuItem(
                  value: 'wifi',
                  child: Text('Wi-Fi'),
                ),
                DropdownMenuItem(
                  value: 'upi',
                  child: Text('UPI'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedType = value;
                  controller.clear();
                  qrData = '';
                });
              },
            ),

            const SizedBox(height: 20),

            if (selectedType == 'upi') ...[
              TextField(
                controller: upiIdController,
                decoration: const InputDecoration(
                  labelText: 'UPI ID',
                  hintText: 'example@upi',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: upiNameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: upiAmountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (Optional)',
                  prefixText: '₹ ',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: upiNoteController,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ] else if (selectedType == 'wifi') ...[
              TextField(
                controller: wifiNameController,
                decoration: const InputDecoration(
                  labelText: 'Wi-Fi Name',
                  hintText: 'Enter Wi-Fi name',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: wifiPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter Wi-Fi password',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              DropdownButtonFormField<String>(
                value: wifiSecurity,
                decoration: const InputDecoration(
                  labelText: 'Security',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'WPA',
                    child: Text('WPA/WPA2'),
                  ),
                  DropdownMenuItem(
                    value: 'WEP',
                    child: Text('WEP'),
                  ),
                  DropdownMenuItem(
                    value: 'nopass',
                    child: Text('No Password'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    wifiSecurity = value;
                  });
                },
              ),

              const SizedBox(height: 10),

              SwitchListTile(
                title: const Text('Hidden Network'),
                value: wifiHidden,
                onChanged: (value) {
                  setState(() {
                    wifiHidden = value;
                  });
                },
              ),
            ] else ...[
              TextField(
                controller: controller,
                minLines: 5,
                maxLines: 8,
                maxLength: 2000,
                decoration: InputDecoration(
                  hintText: getHintText(),
                  labelText: 'QR Content',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: generateQR,
                icon: const Icon(Icons.qr_code_2),
                label: const Text(
                  'Generate QR Code',
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),

            const SizedBox(height: 35),

            if (qrData.isNotEmpty)
              RepaintBoundary(
                key: qrKey,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child:QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 250,
                    backgroundColor: Colors.white,
                    embeddedImageStyle: selectedType == 'upi'
                        ? null
                        : const QrEmbeddedImageStyle(
                      size: Size(50, 50),
                    ),
                  ),
                ),
              ),

            if (qrData.isNotEmpty) ...[
              const SizedBox(height: 20),

              Text(
                qrData,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: saveQr,
                      icon: const Icon(Icons.download),
                      label: const Text('Save'),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: shareQr,
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}