import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/saved_provider.dart';
import '../../theme/app_theme.dart';
import 'news_feed_tab.dart';
import 'alerts_tab.dart';
import 'saved_tab.dart';
import 'profile_tab.dart';
import '../tips/submit_tip_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Bind the saved-articles stream to the signed-in user once at startup.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.uid;
      context.read<SavedProvider>().bindUser(uid);
    });
  }

  static const _tabs = [
    NewsFeedTab(),
    AlertsTab(),
    SavedTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SubmitTipScreen()),
              ),
              icon: const Icon(Icons.add_a_photo_outlined),
              label: const Text('Submit Tip'),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.newspaper_outlined), activeIcon: Icon(Icons.newspaper), label: 'News'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), activeIcon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), activeIcon: Icon(Icons.bookmark), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
