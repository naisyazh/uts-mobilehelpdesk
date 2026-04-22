import 'dart:io';
import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../utils/session.dart';
import '../../widgets/tracking_status_widget.dart';
import 'tracking_screen.dart';

class DetailTicketScreen extends StatefulWidget {
  final Map<String, dynamic> ticket;
  const DetailTicketScreen({super.key, required this.ticket});

  @override
  State<DetailTicketScreen> createState() => _DetailTicketScreenState();
}

class _DetailTicketScreenState extends State<DetailTicketScreen> {
  late String status;
  late Map<String, dynamic> ticket;
  List<Map<String, dynamic>> helpdeskList = [];
  final TextEditingController commentController = TextEditingController();
  final List<Map<String, String>> comments = [
    {'user': 'System', 'text': 'Tiket berhasil dibuat'},
  ];

  String get role => Session.getRole();

  @override
  void initState() {
    super.initState();
    ticket = widget.ticket;
    status = ticket['status'] ?? 'Pending';
    loadHelpdesk();
  }

  void loadHelpdesk() async {
    final list = await DBHelper.getAllHelpdesk();
    setState(() => helpdeskList = list);
  }

  void updateStatus(String newStatus) async {
    await DBHelper.updateTicketStatus(ticket['id'], newStatus, Session.getName());
    setState(() => status = newStatus);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status diubah ke $newStatus'), backgroundColor: Colors.green),
    );
  }

  void assignTicket(String assignedTo) async {
    await DBHelper.assignTicket(ticket['id'], assignedTo, Session.getName());
    setState(() => ticket = {...ticket, 'assigned_to': assignedTo});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tiket di-assign ke $assignedTo'), backgroundColor: Colors.green),
    );
  }

  void showAssignDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Assign Tiket ke'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: helpdeskList.length,
            itemBuilder: (_, i) {
              final h = helpdeskList[i];
              return ListTile(
                leading: const Icon(Icons.person, color: Colors.blue),
                title: Text(h['name']),
                subtitle: Text(h['role'].toString().toUpperCase()),
                onTap: () { Navigator.pop(context); assignTicket(h['name']); },
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal'))],
      ),
    );
  }

  void addComment() {
    if (commentController.text.isEmpty) return;
    setState(() {
      comments.add({'user': Session.getName(), 'text': commentController.text});
      commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdminOrHelpdesk = role == 'admin' || role == 'helpdesk';

    return Scaffold(
      appBar: AppBar(
        title: Text('Tiket #${ticket['id']}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.timeline),
            tooltip: 'Tracking',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => TrackingScreen(ticketId: ticket['id']))),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Info tiket
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ticket['title'] ?? '-',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(ticket['description'] ?? '-',
                              style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 10),
                          Row(children: [
                            const Text('Status: '),
                            TrackingStatusWidget(status: status),
                          ]),
                          const SizedBox(height: 6),
                          Text('Dibuat oleh: ${ticket['created_by'] ?? '-'}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          if (ticket['assigned_to'] != null)
                            Text('Ditangani: ${ticket['assigned_to']}',
                                style: const TextStyle(fontSize: 12, color: Colors.blue)),
                        ],
                      ),
                    ),
                  ),

                  // Foto lampiran
                  if (ticket['image_path'] != null && ticket['image_path'].toString().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('Foto Lampiran:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(File(ticket['image_path']),
                          width: double.infinity, height: 180, fit: BoxFit.cover),
                    ),
                  ],

                  // FITUR ADMIN/HELPDESK SAJA
                  if (isAdminOrHelpdesk) ...[
                    const SizedBox(height: 16),
                    const Text('Update Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['Pending', 'Proses', 'Selesai'].map((s) {
                        return ElevatedButton(
                          onPressed: () => updateStatus(s),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: status == s ? Colors.blue : Colors.grey.shade200,
                            foregroundColor: status == s ? Colors.white : Colors.black,
                          ),
                          child: Text(s),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: showAssignDialog,
                        icon: const Icon(Icons.person_add),
                        label: const Text('Assign ke Helpdesk'),
                      ),
                    ),
                  ],

                  // Komentar
                  const SizedBox(height: 16),
                  const Text('Komentar:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: comments.length,
                    itemBuilder: (_, i) {
                      final c = comments[i];
                      final isMe = c['user'] == Session.getName();
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue.shade100 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c['user']!, style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                              Text(c['text']!),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Input komentar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: 'Tulis komentar...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}