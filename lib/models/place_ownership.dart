// lib/models/place_ownership.dart

enum PlaceStatus {
  draft,     // Only creator can see/edit
  pending,   // Awaiting approval
  approved,  // Visible to community
  public,    // Visible to all users
  rejected,  // Rejected by moderators
}

enum PlaceVisibility {
  private,   // Only creator
  community, // Users in same collections
  public,    // Everyone
}

enum EditPermissionLevel {
  owner,     // Full edit rights
  moderator, // Can edit most fields
  community, // Can suggest edits only
  none,      // No edit rights
}

class PlaceOwnership {
  final String placeId;
  final String createdBy; // User ID
  final DateTime createdAt;
  final DateTime? lastModifiedAt;
  final String? lastModifiedBy;
  final PlaceStatus status;
  final PlaceVisibility visibility;
  final List<String> moderators; // User IDs who can moderate this place
  final List<String> collaborators; // User IDs who can edit
  final int version; // For optimistic locking
  final Map<String, dynamic> metadata; // Additional data

  const PlaceOwnership({
    required this.placeId,
    required this.createdBy,
    required this.createdAt,
    this.lastModifiedAt,
    this.lastModifiedBy,
    this.status = PlaceStatus.draft,
    this.visibility = PlaceVisibility.public,
    this.moderators = const [],
    this.collaborators = const [],
    this.version = 1,
    this.metadata = const {},
  });

  factory PlaceOwnership.fromJson(Map<String, dynamic> json) {
    return PlaceOwnership(
      placeId: json['placeId'],
      createdBy: json['createdBy'],
      createdAt: DateTime.parse(json['createdAt']),
      lastModifiedAt: json['lastModifiedAt'] != null 
        ? DateTime.parse(json['lastModifiedAt']) 
        : null,
      lastModifiedBy: json['lastModifiedBy'],
      status: PlaceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PlaceStatus.draft,
      ),
      visibility: PlaceVisibility.values.firstWhere(
        (e) => e.name == json['visibility'],
        orElse: () => PlaceVisibility.public,
      ),
      moderators: List<String>.from(json['moderators'] ?? []),
      collaborators: List<String>.from(json['collaborators'] ?? []),
      version: json['version'] ?? 1,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'lastModifiedAt': lastModifiedAt?.toIso8601String(),
      'lastModifiedBy': lastModifiedBy,
      'status': status.name,
      'visibility': visibility.name,
      'moderators': moderators,
      'collaborators': collaborators,
      'version': version,
      'metadata': metadata,
    };
  }

  PlaceOwnership copyWith({
    String? placeId,
    String? createdBy,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
    String? lastModifiedBy,
    PlaceStatus? status,
    PlaceVisibility? visibility,
    List<String>? moderators,
    List<String>? collaborators,
    int? version,
    Map<String, dynamic>? metadata,
  }) {
    return PlaceOwnership(
      placeId: placeId ?? this.placeId,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      moderators: moderators ?? this.moderators,
      collaborators: collaborators ?? this.collaborators,
      version: version ?? this.version,
      metadata: metadata ?? this.metadata,
    );
  }

  // Helper methods for permission checking
  EditPermissionLevel getPermissionLevel(String userId) {
    if (createdBy == userId) return EditPermissionLevel.owner;
    if (moderators.contains(userId)) return EditPermissionLevel.moderator;
    if (collaborators.contains(userId)) return EditPermissionLevel.community;
    return EditPermissionLevel.none;
  }

  bool canEdit(String userId) {
    final permission = getPermissionLevel(userId);
    return permission == EditPermissionLevel.owner || 
           permission == EditPermissionLevel.moderator;
  }

  bool canDelete(String userId) {
    return createdBy == userId || moderators.contains(userId);
  }

  bool canView(String userId, {bool isInSameCommunity = false}) {
    switch (visibility) {
      case PlaceVisibility.private:
        return createdBy == userId || 
               moderators.contains(userId) || 
               collaborators.contains(userId);
      case PlaceVisibility.community:
        return isInSameCommunity || 
               createdBy == userId || 
               moderators.contains(userId) || 
               collaborators.contains(userId);
      case PlaceVisibility.public:
        return status == PlaceStatus.approved || status == PlaceStatus.public;
    }
  }

  bool canSuggestEdit(String userId) {
    return status == PlaceStatus.public || status == PlaceStatus.approved;
  }

  // Factory constructors for common scenarios
  factory PlaceOwnership.forNewPlace({
    required String placeId,
    required String createdBy,
    PlaceVisibility visibility = PlaceVisibility.public,
    List<String> collaborators = const [],
  }) {
    return PlaceOwnership(
      placeId: placeId,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      status: PlaceStatus.draft,
      visibility: visibility,
      collaborators: collaborators,
    );
  }

  factory PlaceOwnership.forPublicPlace({
    required String placeId,
    required String createdBy,
    List<String> moderators = const [],
  }) {
    return PlaceOwnership(
      placeId: placeId,
      createdBy: createdBy,
      createdAt: DateTime.now(),
      status: PlaceStatus.public,
      visibility: PlaceVisibility.public,
      moderators: moderators,
    );
  }
}

