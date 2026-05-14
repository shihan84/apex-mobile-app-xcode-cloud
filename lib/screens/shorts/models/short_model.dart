class Short {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? thumbnailUrl;
  final String videoUrl;
  final int? duration;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int? creatorId;
  final List<String>? hashtags;
  final List<String>? mentions;
  final String? location;
  final bool isPremium;
  final int? planId;
  final String access;
  final String status;
  final bool featured;
  final double trendingScore;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isLiked;

  Short({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.thumbnailUrl,
    required this.videoUrl,
    this.duration,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.creatorId,
    this.hashtags,
    this.mentions,
    this.location,
    this.isPremium = false,
    this.planId,
    this.access = 'free',
    this.status = 'active',
    this.featured = false,
    this.trendingScore = 0.0,
    required this.createdAt,
    required this.updatedAt,
    this.isLiked = false,
  });

  factory Short.fromJson(Map<String, dynamic> json) {
    return Short(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      videoUrl: json['video_url'] as String,
      duration: json['duration'] as int?,
      viewCount: json['view_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      shareCount: json['share_count'] as int? ?? 0,
      creatorId: json['creator_id'] as int?,
      hashtags: json['hashtags'] != null ? List<String>.from(json['hashtags']) : null,
      mentions: json['mentions'] != null ? List<String>.from(json['mentions']) : null,
      location: json['location'] as String?,
      isPremium: json['is_premium'] as bool? ?? false,
      planId: json['plan_id'] as int?,
      access: json['access'] as String? ?? 'free',
      status: json['status'] as String? ?? 'active',
      featured: json['featured'] as bool? ?? false,
      trendingScore: (json['trending_score'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }

  Short copyWith({
    int? id,
    String? name,
    String? slug,
    String? description,
    String? thumbnailUrl,
    String? videoUrl,
    int? duration,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    int? creatorId,
    List<String>? hashtags,
    List<String>? mentions,
    String? location,
    bool? isPremium,
    int? planId,
    String? access,
    String? status,
    bool? featured,
    double? trendingScore,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isLiked,
  }) {
    return Short(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      duration: duration ?? this.duration,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      creatorId: creatorId ?? this.creatorId,
      hashtags: hashtags ?? this.hashtags,
      mentions: mentions ?? this.mentions,
      location: location ?? this.location,
      isPremium: isPremium ?? this.isPremium,
      planId: planId ?? this.planId,
      access: access ?? this.access,
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
      'name': name,
      'slug': slug,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'video_url': videoUrl,
      'duration': duration,
      'view_count': viewCount,
      'like_count': likeCount,
      'comment_count': commentCount,
      'share_count': shareCount,
      'creator_id': creatorId,
      'hashtags': hashtags,
      'mentions': mentions,
      'location': location,
      'is_premium': isPremium,
      'plan_id': planId,
      'access': access,
      'status': status,
      'featured': featured,
      'trending_score': trendingScore,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_liked': isLiked,
    };
  }

  String get formattedViewCount {
    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K';
    } else {
      return viewCount.toString();
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
}
