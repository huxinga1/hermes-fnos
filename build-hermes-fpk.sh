#!/bin/bash
# Hermes AI Agent fpk 构建脚本
# 用法:
#   ./build-hermes-fpk.sh            # 自动递增 patch 版本号
#   ./build-hermes-fpk.sh 0.2.0      # 指定版本号
#   ./build-hermes-fpk.sh --noinc    # 使用当前版本号，不递增

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# 构建脚本放在源码目录内，所以项目目录就是脚本所在目录
PROJECT_DIR="${SCRIPT_DIR}"
MANIFEST="${PROJECT_DIR}/manifest"
# 输出到源码目录的上级（工作区根目录）
PARENT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
FNPACK="/usr/local/bin/fnpack"

# 彩色输出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Hermes AI Agent fpk 构建脚本${NC}"
echo -e "${BLUE}========================================${NC}"

# ── 读取当前版本 ────────────────────────────────────────────────────────────
CURRENT_VERSION=$(grep "^version" "${MANIFEST}" | awk -F'=' '{print $2}' | tr -d ' ')
echo "当前 manifest 版本: ${CURRENT_VERSION}"

# ── 确定新版本号 ────────────────────────────────────────────────────────────
NEW_VERSION=""
if [ "$1" = "--noinc" ]; then
    NEW_VERSION="${CURRENT_VERSION}"
    echo "模式: 保持当前版本"
elif [ -n "$1" ]; then
    NEW_VERSION="$1"
    echo "模式: 指定版本 ${NEW_VERSION}"
else
    # 自动递增 patch 版本号 (x.y.z → x.y.z+1)
    IFS='.' read -r MAJOR MINOR PATCH <<< "${CURRENT_VERSION}"
    PATCH=$((PATCH + 1))
    NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
    echo "模式: 自动递增 patch → ${NEW_VERSION}"
fi

# ── 更新 manifest ───────────────────────────────────────────────────────────
if [ "${NEW_VERSION}" != "${CURRENT_VERSION}" ]; then
    echo "更新 manifest 版本: ${CURRENT_VERSION} → ${NEW_VERSION}"
    # 使用精确匹配替换版本行
    sed -i "s/^version[[:space:]]*=[[:space:]]*${CURRENT_VERSION}/version               = ${NEW_VERSION}/" "${MANIFEST}"
    CURRENT_VERSION="${NEW_VERSION}"
fi

# ── 获取外部版本信息 ─────────────────────────────────────────────────────────
echo ""
echo "获取上游最新版本信息..."

LATEST_WEBUI=$(curl -sfL --connect-timeout 10 \
    "https://api.github.com/repos/nesquena/hermes-webui/releases/latest" 2>/dev/null | \
    grep '"tag_name"' | head -1 | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/' || echo "")
LATEST_AGENT=$(curl -sfL --connect-timeout 10 \
    "https://api.github.com/repos/NousResearch/hermes-agent/releases/latest" 2>/dev/null | \
    grep '"tag_name"' | head -1 | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/' || echo "")

if [ -n "${LATEST_WEBUI}" ]; then echo "  WebUI: ${LATEST_WEBUI}"; else echo "  WebUI: 获取失败（不影响构建）"; fi
if [ -n "${LATEST_AGENT}" ]; then echo "  Agent: ${LATEST_AGENT}"; else echo "  Agent: 获取失败（不影响构建）"; fi

# ── 修复权限 ────────────────────────────────────────────────────────────────
echo ""
echo "修复文件权限..."
find "${PROJECT_DIR}" -type d -exec chmod 755 {} \;
find "${PROJECT_DIR}" -type f -exec chmod 644 {} \;
chmod +x "${PROJECT_DIR}/cmd/"*

# ── 输出文件名 ──────────────────────────────────────────────────────────────
APPNAME=$(grep "^appname" "${MANIFEST}" | awk -F'=' '{print $2}' | tr -d ' ')
OUTPUT_FPK="${PARENT_DIR}/${APPNAME}-${CURRENT_VERSION}.fpk"

# 如果已存在同名文件，先备份
if [ -f "${OUTPUT_FPK}" ]; then
    echo "备份已存在的文件: ${OUTPUT_FPK} → ${OUTPUT_FPK}.bak"
    mv "${OUTPUT_FPK}" "${OUTPUT_FPK}.bak"
fi

# ── 构建 ────────────────────────────────────────────────────────────────────
echo ""
echo "开始构建 fpk..."
echo "  输出: ${OUTPUT_FPK}"

cd "${PARENT_DIR}"
${FNPACK} build -d "$(basename "${PROJECT_DIR}")"

# ── 重命名输出文件 ─────────────────────────────────────────────────────────
BUILT_FPK="${PARENT_DIR}/$(basename "${PROJECT_DIR}").fpk"
if [ -f "${BUILT_FPK}" ]; then
    mv "${BUILT_FPK}" "${OUTPUT_FPK}"
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  构建成功！${NC}"
    echo -e "${GREEN}  文件: ${OUTPUT_FPK}${NC}"
    ls -lh "${OUTPUT_FPK}"
    echo -e "${GREEN}========================================${NC}"
else
    echo ""
    echo "错误: 构建失败，未找到输出文件"
    exit 1
fi
