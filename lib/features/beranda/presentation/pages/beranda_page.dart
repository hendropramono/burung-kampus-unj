import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../models/spesies_model.dart';
import '../../../home/bird_detail_page.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  Color _getIUCNColor(String status) {
    switch (status.toUpperCase()) {
      case 'EX':
        return Colors.black;
      case 'EW':
        return Colors.purple[900]!;
      case 'CR':
        return Colors.red[900]!;
      case 'EN':
        return Colors.red[700]!;
      case 'VU':
        return Colors.orange[800]!;
      case 'NT':
        return Colors.lightGreen[700]!;
      case 'LC':
        return Colors.green[700]!;
      case 'DD':
        return Colors.grey[700]!;
      case 'NE':
        return Colors.grey[600]!;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('spesies')
          .where('kelas', isEqualTo: 'Aves')
          .where('lokasi', arrayContains: '6852481f-dd93-4091-8239-e178c0211780')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Terjadi kesalahan: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(
            child: Text('Tidak ada data burung ditemukan di Kampus UNJ.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final spesies = Spesies.fromJson({
              ...docs[index].data() as Map<String, dynamic>,
              'id': docs[index].id,
            });

            final String? gambarUrl =
                spesies.fotos.isNotEmpty ? spesies.fotos.first.url : null;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BirdDetailPage(
                          spesies: spesies,
                        ),
                      ),
                    );
                  },
                child: SizedBox(
                  height: 96, // Fixed height for all items
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image Section (1:1 Ratio)
                      SizedBox(
                        width: 96, // Same as height for 1:1 ratio
                        child: Hero(
                          tag: 'bird-image-${spesies.id}',
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              gambarUrl != null && gambarUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: gambarUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[100],
                                        child: const Center(
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Image.asset(
                                        'assets/images/bird.png',
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      'assets/images/bird.png',
                                      fit: BoxFit.cover,
                                    ),
                            ],
                          ),
                        ),
                      ),
                        // Content Section
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  spesies.namaLokal,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  spesies.namaIlmiah,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontStyle: FontStyle.italic,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // IUCN Badge Section (Replacing Arrow)
                        if (spesies.iucnStatus != null)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getIUCNColor(spesies.iucnStatus!)
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: _getIUCNColor(spesies.iucnStatus!)
                                          .withOpacity(0.2)),
                                ),
                                child: Text(
                                  spesies.iucnStatus!.toUpperCase(),
                                  style: TextStyle(
                                    color: _getIUCNColor(spesies.iucnStatus!),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
