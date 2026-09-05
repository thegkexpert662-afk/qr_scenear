import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanHistoryScreen extends StatefulWidget {
  const ScanHistoryScreen({super.key});

  @override
  State<ScanHistoryScreen> createState() => _ScanHistoryScreenState();
}

class _ScanHistoryScreenState extends State<ScanHistoryScreen> {
  List<Map<String, dynamic>> history = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final savedHistory = prefs.getStringList('scan_history') ?? [];

    setState(() {
      history = savedHistory
          .map(
            (item) => Map<String, dynamic>.from(
          jsonDecode(item),
        ),
      )
          .toList();
    });
  }

  Future<void> deleteHistory(int index) async {
    final prefs = await SharedPreferences.getInstance();

    history.removeAt(index);

    final data = history
        .map((item) => jsonEncode(item))
        .toList();

    await prefs.setStringList('scan_history', data);

    setState(() {});
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('scan_history');

    setState(() {
      history.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        centerTitle: true,
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear History',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Clear History?'),
                      content: const Text(
                        'All scan history will be deleted.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          child: const Text('Clear'),
                        ),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  await clearHistory();
                }
              },
            ),
        ],
      ),
      body: history.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 15),
            Text(
              'No scan history yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      )
          : ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
        separatorBuilder: (_, index) =>
        const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = history[index];

        return Card(
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.qr_code_2),
            ),
            title: Text(
              item['value'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              item['date'] ?? '',
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.delete_outline,
              ),
              onPressed: () {
                deleteHistory(index);
              },
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('QR Result'),
                    content: SelectableText(
                      item['value'] ?? '',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    ),
    );
  }
}