import 'package:app/app/account/view/accounts_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/common_view_type.dart';

class AccountsController extends GetxController {
  final viewType = ViewType.account.obs;

  final accountsList = <AccountsItem>[
    // 확인용 데이터
    const AccountsItem(
      name: '김아라',
      email: 'arakim@gmail.com',
      role: '편집자',
      projectCount: 1,
      lastActivity: '2024.05.27',
      avatarText: 'A',
      avatarColor: Colors.blue,
    ),
    const AccountsItem(
      name: '김아라',
      email: 'user_name_test@gmaill.com',
      role: '사용자',
      projectCount: 1,
      lastActivity: '2024.05.27',
      avatarText: 'U',
      avatarColor: Colors.orange,
    ),
    const AccountsItem(
      name: '김아라',
      email: 'user_name_dummy@gmaill.com',
      role: '사용자',
      projectCount: 1,
      lastActivity: '2024.05.27',
      avatarText: 'K',
      avatarColor: Colors.teal,
    ),
    AccountsItem(
      name: '김아라',
      email: 'user_noname_sample123@gmaill.com',
      role: '사용자',
      projectCount: 1,
      lastActivity: '2024.05.27',
      avatarText: 'H',
      avatarColor: Colors.pink.shade100,
    ),
  ].obs;
}
