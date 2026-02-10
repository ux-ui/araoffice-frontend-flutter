import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../data/vulcan_memo_data.dart';
import '../states/document_state.dart';

class MemoPopup extends StatefulWidget {
  final List<VulcanMemoData>? memoList;
  final DocumentState documentState;
  final bool isEditingPermission;
  final void Function(VulcanMemoData)? onMemoAdded;
  final void Function(VulcanMemoData)? onMemoUpdated;
  final void Function(VulcanMemoData)? onMemoDeleted;
  const MemoPopup({
    super.key,
    required this.memoList,
    this.onMemoAdded,
    this.onMemoUpdated,
    this.onMemoDeleted,
    required this.documentState,
    required this.isEditingPermission,
  });

  static Future<void> show({
    required BuildContext context,
    required List<VulcanMemoData> memoList,
    required DocumentState documentState,
    required bool isEditingPermission,
    void Function(VulcanMemoData)? onMemoAdded,
    void Function(VulcanMemoData)? onMemoUpdated,
    void Function(VulcanMemoData)? onMemoDeleted,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => MemoPopup(
        memoList: memoList,
        onMemoAdded: onMemoAdded,
        onMemoUpdated: onMemoUpdated,
        onMemoDeleted: onMemoDeleted,
        documentState: documentState,
        isEditingPermission: isEditingPermission,
      ),
    );
  }

  @override
  State<MemoPopup> createState() => _MemoPopupState();
}

class _MemoPopupState extends State<MemoPopup> {
  late List<VulcanMemoData> _memoList;
  final TextEditingController _memoController = TextEditingController();
  VulcanMemoData? _editingMemo;

  @override
  void initState() {
    super.initState();
    _memoList = List<VulcanMemoData>.from(widget.memoList ?? []);
    _sortMemoList();
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  void _sortMemoList() {
    _memoList.sort((a, b) {
      if (a.createdAt == null && b.createdAt == null) return 0;
      if (a.createdAt == null) return 1;
      if (b.createdAt == null) return -1;
      return b.createdAt!.compareTo(a.createdAt!);
    });
  }

  void _addMemo() {
    if (_memoController.text.trim().isEmpty) return;
    if (_memoList.length >= 100) return;
    if (!widget.isEditingPermission) return;

    final newMemo = VulcanMemoData(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      memo: _memoController.text.trim(),
      createdAt: DateTime.now(),
      nickname: widget.documentState.rxUserId.value,
    );

    setState(() {
      _memoList.add(newMemo);
      _sortMemoList();
      _memoController.clear();
    });

    widget.onMemoAdded?.call(newMemo);
  }

  void _startEdit(VulcanMemoData memo) {
    setState(() {
      _editingMemo = memo;
      _memoController.text = memo.memo ?? '';
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingMemo = null;
      _memoController.clear();
    });
  }

  void _updateMemo() {
    if (_editingMemo == null || _memoController.text.trim().isEmpty) return;
    if (_editingMemo!.id == null) return;

    final updatedMemo = _editingMemo!.copyWith(
      memo: _memoController.text.trim(),
    );

    setState(() {
      if (_memoList.isNotEmpty && _editingMemo!.id != null) {
        final index = _memoList.indexWhere(
          (m) => m.id != null && m.id == _editingMemo!.id,
        );
        if (index != -1) {
          _memoList[index] = updatedMemo;
        }
      }
      _sortMemoList();
      _editingMemo = null;
      _memoController.clear();
    });

    widget.onMemoUpdated?.call(updatedMemo);
  }

  void _deleteMemo(VulcanMemoData memo) {
    if (memo.id == null) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => PointerInterceptor(
        child: AlertDialog(
          title: Text('memo_delete'.tr),
          content: Text('memo_delete_confirm'.tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (_memoList.isNotEmpty && memo.id != null) {
                    _memoList
                        .removeWhere((m) => m.id != null && m.id == memo.id);
                  }
                });
                Navigator.pop(context);
                widget.onMemoDeleted?.call(memo);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('memo_delete'.tr),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: PointerInterceptor(
        child: Container(
          width: 500,
          height: 600,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'memo'.tr,
                    style: context.titleMedium?.apply(color: context.onSurface),
                  ),
                  IconButton(
                    iconSize: 20,
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // 메모 입력 영역
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: 2,
                    child: VulcanXTextField(
                      height: 60,
                      controller: _memoController,
                      hintText: !widget.isEditingPermission
                          ? 'memo_no_permission'.tr
                          : _memoList.length >= 100
                              ? 'memo_limit_reached'.tr
                              : 'memo_input_hint'.tr,
                      maxLength: 100,
                      readOnly: (!widget.isEditingPermission ||
                              _memoList.length >= 100) &&
                          _editingMemo == null,
                      onSubmitted: (_) {
                        if (_editingMemo != null) {
                          _updateMemo();
                        } else {
                          _addMemo();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_editingMemo != null) ...[
                    Flexible(
                      child: VulcanXElevatedButton.primary(
                        onPressed: _updateMemo,
                        child: Text('memo_update'.tr,
                            style: context.bodyMedium
                                ?.copyWith(color: context.onPrimary)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: TextButton(
                        onPressed: _cancelEdit,
                        child: Text('cancel'.tr),
                      ),
                    ),
                  ] else
                    Flexible(
                      flex: 1,
                      child: VulcanXElevatedButton.primary(
                        onPressed: (!widget.isEditingPermission ||
                                _memoList.length >= 100)
                            ? null
                            : _addMemo,
                        child: Text('memo_add'.tr,
                            style: context.bodyMedium
                                ?.copyWith(color: context.onPrimary)),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // 메모 목록
              Expanded(
                child: _memoList.isEmpty
                    ? Center(
                        child: Text(
                          'memo_list_empty'.tr,
                          style: context.bodyMedium?.apply(
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _memoList.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final memo = _memoList[index];
                          return _buildMemoItem(memo);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMemoItem(VulcanMemoData memo) {
    return VulcanXRoundedContainer(
      backgroundColor: const Color(0xffF5F5F5),
      borderRadius: 8.0,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memo.memo ?? '',
                        style: context.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (memo.nickname != null) ...[
                            Text(
                              memo.nickname!,
                              style: context.bodySmall?.apply(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: context.bodySmall?.apply(
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            _formatDate(memo.createdAt),
                            style: context.bodySmall?.apply(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // IconButton(
                    //   icon: const Icon(Icons.edit, size: 18),
                    //   onPressed: () => _startEdit(memo),
                    //   padding: EdgeInsets.zero,
                    //   constraints: const BoxConstraints(),
                    //   tooltip: 'memo_update'.tr,
                    // ),
                    if (memo.nickname ==
                        widget.documentState.rxUserId.value) ...[
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18),
                        onPressed: () => _deleteMemo(memo),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        color: Colors.red,
                        tooltip: 'memo_delete'.tr,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
