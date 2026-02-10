# changePageTreeList 호출 흐름과 프로젝트 접근 권한 검증

## 1. 호출 경로 (순서)

### 1단계: 호출부 (2곳)

| 위치 | 상황 |
|------|------|
| **page_panel.dart:38** | `onPageClick: (page) => controller.changePageTreeList(page)` — 사용자가 트리에서 **다른 페이지를 클릭**할 때 |
| **vulcan_editor.dart:191** | `controller.changePageTreeList(pages.last)` — **새 페이지 생성** 후 해당 페이지로 이동할 때 |

두 경우 모두 **권한 검사 없이** 곧바로 `changePageTreeList`를 호출합니다.

---

### 2단계: changePageTreeList (vulcan_editor_controller.dart:1128)

```dart
Future<void> changePageTreeList(TreeListModel pageData) async {
  if (documentState.rxPageCurrent.value.hashCode != pageData.hashCode) {
    await changedPage(pageData);
  }
}
```

- **역할:** 현재 페이지와 클릭한 페이지가 다르면 `changedPage`만 호출.
- **권한 검사:** 없음.

---

### 3단계: changedPage (vulcan_editor_controller.dart:1134)

실제 페이지 전환 로직이 들어 있는 구간입니다.

| 순서 | 코드 위치 | 동작 | 권한 관련 |
|------|-----------|------|-----------|
| ① | 1137–1152 | 현재 페이지가 바뀌는 경우, 타이머 취소 후 `triggerUpdatePageContent`로 **저장** | 없음 |
| ② | 1155–1162 | 편집 권한 사용자만 `setEditorUserPermission(false)` 등 상태 정리 | 편집 권한 상태만 |
| ③ | 1167–1173 | `pageUrl = getBuildTypeUrl(projectId, fileName)` → 예: `.../user/project/{projectId}/page2.xhtml` | 없음 |
| ④ | 1175–1176 | `rxPageCurrent`, `rxPageUrl` 갱신 | 없음 |
| ⑤ | 1175–1183 | `loginService.userInfo()` 후 **`isPermission()`** 호출 | ⬅️ 여기서 권한 관련 로직 |
| ⑥ | 1185–1186 | `editor?.unload()` 후 **`editor?.load(rxPageUrl.value)`** | ⬅️ 여기서 실제 xhtml 요청 발생 |
| ⑦ | 1189–1214 | 웹소켓/공유 관련 `onChangedPage`, 커서 위치 전송 등 | 없음 |

---

### 4단계: isPermission() (vulcan_editor_controller.dart:394)

```dart
Future<bool> isPermission() async {
  final result = await apiService.getUserList(documentState.rxProjectId.value);
  // 공유 유저 목록에서 현재 사용자 포함 여부로 편집 권한만 판단
  final hasUserId = userIds.contains(documentState.rxUserId.value);
  // ...
  return hasUserId;
}
```

- **역할:** `getUserList(projectId)`로 **공유 유저 목록**을 받아, 현재 사용자가 그 목록에 있는지로 **편집 가능 여부**만 반환.
- **한계:**
  - **프로젝트 접근 자체가 거부된 경우(403)** 를 구분하지 않음.
  - `getUserList`가 예외 시 `null`만 반환해, 403을 호출부에 전달하지 않음.
- 따라서 **“접근 거부(403)”** 를 이 함수만으로는 알 수 없습니다.

---

### 5단계: editor.load(rxPageUrl.value)

- `rxPageUrl`은 `getBuildTypeUrl`로 만든 **프로젝트 xhtml URL**입니다.
- 이 시점에 **실제 HTTP 요청**이 나가고, 백엔드가 403을 주면:
  - 403 응답 HTML 안의 스크립트가 `postMessage({ type: 'PROJECT_ACCESS_DENIED' })` 를 보내고,
  - VulcanEditor의 `window.onMessage` 리스너가 받아 **EasyLoading + 홈 이동**을 이미 처리하고 있습니다.

즉, **페이지를 바꾼 뒤** 로드 시 403이 나오면 그때는 이미 처리되고,  
**페이지 전환 직전**에 미리 접근 가능 여부를 검사하고 싶다면 아래와 같이 추가하는 것이 좋습니다.

---

## 2. 프로젝트 접근 권한을 확인할 수 있는 방법 (권장 순서)

