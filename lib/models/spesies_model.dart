import 'package:cloud_firestore/cloud_firestore.dart';

class SpesiesPhoto {
  final String url;
  final String? fotografer;
  final String? link;

  SpesiesPhoto({
    required this.url,
    this.fotografer,
    this.link,
  });

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'fotografer': fotografer,
      'link': link,
    };
  }

  factory SpesiesPhoto.fromJson(dynamic json) {
    if (json == null) return SpesiesPhoto(url: '');
    if (json is String) {
      return SpesiesPhoto(url: json);
    }
    return SpesiesPhoto(
      url: (json['url'] ?? '') as String,
      fotografer: json['fotografer'] as String?,
      link: json['link'] as String?,
    );
  }
}

class Spesies {
  final String id;
  final String namaIlmiah;
  final String namaLokal;
  final String kelas; // Aves, Mamalia
  final List<String> lokasi;
  final List<SpesiesPhoto> fotos;
  final String? deskripsi;
  final String? iucnStatus;
  final Timestamp createdAt;

  Spesies({
    required this.id,
    required this.namaIlmiah,
    required this.namaLokal,
    required this.kelas,
    required this.lokasi,
    required this.fotos,
    this.deskripsi,
    this.iucnStatus,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaIlmiah': namaIlmiah,
      'namaLokal': namaLokal,
      'kelas': kelas,
      'lokasi': lokasi,
      'fotos': fotos.map((f) => f.toJson()).toList(),
      'deskripsi': deskripsi,
      'iucnStatus': iucnStatus,
      'createdAt': createdAt,
    };
  }

  factory Spesies.fromJson(Map<String, dynamic> json) {
    List<SpesiesPhoto> parsedFotos = [];
    if (json['fotos'] != null) {
      parsedFotos = (json['fotos'] as List).map((f) => SpesiesPhoto.fromJson(f)).toList();
    } else if (json['fotoUrls'] != null) {
      // Backward compatibility for old data format
      parsedFotos = (json['fotoUrls'] as List).map((f) => SpesiesPhoto.fromJson(f)).toList();
    }

    return Spesies(
      id: (json['id'] ?? '') as String,
      namaIlmiah: (json['namaIlmiah'] ?? '') as String,
      namaLokal: (json['namaLokal'] ?? '') as String,
      kelas: (json['kelas'] ?? 'Aves') as String,
      lokasi: List<String>.from(json['lokasi'] ?? []),
      fotos: parsedFotos,
      deskripsi: json['deskripsi'] as String?,
      iucnStatus: json['iucnStatus'] as String?,
      createdAt: (json['createdAt'] ?? Timestamp.now()) as Timestamp,
    );
  }
}
