/// 用户角色
enum UserRole {
  primary('小学生', 1),
  middle('初中生', 2),
  adult('成人', 3);

  final String label;
  final int level;
  const UserRole(this.label, this.level);
}

/// 用户偏好设置
class UserPreferences {
  final UserRole role;

  const UserPreferences({
    this.role = UserRole.primary,
  });

  /// 字体大小倍数
  double get fontScale {
    switch (role) {
      case UserRole.primary:
        return 1.2;
      case UserRole.middle:
        return 1.0;
      case UserRole.adult:
        return 0.9;
    }
  }

  /// 是否显示拼音标注
  bool get showPinyinAnnotation => role == UserRole.primary;

  /// 是否简化释义
  bool get simplifyDefinitions => role == UserRole.primary;

  /// 保存到SharedPreferences
  Map<String, dynamic> toJson() => {'role': role.index};

  /// 从SharedPreferences加载
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      role: UserRole.values[json['role'] ?? 0],
    );
  }
}
