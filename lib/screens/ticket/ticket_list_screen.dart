import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../utils/session.dart';
import '../../widgets/tracking_status_widget.dart';
import 'detail_ticket_screen.dart';
import 'create_ticket_screen.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  List<Map<String, dynamic>> tickets = [];
  bool get isAdminOrHelpdesk =>
      Session.getRole() == 'admin' || Session.getRole() == 'helpdesk';

  @override
  void initState() { super.initState(); loadData(); }

  void loadData() async {
    // Admin/helpdesk lihat semua, user hanya tiketnya sendiri
    final data = isAdminOrHelpdesk
        ? await DBHelper.getTickets()
        : await DBHelper.getTicketsByUser(Session.getEmail());
    setState(() => tickets = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isAdminOrHelpdesk ? 'Semua Tiket' : 'Tiket Saya'),
        backgroundColor: Colors.blue, foregroundColor: Colors.white,
      ),
      floatingActionButton: !isAdminOrHelpdesk
          ? FloatingActionButton(
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CreateTicketScreen()));
          loadData();
        },
        child: const Icon(Icons.add),
      )
          : null,
      body: tickets.isEmpty
          ? Center(child: Text(isAdminOrHelpdesk
          ? 'Belum ada tiket masuk' : 'Kamu belum membuat tiket'))
          : ListView.builder(
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final t = tickets[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                child: Text('${t['id']}', style: const TextStyle(color: Colors.blue)),
              ),
              title: Text(t['title'],
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t['description'], maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (t['assigned_to'] != null)
                    Text('Ditangani: ${t['assigned_to']}',
                        style: const TextStyle(fontSize: 11, color: Colors.blue)),
                ],
              ),
              trailing: TrackingStatusWidget(status: t['status']),
              onTap: () async {
                await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => DetailTicketScreen(ticket: t)));
                loadData();
              },
            ),
          );
        },
      ),
    );
  }
}