class PlaceEditSuggestion {
  final String id;
  final String placeId;
  final String suggestedBy;
  final DateTime suggestedAt;
  final Map<String, dynamic> suggestedChanges;
  final String? comment;
  final EditSuggestionStatus status;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewComment;

  const PlaceEditSuggestion({
    required this.id,
    required this.placeId,
    required this.suggestedBy,
    required this.suggestedAt,
    required this.suggestedChanges,
    this.comment,
    this.status = EditSuggestionStatus.pending,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewComment,
  });

  factory PlaceEditSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceEditSuggestion(
      id: json['id'],
      placeId: json['placeId'],
      suggestedBy: json['suggestedBy'],
      suggestedAt: DateTime.parse(json['suggestedAt']),
      suggestedChanges: Map<String, dynamic>.from(json['suggestedChanges']),
      comment: json['comment'],
      status: EditSuggestionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EditSuggestionStatus.pending,
      ),
      reviewedBy: json['reviewedBy'],
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt']) : null,
      reviewComment: json['reviewComment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placeId': placeId,
      'suggestedBy': suggestedBy,
      'suggestedAt': suggestedAt.toIso8601String(),
      'suggestedChanges': suggestedChanges,
      'comment': comment,
      'status': status.name,
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewComment': reviewComment,
    };
  }

  PlaceEditSuggestion copyWith({
    EditSuggestionStatus? status,
    String? reviewedBy,
    DateTime? reviewedAt,
    String? reviewComment,
  }) {
    return PlaceEditSuggestion(
      id: id,
      placeId: placeId,
      suggestedBy: suggestedBy,
      suggestedAt: suggestedAt,
      suggestedChanges: suggestedChanges,
      comment: comment,
      status: status ?? this.status,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewComment: reviewComment ?? this.reviewComment,
    );
  }
}

enum EditSuggestionStatus {
  pending,
  approved,
  rejected,
  implemented,
}

class PlaceAuditEntry {
  final String id;
  final String placeId;
  final String userId;
  final DateTime timestamp;
  final PlaceAuditAction action;
  final Map<String, dynamic>? oldValues;
  final Map<String, dynamic>? newValues;
  final String? comment;

  const PlaceAuditEntry({
    required this.id,
    required this.placeId,
    required this.userId,
    required this.timestamp,
    required this.action,
    this.oldValues,
    this.newValues,
    this.comment,
  });

  factory PlaceAuditEntry.fromJson(Map<String, dynamic> json) {
    return PlaceAuditEntry(
      id: json['id'],
      placeId: json['placeId'],
      userId: json['userId'],
      timestamp: DateTime.parse(json['timestamp']),
      action: PlaceAuditAction.values.firstWhere(
        (e) => e.name == json['action'],
      ),
      oldValues: json['oldValues'] != null 
        ? Map<String, dynamic>.from(json['oldValues'])
        : null,
      newValues: json['newValues'] != null
        ? Map<String, dynamic>.from(json['newValues'])
        : null,
      comment: json['comment'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placeId': placeId,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'action': action.name,
      'oldValues': oldValues,
      'newValues': newValues,
      'comment': comment,
    };
  }
}

enum PlaceAuditAction {
  created,
  updated,
  deleted,
  statusChanged,
  collaboratorAdded,
  collaboratorRemoved,
  moderatorAdded,
  moderatorRemoved,
  suggestionApproved,
  suggestionRejected,
}