import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../widgets/tracking_status_widget.dart';

class TrackingScreen extends StatefulWidget {
  final int ticketId;
  const TrackingScreen({super.key, required this.ticketId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  List<Map<String, dynamic>> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  void loadHistory() async {
    final data = await DBHelper.getTicketHistory(widget.ticketId);
    setState(() { history = data; isLoading = false; });
  }

  IconData getIcon(String action) {
    if (action.contains('dibuat')) return Icons.add_circle;
    if (action.contains('Pending')) return Icons.hourglass_empty;
    if (action.contains('Proses')) return Icons.sync;
    if (action.contains('Selesai')) return Icons.check_circle;
    if (action.contains('assign')) return Icons.person_add;
    return Icons.info;
  }

  Color getColor(String action) {
    if (action.contains('dibuat')) return Colors.blue;
    if (action.contains('Pending')) return Colors.orange;
    if (action.contains('Proses')) return Colors.blue;
    if (action.contains('Selesai')) return Colors.green;
    if (action.contains('assign')) return Colors.purple;
    return Colors.grey;
  }

  String formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    } catch (_) { return iso; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracking Tiket #${widget.ticketId}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : history.isEmpty
          ? const Center(child: Text('Belum ada riwayat tracking'))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: history.length,
          itemBuilder: (context, index) {
            final h = history[index];
            final isLast = index == history.length - 1;
            final color = getColor(h['action']);

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Garis timeline
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: color,
                        child: Icon(getIcon(h['action']), color: Colors.white, size: 18),
                      ),
                      if (!isLast)
                        Expanded(child: Container(width: 2, color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // Konten
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h['action'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(h['actor'] ?? '-',
                                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(formatTime(h['timestamp'] ?? ''),
                                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}