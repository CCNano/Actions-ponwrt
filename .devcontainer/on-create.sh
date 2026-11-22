#!/usr/bin/env bash
set -euo pipefail

SRC_DIR="${PONWRT_SRC:-/workspaces/ponwrt}"
REPO_URL="${PONWRT_REPO:-https://github.com/pbs05/ponwrt}"
REPO_BRANCH="${PONWRT_BRANCH:-master}"
WORKSPACE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ ! -d "$SRC_DIR/.git" ]; then
    echo "==> 克隆 $REPO_URL ($REPO_BRANCH) 到 $SRC_DIR"
    if [ ! -w "$(dirname "$SRC_DIR")" ]; then
        sudo mkdir -p "$SRC_DIR"
        sudo chown "$(id -u):$(id -g)" "$SRC_DIR"
    fi
    git clone --filter=blob:none -b "$REPO_BRANCH" "$REPO_URL" "$SRC_DIR"
else
    echo "==> 源码已存在，跳过克隆：$SRC_DIR"
fi

if [ -f "$WORKSPACE_DIR/feeds.conf.default" ]; then
    cp -f "$WORKSPACE_DIR/feeds.conf.default" "$SRC_DIR/feeds.conf.default"
fi

if [ -d "$WORKSPACE_DIR/files" ]; then
    mkdir -p "$SRC_DIR/files"
    cp -a "$WORKSPACE_DIR/files/." "$SRC_DIR/files/"
fi

cd "$SRC_DIR"

if [ -s "$WORKSPACE_DIR/diy-part1.sh" ]; then
    bash "$WORKSPACE_DIR/diy-part1.sh"
fi

./scripts/feeds update -a
./scripts/feeds install -a

echo "==> 源码与 feeds 已就绪：$SRC_DIR"
