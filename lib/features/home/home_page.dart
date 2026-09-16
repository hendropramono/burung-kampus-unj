import 'package:flutter/material.dart';
import '../beranda/presentation/pages/beranda_page.dart';
import '../ceklis/presentation/pages/ceklis_page.dart';
import '../profil/presentation/pages/profil_page.dart';
import '../tentang/presentation/pages/tentang_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const BerandaPage();
      case 1:
        return const CeklisPage();
      case 2:
        return const ProfilPage();
      case 3:
        return const TentangPage();
      default:
        return const BerandaPage();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildAppBarTitle() {
    if (_selectedIndex == 0) {
      return const Text.rich(
        TextSpan(
          text: 'Burung',
          style: TextStyle(fontWeight: FontWeight.bold),
          children: [
            TextSpan(
              text: ' Kampus UNJ',
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      );
    }

    String title = '';
    switch (_selectedIndex) {
      case 1:
        title = 'Ceklis';
        break;
      case 2:
        title = 'Profil';
        break;
      case 3:
        title = 'Tentang';
        break;
      default:
        return const Text.rich(
          TextSpan(
            text: 'Burung',
            style: TextStyle(fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                text: ' Kampus UNJ',
                style: TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        );
    }
    return Text(title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(),
      ),
      body: _buildBody(),
      bottomNavigationBar: NavigationBar(
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist),
            label: 'Ceklis',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
          NavigationDestination(
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: 'Tentang',
          ),
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
      ),
    );
  }
}
