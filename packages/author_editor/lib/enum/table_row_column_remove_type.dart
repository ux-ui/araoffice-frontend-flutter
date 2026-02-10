enum TableCellRemoveType {
  // ui로는 현재 row, column을 삭제하는 아이콘만 있기 때문에
  // current 옵션만 사용한다.

  column('current'),
  row('current');

  final String name;
  const TableCellRemoveType(this.name);
}
