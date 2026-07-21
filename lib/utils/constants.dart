/// App-wide constants for BirtaKhabar.
library;

/// News categories as defined in the project Scope (section 3.3).
enum NewsCategory { local, emergency, sports, business, events }

extension NewsCategoryX on NewsCategory {
  String get label {
    switch (this) {
      case NewsCategory.local:
        return 'Local';
      case NewsCategory.emergency:
        return 'Emergency';
      case NewsCategory.sports:
        return 'Sports';
      case NewsCategory.business:
        return 'Business';
      case NewsCategory.events:
        return 'Events';
    }
  }

  static NewsCategory fromString(String value) {
    return NewsCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => NewsCategory.local,
    );
  }
}

/// Roles supported by the app (residents vs. administrators / editors).
enum UserRole { resident, admin }

extension UserRoleX on UserRole {
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => UserRole.resident,
    );
  }
}

/// Status for community-submitted news tips (section 3.3 - Community News Tips).
enum TipStatus { pending, approved, rejected }

extension TipStatusX on TipStatus {
  String get label {
    switch (this) {
      case TipStatus.pending:
        return 'Pending Review';
      case TipStatus.approved:
        return 'Approved';
      case TipStatus.rejected:
        return 'Rejected';
    }
  }

  static TipStatus fromString(String value) {
    return TipStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => TipStatus.pending,
    );
  }
}

class FirestoreCollections {
  static const users = 'users';
  static const news = 'news';
  static const alerts = 'alerts';
  static const newsTips = 'newsTips';
  static const businesses = 'businesses';
}

class AppStrings {
  static const appName = 'BirtaKhabar';
  static const tagline = 'Birtamode\'s local news, in real time.';
}
