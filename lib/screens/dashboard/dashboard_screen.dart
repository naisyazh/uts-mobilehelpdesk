import 'package:flutter/material.dart';
import '../../database/db_helper.dart';
import '../../utils/session.dart';
import '../../main.dart';
import '../ticket/ticket_list_screen.dart';
import '../ticket/create_ticket_screen.dart';
import '../ticket/history_screen.dart';
import '../profile/profile_screen.dart';
import '../notification/notification_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomeTab(),
    const TicketListScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.confirmation_num), label: 'Tiket'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notif'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  Map<String, int> stats = {'total': 0, 'pending': 0, 'proses': 0, 'selesai': 0};

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  void loadStats() async {
    final data = await DBHelper.getTicketStats();
    setState(() => stats = data);
  }

  String get role => Session.getRole();
  bool get isAdminOrHelpdesk => role == 'admin' || role == 'helpdesk';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(radius: 24,
                      child: Icon(Icons.person, size: 28)),
                  const SizedBox(height: 8),
                  Text(Session.getName(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(Session.getEmail(),
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                    child: Text(role.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ],
              ),
            ),
            ListTile(leading: const Icon(Icons.home), title: const Text('Dashboard'),
                onTap: () => Navigator.pop(context)),
            if (!isAdminOrHelpdesk)
              ListTile(leading: const Icon(Icons.add), title: const Text('Buat Tiket'),
                  onTap: () { Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTicketScreen()))
                      .then((_) => loadStats()); }),
            ListTile(leading: const Icon(Icons.list), title: const Text('List Tiket'),
                onTap: () { Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TicketListScreen())); }),
            ListTile(leading: const Icon(Icons.history), title: const Text('Riwayat'),
                onTap: () { Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())); }),
            const Divider(),
            ListTile(
              leading: Icon(isDark ? Icons.wb_sunny : Icons.dark_mode),
              title: Text(isDark ? 'Mode Terang' : 'Mode Gelap'),
              onTap: () { Navigator.pop(context); MyApp.of(context)?.toggleTheme(); },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1E3A5F), const Color(0xFF121212)]
                : [const Color(0xFF3B82F6), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Builder(builder: (ctx) => IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                    )),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Halo, ${Session.getName()}!',
                              style: const TextStyle(color: Colors.white, fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text(isAdminOrHelpdesk ? '${role.toUpperCase()} Dashboard' : 'User Dashboard',
                              style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: loadStats,
                    ),
                  ],
                ),
              ),

              // Statistik REAL dari DB
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Total tiket
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white54),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.confirmation_num, color: Colors.white),
                          const SizedBox(width: 8),
                          Text('Total Tiket: ${stats['total']}',
                              style: const TextStyle(color: Colors.white,
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _statCard('Pending', stats['pending'].toString(), Colors.orange),
                        _statCard('Proses', stats['proses'].toString(), Colors.blue),
                        _statCard('Selesai', stats['selesai'].toString(), Colors.green),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Grid Menu — berbeda berdasarkan role
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      if (!isAdminOrHelpdesk)
                        GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const CreateTicketScreen()))
                              .then((_) => loadStats()),
                          child: _menuCard(Icons.add_circle, 'Buat Tiket', Colors.blue),
                        ),
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const TicketListScreen())),
                        child: _menuCard(Icons.list_alt,
                            isAdminOrHelpdesk ? 'Semua Tiket' : 'Tiket Saya', Colors.indigo),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const HistoryScreen())),
                        child: _menuCard(Icons.history, 'Riwayat', Colors.teal),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const NotificationScreen())),
                        child: _menuCard(Icons.notifications, 'Notifikasi', Colors.orange),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.25),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white54),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 22,
                fontWeight: FontWeight.bold, color: Colors.white)),
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(IconData icon, String title, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white38),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(backgroundColor: color, radius: 24,
              child: Icon(icon, color: Colors.white)),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}