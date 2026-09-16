import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../auth/presentation/pages/login_page.dart';

class CeklisPage extends StatefulWidget {
  const CeklisPage({super.key});

  @override
  State<CeklisPage> createState() => _CeklisPageState();
}

class _CeklisPageState extends State<CeklisPage> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;

        if (user == null) {
          return _buildLoginPrompt(context);
        }

        return _buildCeklisContent(context, user);
      },
    );
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checklist_rtl_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Akses Terbatas',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Silakan masuk untuk mulai mencatat dan melihat daftar burung yang sudah Anda temukan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text('Masuk ke Akun'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCeklisContent(BuildContext context, User user) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.checklist_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'Fitur Ceklis Segera Hadir',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Nantikan pembaruan fitur pengamatan personal di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
