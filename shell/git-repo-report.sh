#!/usr/bin/env bash

set -e

echo "========================================"
echo " Git Repository Analysis Report"
echo "========================================"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "ERROR: 当前目录不是 Git 仓库"
    exit 1
fi

echo
echo "Repository:"
git rev-parse --show-toplevel

echo
echo "========================================"
echo "1. 最近一年修改最多的文件 Top 20"
echo "========================================"
git --no-pager log --format=format: --name-only --since="1 year ago" \
    | sort \
    | uniq -c \
    | sort -nr \
    | head -20

echo
echo "========================================"
echo "2. Commit 作者贡献统计（排除 merge）"
echo "========================================"
git --no-pager shortlog -sn --no-merges

echo
echo "========================================"
echo "3. Fix/Bug/Broken 相关提交涉及文件 Top 20"
echo "========================================"
git --no-pager log -i -E \
    --grep="fix|bug|broken" \
    --name-only \
    --format="" \
    | sort \
    | uniq -c \
    | sort -nr \
    | head -20

echo
echo "========================================"
echo "4. 最近提交月份分布"
echo "========================================"
git --no-pager log --format="%ad" --date=format:"%Y-%m" \
    | sort \
    | uniq -c \
    | sort -k2

echo
echo "========================================"
echo "5. Revert/Hotfix/Emergency/Rollback 提交"
echo "========================================"
git --no-pager log --oneline --since="1 year ago" \
    | grep -iE "revert|hotfix|emergency|rollback" \
    || echo "未发现相关提交"

echo
echo "========================================"
echo " Analysis Finished"
echo "========================================"
