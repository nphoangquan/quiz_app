import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/entities/subscription_tier.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    required super.createdAt,
    super.avatar,
    super.photoUrl,
    required super.stats,
    super.role,
    super.subscriptionTier,
    required super.usageLimits,
  });

  /// Create UserModel from Firebase User (Google Sign-In)
  factory UserModel.fromFirebaseUser(User firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'Unknown User',
      email: firebaseUser.email ?? '',
      photoUrl: firebaseUser.photoURL,
      createdAt: DateTime.now(),
      stats: const UserStats(),
      role: UserRole.user, // Default role cho user mới
      subscriptionTier: SubscriptionTier.free, // Default FREE tier
      usageLimits: UsageLimits(
        lastAiResetDate: DateTime.now(),
        lastQuizResetDate: DateTime.now(),
      ),
    );
  }

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      avatar: data['avatar'],
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      stats: data['stats'] != null
          ? UserStats.fromMap(data['stats'] as Map<String, dynamic>)
          : const UserStats(),
      role: UserRoleExtension.fromString(data['role'] ?? 'user'),
      subscriptionTier: SubscriptionTierExtension.fromString(
        data['subscriptionTier'] ?? 'free',
      ),
      usageLimits: data['usageLimits'] != null
          ? UsageLimits.fromMap(data['usageLimits'] as Map<String, dynamic>)
          : UsageLimits(
              lastAiResetDate: DateTime.now(),
              lastQuizResetDate: DateTime.now(),
            ),
    );
  }

  /// Convert UserModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'avatar': avatar,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'stats': stats.toMap(),
      'role': role.value,
      'subscriptionTier': subscriptionTier.value, // NEW: Save subscription tier
      'usageLimits': usageLimits.toMap(), // NEW: Save usage limits
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    DateTime? createdAt,
    String? avatar,
    String? photoUrl,
    UserStats? stats,
    UserRole? role,
    SubscriptionTier? subscriptionTier,
    UsageLimits? usageLimits,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      avatar: avatar ?? this.avatar,
      photoUrl: photoUrl ?? this.photoUrl,
      stats: stats ?? this.stats,
      role: role ?? this.role,
      subscriptionTier: subscriptionTier ?? this.subscriptionTier,
      usageLimits: usageLimits ?? this.usageLimits,
    );
  }
}
