import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../utils/session.dart';
import '../../widgets/tracking_status_widget.dart';
import 'detail_ticket_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> tickets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  void loadHistory() async {
    // Semua role lihat riwayat sesuai akses
    final isAdminOrHelpdesk =
        Session.getRole() == 'admin' || Session.getRole() == 'helpdesk';
    final data = isAdminOrHelpdesk
        ? await DBHelper.getTickets()
        : await DBHelper.getTicketsByUser(Session.getEmail());

    if (mounted) setState(() { tickets = data; isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Tiket'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white, // FIX: tambah foregroundColor
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : tickets.isEmpty
          ? const Center(child: Text('Belum ada riwayat tiket'))
          : ListView.builder(
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final t = tickets[index];
          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.history, color: Colors.blue),
              title: Text(t['title'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t['description'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  Text(
                    'Dibuat: ${t['created_by'] ?? '-'}',
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              trailing:
              TrackingStatusWidget(status: t['status']),
              // FIX: bisa tap ke detail
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      DetailTicketScreen(ticket: t),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}