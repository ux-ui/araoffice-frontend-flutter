import 'package:app_ui/app_ui.dart';
import 'package:author_editor/data/vulcan_epub_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../enum/enums.dart';

class EditorExportDialog extends StatefulWidget {
  final String projectName;
  final String projectId;
  final ValueChanged<VulcanEpubData> onExport;
  final VoidCallback onExportPdf;

  const EditorExportDialog({
    super.key,
    required this.projectName,
    required this.projectId,
    required this.onExport,
    required this.onExportPdf,
  });

  @override
  State<EditorExportDialog> createState() => _EditorExportDialogState();
}

class _EditorExportDialogState extends State<EditorExportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _publisherController = TextEditingController(); // 출판사
  final _copyrightController = TextEditingController(); // 저작권
  final _publishDateController = TextEditingController(); // 발행일

  LanguageType _language = LanguageType.ko; //언어
  // bool _isIncludeFont = false; // 글꼴포함 체크
  //PublishType _publishType = PublishType.test; // 출판유형

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.projectName;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Table(columnWidths: const {
            0: IntrinsicColumnWidth(flex: 1), // 왼쪽 열
            1: FlexColumnWidth(3), // 오른쪽 열 (2배 넓게)
          }, children: [
            _buildTableRow([
              // 제목
              Text('epub_title'.tr),
              VulcanXTextField(inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'[/\";\n]')),
              ], controller: _titleController)
            ]),
            _buildTableRow([
              // 저자, 작성자
              Text('doc_author'.tr),
              VulcanXTextField(controller: _authorController)
            ]),
            // _buildTableRow([
            //   // 고유번호
            //   Text('epub_uuid'.tr),
            //   Row(
            //     children: [
            //       VulcanXDropdown<String>(
            //         width: 130,
            //         value: 'uuid',
            //         stringItems: const ['uuid', 'uuid2'],
            //         onChanged: (String? newValue) {},
            //         hintText: 'uuid',
            //         hintIcon: Icons.lock, // 힌트 텍스트 옆의 아이콘
            //       ),
            //       const SizedBox(width: 8),
            //       const Expanded(flex: 3, child: VulcanXTextField()),
            //     ],
            //   )
            // ]),
            _buildTableRow([
              // 언어
              Text('epub_lang'.tr),
              Row(
                children: [
                  VulcanXDropdown<LanguageType>(
                    width: 130,
                    value: _language,
                    enumItems: LanguageType.values,
                    onChanged: (LanguageType? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _language = newValue;
                        });
                      }
                    },
                    hintText: '',
                    hintIcon: Icons.lock, // 힌트 텍스트 옆의 아이콘
                    displayStringForOption: (LanguageType option) =>
                        option.name,
                  ),
                  const SizedBox(width: 8),
                  //발행일, 작성일
                  Text('doc_publish_date'.tr),
                  const SizedBox(width: 8),
                  Expanded(
                      child: VulcanXDatePickerTextField(
                          initialDate: DateTime.now(),
                          controller: _publishDateController)),
                ],
              )
            ]),
            _buildTableRow([
              //출판사, 기관명
              Text('doc_publisher'.tr),
              VulcanXTextField(controller: _publisherController)
            ]),
            _buildTableRow([
              //저작권, 부서명
              Text('doc_copyright'.tr),
              VulcanXTextField(controller: _copyrightController)
            ]),
            // TODO : 끌꼴을 포함하여 저장 기능 추가 필요
            // _buildTableRow([
            //   const SizedBox.shrink(),
            //   //include_font
            //   LabelRectangleCheckbox(
            //       label: 'include_font'.tr,
            //       onChanged: (value) {
            //         setState(() {
            //           _isIncludeFont = value;
            //         });
            //       })
            // ]),
            // TODO : doc 기반에서는 필요없어 비활성화
            // _buildTableRow([
            //   //출판유형
            //   Text('epub_publish_type'.tr),
            //   VulcanXDropdown<PublishType>(
            //     value: _publishType,
            //     enumItems: PublishType.values,
            //     onChanged: (PublishType? newValue) {
            //       if (newValue != null) {
            //         setState(() {
            //           _publishType = newValue;
            //         });
            //       }
            //     },
            //     hintText: '',
            //     hintIcon: Icons.lock, // 힌트 텍스트 옆의 아이콘
            //     displayStringForOption: (PublishType option) => option.name,
            //   ),
            // ]),
          ]),
          const SizedBox(height: 8),
          const VulcanXDivider(space: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              VulcanXElevatedButton.primary(
                width: 150,
                child: Text('${'office_epub'.tr} (${'export'.tr})'),
                onPressed: () {
                  final epubData = VulcanEpubData(
                    title: _titleController.text,
                    author: _authorController.text,
                    publishDate: DateTime.parse(_publishDateController.text),
                    language: _language.translationKey,
                    publisher: _publisherController.text,
                    copyright: _copyrightController.text,
                    //location:,
                    // isIncludeFont: _isIncludeFont,
                    // publishType: _publishType.javaEnum,
                    isIncludeFont: true,
                    publishType: PublishType.official.javaEnum,
                    projectId: widget.projectId,
                  );

                  widget.onExport.call(epubData);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(List<Widget> cells, {double height = 50}) {
    return TableRow(
      children: cells
          .map((cell) => ConstrainedBox(
                constraints: BoxConstraints(minHeight: height),
                child: Align(alignment: Alignment.centerLeft, child: cell),
              ))
          .toList(),
    );
  }
}
