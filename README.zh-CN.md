# FastCut

[English](README.md) · **简体中文** · [日本語](README.ja.md) · [한국어](README.ko.md)

一款原生、轻量的 **macOS 剪贴板历史管理器** —— 类似 Maccy / Flycut 的极简替代品。常驻菜单栏,
记住你复制过的内容,一个全局快捷键即可唤回历史。

**🌐 [官网](https://7757.github.io/FastCut/) · ⬇️ [下载](https://github.com/7757/FastCut/releases/latest)**

![FastCut 剪贴板弹窗](docs/popup.png)

## ⚡ 安装

**一行命令安装** —— 自动下载最新版、装入 `/应用程序` 并启动:

```sh
curl -fsSL https://7757.github.io/FastCut/install.sh | bash
```

**Homebrew:**

```sh
brew install --cask 7757/fastcut/fastcut
```

**手动安装** —— 从 [Releases](https://github.com/7757/FastCut/releases/latest) 下载最新 `.app`,拖入
`/应用程序`,首次打开请 **右键 → 打开**(应用为自签名,未经过公证)。

**从源码构建** —— 见下方 [构建](#构建)。

## 功能

- **剪贴板历史**:文本、图片、复制的文件路径
- **全局快捷键**(默认 **⌘⇧V**)唤起可搜索的历史弹窗 —— 可在偏好设置里**自定义**
- **键盘全操作**:输入即搜索,`↑`/`↓` 移动,`↩` 粘贴,`⌘⇧⌫` 删除,`⎋` 关闭
- **自动回贴**:直接粘回你刚才所在的应用(需辅助功能权限)
- **菜单栏快捷访问**最近 8 条
- **隐私优先**:自动忽略密码管理器标记的敏感/临时内容
- **持久保存**;历史条数可调;可选**开机自启**
- **自动更新检查**:有新版本时在菜单栏提示
- 仅菜单栏(无 Dock 图标),零第三方依赖

## 系统要求

- macOS 14 或更高(在 macOS 26、Apple Silicon 上构建与测试)
- Xcode 命令行工具(`xcode-select --install`)—— 无需完整 Xcode

## 构建

```sh
./build.sh
```

用 `swiftc` 编译 Swift 源码,组装出 `FastCut.app` 并签名。

> **小贴士 —— 让辅助功能授权在重新编译后不失效。** 默认使用 **ad-hoc** 签名,其身份每次编译都会变,
> 于是 macOS 每次都要你重新授权。运行一次 `Assets/setup-signing.sh` 生成一个稳定的自签名身份后,
> `build.sh` 会自动用它签名,授权便会一直保留。(证书仅本机使用,无安全价值。)

## 运行

```sh
open FastCut.app
```

或把 `FastCut.app` 拖进 `/应用程序` 从那里启动(推荐,这样授权更稳定)。菜单栏会出现一个闪电图标,
在任意界面按 **⌘⇧V** 即可唤起历史。

### 权限

- **读取剪贴板**和**全局快捷键**无需任何权限。
- **自动回贴**通过模拟 ⌘V 实现,需要**辅助功能**权限:
  系统设置 → 隐私与安全性 → 辅助功能 → 打开 **FastCut**。
  未授权时,选中条目只会复制到剪贴板,你可手动粘贴。

## 卸载

从菜单栏退出,删除 `FastCut.app`,并移除 `~/Library/Application Support/FastCut/`。

## 参与贡献

欢迎提 Issue 和 PR。整个应用是纯 Swift、用 `swiftc` 编译 —— 没有 Xcode 工程、没有依赖,
`./build.sh` 就是全部。

## 许可证

[MIT](LICENSE) © 2026 musk