### 방법 A: changePageTreeList 진입 시 검사 (가장 권장)

- **위치:** `changePageTreeList` **맨 앞**에서, `changedPage`를 호출하기 전에 한 번만 검사.
- **방법:**  
  `apiService.fetchProject(documentState.rxProjectId.value)` 호출 후  
  `result?.statusCode == 403` 이면 **접근 거부**로 간주.
- **장점:**
  - 페이지 클릭/새 페이지 이동 **모든 경로**에서 한 곳만 검사하면 됨.
  - 저장(`triggerUpdatePageContent`)이나 `editor.load` 전에 막을 수 있어, 불필요한 요청을 줄일 수 있음.
- **필요한 것:**  
  403일 때 **EasyLoading + 홈 이동**을 수행할 수단.  
  (예: 콜백 `onProjectAccessDenied`를 VulcanEditor에서 넘기거나, `Get.find<GoRouter>()` + `EasyLoading.showInfo`)

### 방법 B: changedPage 진입 시 검사

- **위치:** `changedPage` **시작** 부분(저장/URL 생성 전).
- **방법:** 위와 동일하게 `fetchProject(projectId)` 후 403이면 접근 거부 처리 후 `return`.
- **장점:** 실제 페이지 전환 로직 진입 전에 한 번 더 막을 수 있음.  
**단점:** `changePageTreeList`에서 이미 검사했다면 중복 호출이 됨. 한 곳만 검사할 거라면 A를 쓰는 편이 낫습니다.

### 방법 C: isPermission() 전에 “접근 가능 여부”만 검사

- **위치:** `changedPage` 안에서 **`isPermission()` 호출 전**에,  
  “이 프로젝트에 접근 가능한지”만 검사하는 API 한 번 호출.
- **방법:**  
  `fetchProject(projectId)` 또는 `checkUserPermission(projectId)` 사용.  
  403이면 접근 거부 처리 후 `return`하고, **`isPermission()`은 호출하지 않음**.
- **의미:**  
  `isPermission()`은 “공유 목록에 있어서 편집 가능한지”만 담당하게 하고,  
  “접근 자체가 허용되는지”는 이 전단계에서만 검사.

### 방법 D: editor.load 이후 (이미 구현됨)

- **현재:** 403 응답 시 iframe 쪽에서 `postMessage` → VulcanEditor에서 EasyLoading + 홈 이동.
- **역할:** **사전 검사(A/B/C)를 하지 못했을 때**의 마지막 방어선.
- **추가 검사**를 넣으면, 권한이 바뀐 직후 페이지 전환 시 **더 빨리** 막고 같은 UX(팝업 + 홈)를 줄 수 있습니다.

---

## 3. 정리

- **순서대로 보면:**  
  `호출부(2곳)` → `changePageTreeList` → `changedPage` → (저장) → **`isPermission()`** → **`editor.load()`**.
- **접근 권한 확인이 가능한 지점:**
  - **가장 적합한 곳:** `changePageTreeList` **진입 시** `fetchProject(projectId)` 로 403 여부 확인 후, 403이면 EasyLoading + 홈 이동하고 `changedPage`를 호출하지 않음.
  - 대안: `changedPage` 진입 직후 또는 `isPermission()` 직전에 같은 검사 추가.
- **이미 있는 것:**  
  `isPermission()`은 “편집 권한(공유 목록 포함 여부)”만 확인하고,  
  `editor.load()` 이후 403은 postMessage로 이미 처리 중입니다.

이 흐름을 기준으로, **changePageTreeList 호출 과정**에서 프로젝트 접근 권한을 검증하려면 **방법 A**를 적용하는 것을 추천합니다.

---

## 4. 적용된 구현 (방법 A)

- **위치:** `VulcanEditorController.changePageTreeList` 진입 시.
- **동작:**
  1. `documentState.rxProjectId`로 `apiService.fetchProject(projectId)` 호출.
  2. `result?.statusCode == 403`이면 `onProjectAccessDenied` 콜백 호출 후 `return` (페이지 전환 없음).
  3. 그 외에는 기존처럼 `changedPage(pageData)` 호출.
- **콜백:** `VulcanEditor`에서 `controller.onProjectAccessDenied = () { _showUnauthorizedDialog(context); }` 로 등록하여, 403 시 기존과 동일하게 EasyLoading + 홈 이동 처리.
