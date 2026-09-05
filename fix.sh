#!/usr/bin/env bash

# 修复 Flathub 版 QQ 音乐（com.qq.QQmusic）的中文方框和托盘图标。
# 适用于本机当前的 QQ 音乐 1.1.8 / Electron 8 Flatpak 包。

set -Eeuo pipefail

readonly APP_ID='com.qq.QQmusic'
readonly TRAY_WATCHER='org.kde.StatusNotifierWatcher'
readonly TRAY_ITEM='org.kde.StatusNotifierItem-2-1'
readonly OVERRIDE_FILE="${XDG_DATA_HOME:-${HOME}/.local/share}/flatpak/overrides/${APP_ID}"
readonly BACKUP_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/flatpak/override-backups"

die() {
    printf '错误：%s\n' "$*" >&2
    exit 1
}

command -v flatpak >/dev/null 2>&1 || die '未找到 Flatpak。'
flatpak info "${APP_ID}" >/dev/null 2>&1 || die "尚未安装 Flathub 版 QQ 音乐（${APP_ID}）。"

printf '1/5 关闭正在运行的 QQ 音乐…\n'
if flatpak ps --columns=application | awk -v app="${APP_ID}" '$0 == app { found=1 } END { exit !found }'; then
    flatpak kill "${APP_ID}"
fi

printf '2/5 备份并清理 QQ 音乐原有的 Flatseal 权限…\n'
if [[ -f "${OVERRIDE_FILE}" ]]; then
    mkdir -p "${BACKUP_DIR}"
    cp --preserve=mode,timestamps "${OVERRIDE_FILE}" \
        "${BACKUP_DIR}/${APP_ID}.$(date +%Y%m%d-%H%M%S).conf"
fi
flatpak override --user --reset "${APP_ID}"

printf '3/5 写入托盘所需的精确权限…\n'
flatpak override --user \
    --talk-name="${TRAY_WATCHER}" \
    --own-name="${TRAY_ITEM}" \
    "${APP_ID}"

printf '4/5 清理 QQ 音乐字体缓存并重新建立索引…\n'
flatpak run --command=sh "${APP_ID}" -eu -c '
cache_dir="${XDG_CACHE_HOME}/fontconfig"
if [ -d "${cache_dir}" ]; then
    find "${cache_dir}" -mindepth 1 -delete
fi
fc-cache -f
'

font_match="$({ flatpak run --command=fc-match "${APP_ID}" ':lang=zh-cn'; } 2>/dev/null | head -n 1)"
[[ -n "${font_match}" ]] || die 'QQ 音乐沙箱内未找到可用的中文字体。'
printf '    中文字体：%s\n' "${font_match}"

printf '5/5 重新启动 QQ 音乐…\n'
nohup flatpak run "${APP_ID}" >/dev/null 2>&1 &

tray_ok=0
if command -v busctl >/dev/null 2>&1; then
    for _ in {1..15}; do
        if busctl --user get-property \
            "${TRAY_WATCHER}" /StatusNotifierWatcher \
            org.kde.StatusNotifierWatcher RegisteredStatusNotifierItems \
            2>/dev/null | grep -Fq "${TRAY_ITEM}"; then
            tray_ok=1
            break
        fi
        sleep 1
    done
fi

printf '\n修复完成。QQ 音乐已重新启动。\n'
if (( tray_ok )); then
    printf '中文字体和托盘图标均已通过检查。\n'
else
    printf '字体检查已通过；请观察桌面顶部托盘是否出现 QQ 音乐图标。\n'
fi
printf '旧权限备份目录：%s\n' "${BACKUP_DIR}"
