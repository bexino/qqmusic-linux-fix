[![QuickStart](https://img.shields.io/badge/快速-开始-orange)](#快速开始)
[![Commit Activity](https://img.shields.io/github/commit-activity/t/bexino/qqmusic-linux-fix?color=green)](https://github.com/bexino/qqmusic-linux-fix/commits/main/)
[![License](https://img.shields.io/github/license/bexino/qqmusic-linux-fix?color=blue)](https://github.com/bexino/qqmusic-linux-fix/blob/main/LICENSE)
[![MadeWith♥](https://img.shields.io/badge/@bexino-Made_With_♥-purple)](https://github.com/bexino)
[![ViewInGithub](https://img.shields.io/badge/Github-bexino%2Fqqmusic__linux__fix-white?logo=github&logoColor=auto&labelColor=555555&color=ffffff)](https://github.com/bexino/qqmusic-linux-fix/)

# qqmusic-linux-fix

修复 Flatpak 版 QQ 音乐：

- 中文显示为方框，
- 不能显示托盘，

---

## 快速开始

不要使用 sudo，直接在终端运行：  


```bash
bash -c 'set -Eeuo pipefail; (( EUID != 0 )) || { printf "%s\n" "错误：请以当前桌面用户运行，不要在命令前加 sudo。" >&2; exit 1; }; command -v curl >/dev/null 2>&1 || { printf "%s\n" "错误：未找到 curl。" >&2; exit 1; }; tmp_file=$(mktemp "${TMPDIR:-/tmp}/qqmusic-linux-fix.XXXXXX"); trap '\''rm -f "$tmp_file"'\'' EXIT HUP INT TERM; curl --proto "=https" --tlsv1.2 -fsSL "https://raw.githubusercontent.com/bexino/qqmusic-linux-fix/main/fix.sh" -o "$tmp_file"; bash "$tmp_file"'
```
  

> [!Caution]
> 脚本会拒绝 sudo 运行，因为使用 `sudo` 会误写到 `root` 账户。

---

## 适用于

理论适用全部于 GNU/Linux，  

> [!Note]
> 在 Fedora Workstation 44 GNOME + Wayland 测试通过。

---

## 注意

> [!TIP]
> - GNOME 用户建议提前启用扩展：[AppIndicator and KStatusNotifierItem Support](https://extensions.gnome.org/extension/615/appindicator-support/)。
> 
>   现代 GNOME在默认情况下，该插件是预置的，直接开启即可。
> 
> 若未安装 GNOME 扩展管理器:
> 
> ```bash
> flatpak install flathub com.mattjakeman.ExtensionManager
> ```

## 许可证

Apache-2.0 license
