enum EditorCallBackType {
  load('onLoad'),
  singleSelected('onSingleSelected'),
  noneSelected('onNoneSelected'),
  caretSelected('onCaretSelected'),
  multiSelected('onMultiSelected'),
  insertElement('onInsertElement'),
  cellSelected('onCellSelected'),
  widgetSelected('onWidgetSelected');

  final String name;
  const EditorCallBackType(this.name);
}
