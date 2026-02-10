class VulcanProjectSettingData {
  final String projectName;
  final String? projectId;
  final String? templateId;
  final String? targetFolderId;
  final bool? useCover;
  final bool? useToc;

  VulcanProjectSettingData({
    required this.projectName,
    this.projectId,
    this.templateId,
    this.targetFolderId,
    this.useCover = true,
    this.useToc = true,
  });

  VulcanProjectSettingData copyWith({
    String? projectName,
    String? projectId,
    String? templateId,
    String? targetFolderId,
    bool? useCover,
    bool? useToc,
  }) {
    return VulcanProjectSettingData(
      projectName: projectName ?? this.projectName,
      projectId: projectId ?? this.projectId,
      templateId: templateId ?? this.templateId,
      targetFolderId: targetFolderId ?? this.targetFolderId,
      useCover: useCover ?? this.useCover,
      useToc: useToc ?? this.useToc,
    );
  }
}
