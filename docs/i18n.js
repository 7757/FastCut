/* FastCut site i18n — English / 简体中文 / 日本語 / 한국어 (matches the README languages) */
(function () {
  const I18N = {
    en: {
      nav_features: "Features", nav_shortcuts: "Shortcuts", nav_changelog: "Changelog", nav_download: "Download",
      btn_download: "Download",
      hero_eyebrow: "Open source · Native macOS · MIT",
      hero_h1: 'Your Mac clipboard,<br><span class="gradient-text">at lightning speed</span>',
      hero_sub: "Lives in the menu bar; one hotkey brings your clipboard history back — text, images, links. Search, hit return, paste.<br>Native, lightweight, open source.",
      btn_github_view: "View on GitHub",
      hero_meta: "For macOS 14+ · Apple Silicon · Free",
      feat_kicker: "Features", feat_h2: "Small and fast, just right",
      feat_p: "Everything you need, nothing you don't — the essentials of a clipboard manager and nothing more.",
      feat1_t: "Global hotkey", feat1_d: "Press ⌘⇧V anywhere to open your history; the shortcut is configurable in Preferences.",
      feat2_t: "Smart type detection", feat2_d: "Links, emails, file paths, colors and numbers — each recognized at a glance.",
      feat3_t: "All keyboard", feat3_d: "Type to search, arrows to select, return to paste — hands never leave the keyboard.",
      feat4_t: "Auto-paste", feat4_d: "Picking an item pastes it straight into the app you were using (Accessibility required).",
      feat5_t: "Text · Images · Files", feat5_d: "It remembers whatever you copy — images and copied file paths included.",
      feat6_t: "Privacy first", feat6_d: "Entries marked sensitive by password managers are ignored; history stays on your Mac.",
      feat7_t: "Native & light", feat7_d: "Pure Swift, zero dependencies, lives in the menu bar, barely there.",
      feat8_t: "Open source", feat8_d: "MIT-licensed and fully open — star it, file issues, or fork and hack.",
      kbd_kicker: "Keyboard-driven", kbd_h2: "Hands never leave the keyboard",
      kbd_p: "Summon, search, select, paste, delete — the whole flow works from the keyboard.",
      kbd_summon: "Open history", kbd_select: "Select", kbd_paste: "Paste", kbd_delete: "Delete item", kbd_close: "Close",
      dl_kicker: "Download", dl_h2: "Get FastCut now", dl_p: "Free and open source, ready in seconds.",
      dl_req: "macOS 14+ · Apple Silicon", copy: "Copy", copied: "Copied", dl_or: "or", dl_downloads: "downloads",
      dl_appbtn: "Download .app", dl_source: "Build from source",
      dl_note: "The one-liner downloads, installs and launches automatically. For a manual .app, <strong>right-click → Open</strong> on first launch (self-signed).",
      clog_kicker: "Changelog", clog_h2: "Always improving",
      clog_102_1: "Press ⌘1–⌘9 in the popup to paste the 1st–9th item instantly.",
      clog_101_1: "Update check reads the version from GitHub's redirect instead of the API — no rate limit, more reliable.",
      clog_101_2: "The update-check failure dialog now offers a download link instead of a dead end.",
      clog_100_1: "First release — menu-bar clipboard history opened with a global hotkey.",
      clog_100_2: "Text / images / files with type-aware icons; full keyboard control; auto-paste.",
      clog_100_3: "Ignores passwords; persistence; launch at login; in-app update checks.",
      clog_more: "View full changelog →",
      cta_h2: "Make copy-paste lightning fast.", cta_p: "Free, open source, native. Give your Mac a smarter clipboard.",
      foot_tag: "Native, lightweight, open-source clipboard-history manager for macOS.",
      foot_author: "By musk", foot_product: "Product", foot_source: "Source",
      foot_repo: "Repository", foot_license: "MIT License", foot_copyright: "Open-source under MIT",
    },
    zh: {
      nav_features: "功能", nav_shortcuts: "快捷键", nav_changelog: "更新日志", nav_download: "下载",
      btn_download: "免费下载",
      hero_eyebrow: "开源 · 原生 macOS · MIT 协议",
      hero_h1: '你的 Mac 剪贴板,<br><span class="gradient-text">快如闪电</span>',
      hero_sub: "常驻菜单栏,一个快捷键唤起剪贴板历史 —— 文本、图片、链接,搜一下,回车粘贴。<br>原生、轻量、开源,几乎无感。",
      btn_github_view: "在 GitHub 查看",
      hero_meta: "适用于 macOS 14 或更高 · Apple Silicon · 免费",
      feat_kicker: "功能", feat_h2: "小而快,恰到好处",
      feat_p: "该有的一个不少,多余的一个不加。对标市面主流剪贴板工具,只留最常用的。",
      feat1_t: "全局快捷键", feat1_d: "任意界面按 ⌘⇧V 唤起历史,快捷键可在偏好设置里自定义。",
      feat2_t: "智能类型识别", feat2_d: "链接、邮箱、文件路径、颜色值、数字自动分辨,一眼看清。",
      feat3_t: "键盘全操作", feat3_d: "输入即搜索,方向键选择,回车粘贴 —— 双手不离键盘。",
      feat4_t: "自动回贴", feat4_d: "选中即自动粘回你刚才所在的应用(需辅助功能权限)。",
      feat5_t: "文本 · 图片 · 文件", feat5_d: "复制什么都记得住,图片和复制的文件路径也一并保存。",
      feat6_t: "隐私优先", feat6_d: "自动忽略密码管理器标记的敏感内容,历史只存在你本机。",
      feat7_t: "原生轻量", feat7_d: "纯 Swift 打造,零第三方依赖,常驻菜单栏,几乎不占资源。",
      feat8_t: "开源免费", feat8_d: "MIT 协议,代码完全公开,欢迎 Star、提 Issue 或自己动手改。",
      kbd_kicker: "键盘驱动", kbd_h2: "双手不离键盘",
      kbd_p: "唤起、搜索、选择、粘贴、删除,一整套流程都能用键盘完成。",
      kbd_summon: "唤起历史", kbd_select: "选择", kbd_paste: "粘贴", kbd_delete: "删除该条", kbd_close: "关闭",
      dl_kicker: "下载", dl_h2: "现在就装上 FastCut", dl_p: "免费、开源,几秒钟搞定。",
      dl_req: "macOS 14 或更高 · Apple Silicon", copy: "复制", copied: "已复制", dl_or: "或", dl_downloads: "次下载",
      dl_appbtn: "下载 .app", dl_source: "源码构建",
      dl_note: "一行命令自动下载、安装并启动。手动下载 .app 时,首次打开请<strong>右键 → 打开</strong>(应用为自签名)。",
      clog_kicker: "更新日志", clog_h2: "持续更新中",
      clog_102_1: "在弹窗里按 ⌘1–⌘9 可直接粘贴第 1–9 条。",
      clog_101_1: "更新检查改用 GitHub 重定向解析,不再受 API 速率限制,更稳定。",
      clog_101_2: "检查更新失败时提供「前往下载页」入口,不再是死胡同。",
      clog_100_1: "首个版本:菜单栏剪贴板历史,全局快捷键唤起。",
      clog_100_2: "文本 / 图片 / 文件,按类型区分图标;键盘全操作;自动回贴。",
      clog_100_3: "隐私忽略密码内容;持久化;开机自启;应用内更新检查。",
      clog_more: "查看完整更新日志 →",
      cta_h2: "让复制粘贴,快如闪电。", cta_p: "免费、开源、原生。给你的 Mac 装上更聪明的剪贴板。",
      foot_tag: "原生、轻量、开源的 macOS 剪贴板历史管理器。",
      foot_author: "作者 · musk", foot_product: "产品", foot_source: "源码",
      foot_repo: "GitHub 仓库", foot_license: "MIT 许可证", foot_copyright: "基于 MIT 协议开源",
    },
    ja: {
      nav_features: "機能", nav_shortcuts: "ショートカット", nav_changelog: "変更履歴", nav_download: "ダウンロード",
      btn_download: "無料ダウンロード",
      hero_eyebrow: "オープンソース · ネイティブ macOS · MIT",
      hero_h1: 'あなたの Mac のクリップボードを<br><span class="gradient-text">稲妻の速さで</span>',
      hero_sub: "メニューバーに常駐。ホットキー一つでクリップボード履歴を呼び出し —— テキスト、画像、リンク。検索して Enter で貼り付け。<br>ネイティブ、軽量、オープンソース。",
      btn_github_view: "GitHub で見る",
      hero_meta: "macOS 14 以降 · Apple Silicon · 無料",
      feat_kicker: "機能", feat_h2: "小さくて速い、ちょうどいい",
      feat_p: "必要なものはすべて、余計なものは一切なし。定番クリップボードツールの要点だけ。",
      feat1_t: "グローバルホットキー", feat1_d: "どこでも ⌘⇧V で履歴を表示。ショートカットは設定でカスタマイズ可能。",
      feat2_t: "スマートな種類判別", feat2_d: "リンク、メール、ファイルパス、色、数字を一目で識別。",
      feat3_t: "すべてキーボードで", feat3_d: "入力で検索、矢印で選択、Enter で貼り付け —— 手はキーボードから離れません。",
      feat4_t: "自動貼り付け", feat4_d: "選ぶと直前のアプリへそのまま貼り付け（アクセシビリティ権限が必要）。",
      feat5_t: "テキスト · 画像 · ファイル", feat5_d: "コピーしたものは何でも記憶。画像やファイルパスも。",
      feat6_t: "プライバシー重視", feat6_d: "パスワードマネージャーが機密とした項目は無視。履歴は端末内のみ。",
      feat7_t: "ネイティブで軽量", feat7_d: "純粋な Swift、依存ゼロ、メニューバー常駐でほぼ無負荷。",
      feat8_t: "オープンソース", feat8_d: "MIT ライセンスで全公開。Star・Issue・フォーク歓迎。",
      kbd_kicker: "キーボード操作", kbd_h2: "手はキーボードから離れない",
      kbd_p: "呼び出し、検索、選択、貼り付け、削除 —— すべてキーボードで完結。",
      kbd_summon: "履歴を開く", kbd_select: "選択", kbd_paste: "貼り付け", kbd_delete: "項目を削除", kbd_close: "閉じる",
      dl_kicker: "ダウンロード", dl_h2: "今すぐ FastCut を", dl_p: "無料・オープンソース、数秒で完了。",
      dl_req: "macOS 14 以降 · Apple Silicon", copy: "コピー", copied: "コピー済み", dl_or: "または", dl_downloads: "ダウンロード",
      dl_appbtn: ".app をダウンロード", dl_source: "ソースからビルド",
      dl_note: "ワンライナーが自動でダウンロード・インストール・起動。手動の .app は初回<strong>右クリック → 開く</strong>（自己署名）。",
      clog_kicker: "変更履歴", clog_h2: "継続的に改善中",
      clog_102_1: "ポップアップで ⌘1–⌘9 を押すと 1–9 番目を即座に貼り付け。",
      clog_101_1: "更新確認を API ではなく GitHub のリダイレクトで取得 —— レート制限なしで安定。",
      clog_101_2: "更新確認の失敗時に、ダウンロードページへの導線を追加。",
      clog_100_1: "初回リリース —— メニューバーのクリップボード履歴をホットキーで。",
      clog_100_2: "テキスト/画像/ファイルを種類別アイコンで表示、キーボード操作、自動貼り付け。",
      clog_100_3: "パスワードを無視、永続化、ログイン時起動、アプリ内更新確認。",
      clog_more: "完全な変更履歴を見る →",
      cta_h2: "コピペを、稲妻の速さに。", cta_p: "無料・オープンソース・ネイティブ。あなたの Mac に賢いクリップボードを。",
      foot_tag: "ネイティブで軽量、オープンソースの macOS クリップボード履歴マネージャー。",
      foot_author: "作者 · musk", foot_product: "製品", foot_source: "ソース",
      foot_repo: "リポジトリ", foot_license: "MIT ライセンス", foot_copyright: "MIT ライセンスで公開",
    },
    ko: {
      nav_features: "기능", nav_shortcuts: "단축키", nav_changelog: "변경 이력", nav_download: "다운로드",
      btn_download: "무료 다운로드",
      hero_eyebrow: "오픈소스 · 네이티브 macOS · MIT",
      hero_h1: '당신의 Mac 클립보드를<br><span class="gradient-text">번개처럼 빠르게</span>',
      hero_sub: "메뉴 막대에 상주하며, 단축키 하나로 클립보드 기록을 불러옵니다 —— 텍스트, 이미지, 링크. 검색하고 Enter로 붙여넣기.<br>네이티브, 가볍고, 오픈소스.",
      btn_github_view: "GitHub에서 보기",
      hero_meta: "macOS 14 이상 · Apple Silicon · 무료",
      feat_kicker: "기능", feat_h2: "작고 빠르게, 딱 알맞게",
      feat_p: "필요한 건 다 있고 군더더기는 없습니다. 클립보드 도구의 핵심만.",
      feat1_t: "전역 단축키", feat1_d: "어디서든 ⌘⇧V로 기록을 열고, 환경설정에서 단축키를 지정할 수 있어요.",
      feat2_t: "스마트 타입 인식", feat2_d: "링크·이메일·경로·색상·숫자를 한눈에 구분.",
      feat3_t: "키보드 중심", feat3_d: "입력해 검색, 방향키로 선택, Enter로 붙여넣기 —— 손이 키보드를 떠나지 않아요.",
      feat4_t: "자동 붙여넣기", feat4_d: "선택하면 방금 쓰던 앱에 바로 붙여넣기(손쉬운 사용 권한 필요).",
      feat5_t: "텍스트 · 이미지 · 파일", feat5_d: "복사한 건 무엇이든 기억 —— 이미지와 파일 경로까지.",
      feat6_t: "개인정보 우선", feat6_d: "비밀번호 관리자가 민감 표시한 항목은 무시하고, 기록은 내 Mac에만.",
      feat7_t: "네이티브 & 가벼움", feat7_d: "순수 Swift, 의존성 없음, 메뉴 막대 상주로 거의 무부하.",
      feat8_t: "오픈소스", feat8_d: "MIT 라이선스로 전면 공개 —— Star·이슈·포크 환영.",
      kbd_kicker: "키보드 중심", kbd_h2: "손은 키보드를 떠나지 않아요",
      kbd_p: "호출·검색·선택·붙여넣기·삭제 —— 전 과정을 키보드로.",
      kbd_summon: "기록 열기", kbd_select: "선택", kbd_paste: "붙여넣기", kbd_delete: "항목 삭제", kbd_close: "닫기",
      dl_kicker: "다운로드", dl_h2: "지금 FastCut 설치", dl_p: "무료·오픈소스, 몇 초면 끝.",
      dl_req: "macOS 14 이상 · Apple Silicon", copy: "복사", copied: "복사됨", dl_or: "또는", dl_downloads: "다운로드",
      dl_appbtn: ".app 다운로드", dl_source: "소스 빌드",
      dl_note: "한 줄 명령이 자동으로 내려받아 설치·실행합니다. 수동 .app은 처음에 <strong>오른쪽 클릭 → 열기</strong>(자체 서명).",
      clog_kicker: "변경 이력", clog_h2: "계속 개선 중",
      clog_102_1: "팝업에서 ⌘1–⌘9로 1–9번째 항목을 바로 붙여넣기.",
      clog_101_1: "업데이트 확인을 API 대신 GitHub 리디렉션으로 —— 속도 제한 없이 안정적.",
      clog_101_2: "업데이트 확인 실패 시 다운로드 페이지 링크를 제공합니다.",
      clog_100_1: "첫 릴리스 —— 메뉴 막대 클립보드 기록을 단축키로.",
      clog_100_2: "텍스트/이미지/파일 타입별 아이콘, 키보드 조작, 자동 붙여넣기.",
      clog_100_3: "비밀번호 무시, 영구 저장, 로그인 시 시작, 앱 내 업데이트 확인.",
      clog_more: "전체 변경 이력 보기 →",
      cta_h2: "복사-붙여넣기를, 번개처럼.", cta_p: "무료·오픈소스·네이티브. 당신의 Mac에 더 똑똑한 클립보드를.",
      foot_tag: "네이티브하고 가벼운 오픈소스 macOS 클립보드 기록 관리자.",
      foot_author: "제작 · musk", foot_product: "제품", foot_source: "소스",
      foot_repo: "저장소", foot_license: "MIT 라이선스", foot_copyright: "MIT 라이선스로 공개",
    },
  };

  const LABEL = { en: "English", zh: "中文", ja: "日本語", ko: "한국어" };
  const HTML_LANG = { en: "en", zh: "zh-CN", ja: "ja", ko: "ko" };

  function applyLang(lang) {
    if (!I18N[lang]) lang = "en";
    window.__fcLang = lang;
    document.documentElement.lang = HTML_LANG[lang];
    const dict = I18N[lang];
    document.querySelectorAll("[data-i18n]").forEach((el) => {
      const k = el.getAttribute("data-i18n");
      if (dict[k] != null) el.innerHTML = dict[k];
    });
    const cur = document.getElementById("lang-cur");
    if (cur) cur.textContent = LABEL[lang];
    document.querySelectorAll(".lang-menu [data-lang]").forEach((b) =>
      b.classList.toggle("active", b.getAttribute("data-lang") === lang)
    );
    try { localStorage.setItem("fc_lang", lang); } catch (e) {}
  }

  function detectLang() {
    try { const s = localStorage.getItem("fc_lang"); if (s && I18N[s]) return s; } catch (e) {}
    const n = (navigator.language || "en").toLowerCase();
    if (n.indexOf("zh") === 0) return "zh";
    if (n.indexOf("ja") === 0) return "ja";
    if (n.indexOf("ko") === 0) return "ko";
    return "en";
  }

  window.fcApplyLang = applyLang;   // also usable from the console
  applyLang(detectLang());

  // switcher
  const box = document.getElementById("lang");
  document.querySelectorAll(".lang-menu [data-lang]").forEach((b) =>
    b.addEventListener("click", () => { applyLang(b.getAttribute("data-lang")); if (box) box.classList.remove("open"); })
  );
  const btn = document.querySelector(".lang-btn");
  if (btn) btn.addEventListener("click", (e) => { e.stopPropagation(); if (box) box.classList.toggle("open"); });
  document.addEventListener("click", () => { if (box) box.classList.remove("open"); });

  // copy install command (language-aware button label)
  const copyBtn = document.getElementById("copy-btn");
  if (copyBtn) copyBtn.addEventListener("click", () => {
    const cmd = document.getElementById("install-cmd").textContent;
    navigator.clipboard.writeText(cmd).then(() => {
      const d = I18N[window.__fcLang] || I18N.en;
      copyBtn.textContent = d.copied;
      setTimeout(() => { copyBtn.textContent = d.copy; }, 1500);
    }).catch(() => {});
  });
})();
