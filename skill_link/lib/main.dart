import 'package:flutter/material.dart';

import 'screens/explore_screen.dart';
import 'screens/home_screen.dart';
import 'screens/my_bookings_screen.dart';
import 'screens/profile_screen.dart';
import 'services/booking_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SkillLinkApp());
}

class SkillLinkApp extends StatelessWidget {
  const SkillLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillLink',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const List<Widget> _screens = [
    HomeScreen(),
    ExploreScreen(),
    MyBookingsScreen(),
    ProfileScreen(),
  ];

  static const List<_Destination> _destinations = [
    _Destination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    _Destination(
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore,
      label: 'Explore',
    ),
    _Destination(
      icon: Icons.event_note_outlined,
      selectedIcon: Icons.event_note,
      label: 'Bookings',
    ),
    _Destination(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    BookingService.instance.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: _destinations
            .map(
              (destination) => NavigationDestination(
                icon: Icon(destination.icon),
                selectedIcon: Icon(destination.selectedIcon),
                label: destination.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _Destination {
  const _Destination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
