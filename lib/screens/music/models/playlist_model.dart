import 'music_model.dart';

class Playlist {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? thumbnailUrl;
  final int userId;
  final bool isPublic;
  final bool isFeatured;
  final int trackCount;
  final int totalDuration;
  final int playCount;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Music>? tracks;

  Playlist({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.thumbnailUrl,
    required this.userId,
    this.isPublic = true,
    this.isFeatured = false,
    this.trackCount = 0,
    this.totalDuration = 0,
    this.playCount = 0,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
    this.tracks,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      userId: json['user_id'] as int,
      isPublic: json['is_public'] as bool? ?? true,
      isFeatured: json['is_featured'] as bool? ?? false,
      trackCount: json['track_count'] as int? ?? 0,
      totalDuration: json['total_duration'] as int? ?? 0,
      playCount: json['play_count'] as int? ?? 0,
      status: json['status'] as String? ?? 'active',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      tracks: json['tracks'] != null ? (json['tracks'] as List).map((track) => Music.fromJson(track)).toList() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'user_id': userId,
      'is_public': isPublic,
      'is_featured': isFeatured,
      'track_count': trackCount,
      'total_duration': totalDuration,
      'play_count': playCount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'tracks': tracks?.map((track) => track.toJson()).toList(),
    };
  }

  String get formattedTrackCount {
    return trackCount.toString();
  }

  String get formattedDuration {
    if (totalDuration == 0) return '0:00';
    
    final hours = (totalDuration ~/ 3600);
    final minutes = ((totalDuration % 3600) ~/ 60);
    final seconds = totalDuration % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedPlayCount {
    if (playCount >= 1000000) {
      return '${(playCount / 1000000).toStringAsFixed(1)}M';
    } else if (playCount >= 1000) {
      return '${(playCount / 1000).toStringAsFixed(1)}K';
    } else {
      return playCount.toString();
    }
  }
}
