<p align="center">
  <a href="../../README.md"><img alt="English" src="https://img.shields.io/badge/English-3A3A3C?style=for-the-badge"></a>
  <a href="./ar.md"><img alt="Arabic" src="https://img.shields.io/badge/%D8%A7%D9%84%D8%B9%D8%B1%D8%A8%D9%8A%D8%A9-3A3A3C?style=for-the-badge"></a>
  <a href="./es.md"><img alt="Spanish" src="https://img.shields.io/badge/Espa%C3%B1ol-3A3A3C?style=for-the-badge"></a>
  <a href="./fr.md"><img alt="French" src="https://img.shields.io/badge/Fran%C3%A7ais-3A3A3C?style=for-the-badge"></a>
  <a href="./de.md"><img alt="German" src="https://img.shields.io/badge/Deutsch-3A3A3C?style=for-the-badge"></a>
  <a href="./pt.md"><img alt="Portuguese" src="https://img.shields.io/badge/Portugu%C3%AAs-3A3A3C?style=for-the-badge"></a>
  <a href="./tr.md"><img alt="Turkish" src="https://img.shields.io/badge/T%C3%BCrk%C3%A7e-3A3A3C?style=for-the-badge"></a>
  <a href="./zh.md"><img alt="Chinese" src="https://img.shields.io/badge/%E4%B8%AD%E6%96%87-3A3A3C?style=for-the-badge"></a>
  <a href="./ja.md"><img alt="Japanese" src="https://img.shields.io/badge/%E6%97%A5%E6%9C%AC%E8%AA%9E-3A3A3C?style=for-the-badge"></a>
  <a href="./ko.md"><img alt="Korean" src="https://img.shields.io/badge/%ED%95%9C%EA%B5%AD%EC%96%B4-0A84FF?style=for-the-badge"></a>
</p>

# Banish

**앱, 그리고 그 앱이 남긴 모든 것.**

앱을 휴지통으로 끌어다 놓으면 아이콘만 사라집니다. 환경설정, 캐시, 컨테이너, 로그, 로그인 항목은 라이브러리에 남습니다. 공간을 계속 차지하고, 다시 설치하면 돌아옵니다.

Banish는 그 파일을 찾고, 무엇이든 옮기기 전에 보여 준 다음, 고른 것만 휴지통으로 보냅니다. 모든 항목은 되돌릴 수 있습니다. 영원히 지워지지 않습니다.

<p><img src="../images/library.png" alt="Banish에 나온 설치된 앱" width="920"></p>

## 화면에 나오는 것

사이드바는 설치된 앱을 버전과 크기와 함께 보여 줍니다. 초록 점은 실행 중이라는 뜻입니다. 검색은 이름이나 `com.google.Chrome` 같은 번들 ID를 받습니다.

앱을 고르면 숫자 세 개가 나옵니다. 앱 자체의 크기, 관련 파일의 크기, 그리고 실제로 선택되어 휴지통으로 갈 크기입니다.

**관련 파일**은 번들 ID로 맞추며 처음부터 선택되어 있습니다. **이름 일치**는 이름만 같으므로, 경로를 보기 전에는 선택되지 않습니다.

<p><img src="../images/detail.png" alt="Banish에서 연 Chrome과 관련 파일" width="920"></p>

## 확인하기 전에는 아무것도 움직이지 않습니다

**Move to Trash**는 개수와 크기가 있는 확인 시트를 엽니다. 옮기기 버튼은 기본 버튼이 아니라서 Return으로 실수 확인되지 않습니다.

`/Applications` 안의 앱은 macOS 소유이고, 보통의 이동은 거부됩니다. 시트는 암호가 필요할 수 있다고 알려 줍니다. 확인한 뒤 macOS가 한 번 묻고, Banish가 선택한 항목을 휴지통으로 옮깁니다.

<p><img src="../images/confirm.png" alt="Chrome을 휴지통으로 옮기기 전의 확인" width="920"></p>

암호 창을 취소하면 이동이 멈춥니다. 움직이지 않은 것은 그대로 있습니다. 휴지통에 들어간 것은 되돌릴 수 있습니다.

## 어디를 보나

Banish는 디스크 전체를 훑지 않습니다. 알려진 라이브러리 폴더만, 한두 단계 깊이로 봅니다. 환경설정, Application Support, 캐시, 로그, 컨테이너, ID가 맞을 때의 웹 데이터, 로그인 항목, 저장된 상태입니다.

강한 일치는 번들 ID를 씁니다. `com.foo.app`는 `com.foo.application`이나 `com.foo.app2`를 가져가지 않습니다. `Google/Chrome`은 Chrome의 것일 수 있습니다. `Google/Earth`는 단어 하나가 같다고 해서 그렇지 않습니다.

## 건드리지 않는 것

`/System`, `/usr`, `/bin`, `/private` 같은 시스템 위치. 문서, 데스크탑, 다운로드, 사진, 음악. Mail, 메시지, 사진, Safari, 키체인, 캘린더, 메모. `~/.ssh`, 그리고 삭제 원본으로서의 휴지통. 심볼릭 링크. 그리고 실행 중인 Banish. 앱은 자기 자신을 옮길 수 없습니다.

Finder, Safari, Mail 같은 핵심 Apple 앱은 잠겨 있습니다. Keynote, Pages, Numbers 같은 선택형 Apple 앱은 분명한 경고와 함께 지울 수 있습니다. 시스템 앱은 처음에 숨겨져 있고, 보기 메뉴나 설정에서 꺼낼 수 있습니다.

## 권한

**관리자 암호**는 macOS가 응용 프로그램 폴더 밖으로 앱을 옮기는 것을 거부할 때만 묻습니다. 대화상자는 시스템 대화상자이고, 이름은 Banish입니다.

**전체 디스크 접근**은 선택 사항입니다. macOS가 숨기는 컨테이너와 캐시를 읽게 합니다. 없어도 목록은 동작하고, 폴더를 읽지 못하면 배너가 나타납니다.

시스템 설정 → 개인정보 보호 및 보안 → 전체 디스크 접근

## 앱 안의 언어

창은 Mac의 언어를 따릅니다. 아랍어는 오른쪽에서 왼쪽입니다. 설정에서 아랍어나 영어로 고정할 수 있습니다.

<p><img src="../images/settings.png" alt="Banish 설정" width="540"></p>

## 빌드

macOS 14 이상과 Swift 6. 외부 라이브러리는 없습니다.

```bash
./Scripts/build-app.sh
open build/Banish.app
```

또는 `make app` 다음 `make run`. 테스트는 `make test`입니다. 서명된 앱은 `build/Banish.app`에 있습니다.
