import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../ticket/detail_ticket_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> tickets = [];

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  void loadNotifications() async {
    final data = await DBHelper.getTickets();
    setState(() => tickets = data);
  }

  String getNotifMessage(String status) {
    switch (status) {
      case 'Pending': return 'Tiket menunggu untuk diproses';
      case 'Proses': return 'Tiket sedang dalam penanganan';
      case 'Selesai': return 'Tiket telah berhasil diselesaikan';
      default: return 'Status tiket diperbarui';
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'Proses': return Colors.blue;
      case 'Selesai': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi'),
          backgroundColor: Colors.blue, foregroundColor: Colors.white),
      body: tickets.isEmpty
          ? const Center(child: Text('Belum ada notifikasi'))
          : ListView.separated(
        itemCount: tickets.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final t = tickets[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: getStatusColor(t['status']).withOpacity(0.2),
              child: Icon(Icons.notifications, color: getStatusColor(t['status'])),
            ),
            title: Text('Tiket #${t['id']}: ${t['title']}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(getNotifMessage(t['status'])),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: getStatusColor(t['status']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(t['status'],
                  style: TextStyle(color: getStatusColor(t['status']),
                      fontSize: 11, fontWeight: FontWeight.bold)),
            ),
            // ✅ FR-007: Navigasi ke halaman detail saat diklik
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailTicketScreen(ticket: t)),
            ),
          );
        },
      ),
    );
  }
}