# FastCut

[English](README.md) · [简体中文](README.zh-CN.md) · [日本語](README.ja.md) · **한국어**

[![Release](https://img.shields.io/github/v/release/7757/FastCut?color=ff8a2b&label=release)](https://github.com/7757/FastCut/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/7757/FastCut/total?color=ff8a2b&label=downloads)](https://github.com/7757/FastCut/releases)
[![License](https://img.shields.io/github/license/7757/FastCut?color=ff8a2b)](LICENSE)

가볍고 네이티브한 **macOS 클립보드 기록 관리자** — Maccy / Flycut 같은 도구의 군더더기 없는 대안입니다.
메뉴 막대에 상주하며 복사한 내용을 기억하고, 전역 단축키로 기록을 다시 불러옵니다.

**🌐 [웹사이트](https://7757.github.io/FastCut/) · ⬇️ [다운로드](https://github.com/7757/FastCut/releases/latest)**

![FastCut 클립보드 팝업](docs/popup.png)

## ⚡ 설치

**한 줄 설치** — 최신 릴리스를 내려받아 `/Applications`에 설치하고 실행합니다:

```sh
curl -fsSL https://7757.github.io/FastCut/install.sh | bash
```

**Homebrew:**

```sh
brew install --cask 7757/fastcut/fastcut
```

**수동 설치** — [Releases](https://github.com/7757/FastCut/releases/latest)에서 최신 `.app`을 받아
`/Applications`로 옮기고, 처음 실행 시 **오른쪽 클릭 → 열기**(자체 서명, 공증 안 됨).

**소스에서 빌드** — 아래 [빌드](#빌드) 참고.

## 기능

- **클립보드 기록**: 텍스트, 이미지, 복사한 파일 경로
- **전역 단축키**(기본 **⌘⇧V**)로 검색 가능한 기록 팝업 — 환경설정에서 **사용자 지정** 가능
- **키보드 중심**: 입력으로 검색, `↑`/`↓` 이동, `↩` 붙여넣기, `⌘⇧⌫` 삭제, `⎋` 닫기
- **자동 붙여넣기**: 방금 쓰던 앱에 바로 붙여넣기(손쉬운 사용 권한 필요)
- **메뉴 막대**에서 최근 8개 항목 빠른 접근
- **개인정보 우선**: 비밀번호 관리자가 표시한 민감/임시 항목은 자동 무시
- **영구 저장**; 기록 개수 조절 가능; **로그인 시 시작**(선택)
- **자동 업데이트 확인**: 새 버전이 있으면 메뉴 막대에 알림
- 메뉴 막대 전용(Dock 아이콘 없음), 서드파티 의존성 없음

## 요구 사항

- macOS 14 이상 (macOS 26, Apple Silicon에서 빌드/테스트)
- Xcode Command Line Tools (`xcode-select --install`) — 전체 Xcode 불필요

## 빌드

```sh
./build.sh
```

`swiftc`로 Swift 소스를 컴파일하여 `FastCut.app`을 만들고 코드 서명합니다.

> **팁 — 재빌드 후에도 손쉬운 사용 권한 유지하기.** 기본은 **ad-hoc** 서명이라 빌드마다 식별자가 바뀌어
> macOS가 매번 다시 권한을 요구합니다. `Assets/setup-signing.sh`를 한 번 실행해 안정적인 자체 서명 ID를
> 만들면 `build.sh`가 자동으로 그것으로 서명하고 권한이 유지됩니다. (인증서는 로컬 전용, 보안적 가치 없음.)

## 실행

```sh
open FastCut.app
```

또는 `FastCut.app`을 `/Applications`에 넣고 거기서 실행(권장). 메뉴 막대에 번개 아이콘이 나타나며,
어디서든 **⌘⇧V**로 기록을 엽니다.

### 권한

- **클립보드 읽기**와 **전역 단축키**는 권한이 필요 없습니다.
- **자동 붙여넣기**는 ⌘V를 시뮬레이션하므로 **손쉬운 사용** 권한이 필요합니다:
  시스템 설정 → 개인정보 보호 및 보안 → 손쉬운 사용 → **FastCut** 켜기.
  권한 전에는 항목을 선택하면 클립보드에만 복사되어 수동으로 붙여넣을 수 있습니다.

## 제거

메뉴 막대에서 종료하고 `FastCut.app`을 삭제한 뒤 `~/Library/Application Support/FastCut/`를 제거합니다.

## 기여

이슈와 PR을 환영합니다. 앱 전체가 순수 Swift이며 `swiftc`로 컴파일됩니다 —
Xcode 프로젝트도 의존성도 없어 `./build.sh` 하나면 충분합니다.

## 라이선스

[MIT](LICENSE) © 2026 musk
