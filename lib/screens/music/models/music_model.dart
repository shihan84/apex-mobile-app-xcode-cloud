class Music {
  final int id;
  final String title;
  final String slug;
  final String? artistName;
  final String? albumName;
  final String? genre;
  final String? thumbnailUrl;
  final String audioUrl;
  final int? duration;
  final int? fileSize;
  final int? bitrate;
  final int? sampleRate;
  final String? lyrics;
  final int playCount;
  final int likeCount;
  final int downloadCount;
  final bool isExplicit;
  final bool isPremium;
  final int? planId;
  final String access;
  final DateTime? releaseDate;
  final String? recordLabel;
  final String? copyright;
  final String status;
  final bool featured;
  final double trendingScore;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isLiked;

  Music({
    required this.id,
    required this.title,
    required this.slug,
    this.artistName,
    this.albumName,
    this.genre,
    this.thumbnailUrl,
    required this.audioUrl,
    this.duration,
    this.fileSize,
    this.bitrate,
    this.sampleRate,
    this.lyrics,
    this.playCount = 0,
    this.likeCount = 0,
    this.downloadCount = 0,
    this.isExplicit = false,
    this.isPremium = false,
    this.planId,
    this.access = 'free',
    this.releaseDate,
    this.recordLabel,
    this.copyright,
    this.status = 'active',
    this.featured = false,
    this.trendingScore = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.isLiked = false,
  });

  factory Music.fromJson(Map<String, dynamic> json) {
    return Music(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      artistName: json['artist_name'] as String?,
      albumName: json['album_name'] as String?,
      genre: json['genre'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      audioUrl: json['audio_url'] as String,
      duration: json['duration'] as int?,
      fileSize: json['file_size'] as int?,
      bitrate: json['bitrate'] as int?,
      sampleRate: json['sample_rate'] as int?,
      lyrics: json['lyrics'] as String?,
      playCount: json['play_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      downloadCount: json['download_count'] as int? ?? 0,
      isExplicit: json['is_explicit'] as bool? ?? false,
      isPremium: json['is_premium'] as bool? ?? false,
      planId: json['plan_id'] as int?,
      access: json['access'] as String? ?? 'free',
      releaseDate: json['release_date'] != null ? DateTime.parse(json['release_date']) : null,
      recordLabel: json['record_label'] as String?,
      copyright: json['copyright'] as String?,
      status: json['status'] as String? ?? 'active',
      featured: json['featured'] as bool? ?? false,
      trendingScore: (json['trending_score'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }

  Music copyWith({
    int? id,
    String? title,
    String? slug,
    String? artistName,
    String? albumName,
    String? genre,
    String? thumbnailUrl,
    String? audioUrl,
    int? duration,
    int? fileSize,
    int? bitrate,
    int? sampleRate,
    String? lyrics,
    int? playCount,
    int? likeCount,
    int? downloadCount,
    bool? isExplicit,
    bool? isPremium,
    int? planId,
    String? access,
    DateTime? releaseDate,
    String? recordLabel,
    String? copyright,
    String? status,
    bool? featured,
    double? trendingScore,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isLiked,
  }) {
    return Music(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      artistName: artistName ?? this.artistName,
      albumName: albumName ?? this.albumName,
      genre: genre ?? this.genre,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      fileSize: fileSize ?? this.fileSize,
      bitrate: bitrate ?? this.bitrate,
      sampleRate: sampleRate ?? this.sampleRate,
      lyrics: lyrics ?? this.lyrics,
      playCount: playCount ?? this.playCount,
      likeCount: likeCount ?? this.likeCount,
      downloadCount: downloadCount ?? this.downloadCount,
      isExplicit: isExplicit ?? this.isExplicit,
      isPremium: isPremium ?? this.isPremium,
      planId: planId ?? this.planId,
      access: access ?? this.access,
      releaseDate: releaseDate ?? this.releaseDate,
      recordLabel: recordLabel ?? this.recordLabel,
      copyright: copyright ?? this.copyright,
      status: status ?? this.status,
      featured: featured ?? this.featured,
      trendingScore: trendingScore ?? this.trendingScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'artist_name': artistName,
      'album_name': albumName,
      'genre': genre,
      'thumbnail_url': thumbnailUrl,
      'audio_url': audioUrl,
      'duration': duration,
      'file_size': fileSize,
      'bitrate': bitrate,
      'sample_rate': sampleRate,
      'lyrics': lyrics,
      'play_count': playCount,
      'like_count': likeCount,
      'download_count': downloadCount,
      'is_explicit': isExplicit,
      'is_premium': isPremium,
      'plan_id': planId,
      'access': access,
      'release_date': releaseDate?.toIso8601String(),
      'record_label': recordLabel,
      'copyright': copyright,
      'status': status,
      'featured': featured,
      'trending_score': trendingScore,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_liked': isLiked,
    };
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

  String get formattedLikeCount {
    if (likeCount >= 1000000) {
      return '${(likeCount / 1000000).toStringAsFixed(1)}M';
    } else if (likeCount >= 1000) {
      return '${(likeCount / 1000).toStringAsFixed(1)}K';
    } else {
      return likeCount.toString();
    }
  }

  String get formattedDuration {
    if (duration == null) return '';
    
    final minutes = (duration! ~/ 60);
    final seconds = duration! % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String get displayArtist {
    return artistName ?? 'Unknown Artist';
  }

  String get displayAlbum {
    return albumName ?? 'Unknown Album';
  }
}
