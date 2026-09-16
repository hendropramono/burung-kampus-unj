import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class TentangPage extends StatelessWidget {
  const TentangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100), // Memberi ruang untuk footer
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/icon/app_icon.png',
                  width: 180,
                  height: 180,
                ),
                const SizedBox(height: 4),
                Text(
                  'Burung Kampus UNJ',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        'Versi ${snapshot.data!.version}',
                        style: const TextStyle(color: Colors.grey),
                      );
                    }
                    return const Text(
                      'Memuat versi...',
                      style: TextStyle(color: Colors.grey),
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    'Aplikasi panduan lapangan pengamatan burung di lingkungan kampus Universitas Negeri Jakarta.',
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                Image.asset(
                  'assets/images/logo_kpb.png',
                  height: 72,
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Supported by',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Image.asset(
                  'assets/images/logo_scentia.png',
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
