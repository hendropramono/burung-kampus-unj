import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/spesies_model.dart';

class BirdDetailPage extends StatefulWidget {
  final Spesies spesies;

  const BirdDetailPage({
    super.key,
    required this.spesies,
  });

  @override
  State<BirdDetailPage> createState() => _BirdDetailPageState();
}

class _BirdDetailPageState extends State<BirdDetailPage> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-9042306551705058/1585586935',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getIUCNInfo(String status) {
    switch (status.toUpperCase()) {
      case 'EX':
        return {
          'name': 'Punah (EX)',
          'desc': 'Tidak ada individu yang diketahui hidup.',
          'color': Colors.black,
        };
      case 'EW':
        return {
          'name': 'Punah di Alam Liar (EW)',
          'desc':
              'Diketahui hanya ada di penangkaran, atau sebagai populasi yang dinaturalisasi di luar rentang historisnya.',
          'color': Colors.purple[900],
        };
      case 'CR':
        return {
          'name': 'Terancam Kritis (CR)',
          'desc': 'Berisiko sangat tinggi punah di alam liar.',
          'color': Colors.red[900],
        };
      case 'EN':
        return {
          'name': 'Genting / Terancam (EN)',
          'desc': 'Berisiko tinggi mengalami kepunahan.',
          'color': Colors.red[700],
        };
      case 'VU':
        return {
          'name': 'Rentan (VU)',
          'desc': 'Risiko tinggi terancam di alam liar.',
          'color': Colors.orange[800],
        };
      case 'NT':
        return {
          'name': 'Hampir Terancam (NT)',
          'desc': 'Kemungkinan akan terancam dalam waktu dekat.',
          'color': Colors.lightGreen[700],
        };
      case 'LC':
        return {
          'name': 'Risiko Rendah (LC)',
          'desc':
              'Risiko terendah; tidak memenuhi syarat untuk kategori risiko yang lebih tinggi. Taksi yang tersebar luas dan melimpah termasuk dalam kategori ini.',
          'color': Colors.green[700],
        };
      case 'DD':
        return {
          'name': 'Kurang Data (DD)',
          'desc':
              'Tidak cukup data untuk membuat penilaian tentang risiko kepunahannya.',
          'color': Colors.grey[700],
        };
      case 'NE':
        return {
          'name': 'Tidak Dievaluasi (NE)',
          'desc': 'Belum dievaluasi terhadap kriteria.',
          'color': Colors.grey[600],
        };
      default:
        return {
          'name': status,
          'desc': '-',
          'color': Colors.grey,
        };
    }
  }

  void _showIUCNInfo(BuildContext context, String status) {
    final info = _getIUCNInfo(status);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Icon(Icons.shield_outlined,
                    color: info['color'] as Color, size: 20),
                const SizedBox(width: 8),
                Text(
                  'STATUS KONSERVASI',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        letterSpacing: 1.2,
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              info['name'] as String,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: info['color'] as Color,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              info['desc'] as String,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    color: Colors.grey[800],
                  ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Tutup'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<SpesiesPhoto> fotos = widget.spesies.fotos;
    final String? iucnStatus = widget.spesies.iucnStatus;

    return Scaffold(
      body: SafeArea(
        top: false, // Membiarkan gambar tetap di bawah status bar
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 350,
              pinned: true,
              stretch: true,
              backgroundColor: Theme.of(context).colorScheme.primary,
              leading: IconButton(
                icon: const CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: Icon(Icons.arrow_back, color: Colors.white),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                ],
                title: LayoutBuilder(
                  builder: (context, constraints) {
                    final opacity = (constraints.maxHeight - kToolbarHeight) /
                        (350 - kToolbarHeight);
                    return Opacity(
                      opacity: 1.0 - opacity.clamp(0.0, 1.0),
                      child: Text(
                        widget.spesies.namaLokal,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
                background: GestureDetector(
                  onTap: () {
                    if (fotos.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImagePage(
                            photo: fotos.first,
                            heroTag: 'bird-image-${widget.spesies.id}',
                          ),
                        ),
                      );
                    }
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'bird-image-${widget.spesies.id}',
                        child: fotos.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: fotos.first.url,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
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
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black54, Colors.transparent],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.spesies.namaLokal,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.spesies.namaIlmiah,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                          if (iucnStatus != null) ...[
                            const SizedBox(height: 20),
                            _buildIUCNBadge(context, iucnStatus),
                          ],
                        ],
                      ),
                    ),
                    if (fotos.length > 1) ...[
                      _buildGallery(context, fotos),
                      const SizedBox(height: 24),
                    ],
                    if (widget.spesies.deskripsi != null)
                      _buildInfoCard(
                        context,
                        'Deskripsi',
                        widget.spesies.deskripsi!,
                        Icons.description_outlined,
                      ),
                    const SizedBox(height: 32),
                    if (_isLoaded && _bannerAd != null)
                      Center(
                        child: Container(
                          key: Key('ad-container-${widget.spesies.id}'),
                          alignment: Alignment.center,
                          width: _bannerAd!.size.width.toDouble(),
                          height: _bannerAd!.size.height.toDouble(),
                          child: AdWidget(ad: _bannerAd!),
                        ),
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIUCNBadge(BuildContext context, String status) {
    final info = _getIUCNInfo(status);
    final color = info['color'] as Color;

    return InkWell(
      onTap: () => _showIUCNInfo(context, status),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.priority_high,
                  size: 12, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STATUS KONSERVASI',
                  style: TextStyle(
                    color: color.withOpacity(0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  info['name'] as String,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      BuildContext context, String title, String content, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        content,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }

  Widget _buildGallery(BuildContext context, List<SpesiesPhoto> fotos) {
    final otherFotos = fotos.skip(1).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            physics: const BouncingScrollPhysics(),
            itemCount: otherFotos.length,
            itemBuilder: (context, index) {
              final photo = otherFotos[index];
              final String heroTag =
                  'bird-image-${widget.spesies.id}-${index + 1}';

              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImagePage(
                          photo: photo,
                          heroTag: heroTag,
                        ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: heroTag,
                    child: Container(
                      width: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CachedNetworkImage(
                          imageUrl: photo.url,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[100],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            'assets/images/bird.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final SpesiesPhoto photo;
  final String heroTag;

  const FullScreenImagePage({
    super.key,
    required this.photo,
    required this.heroTag,
  });

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Hero(
            tag: heroTag,
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: photo.url,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(color: Colors.white)),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/bird.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          if (photo.fotografer != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 40),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Foto oleh:',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: photo.link != null
                          ? () => _launchUrl(photo.link!)
                          : null,
                      child: Text(
                        photo.fotografer!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: photo.link != null
                              ? TextDecoration.underline
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
