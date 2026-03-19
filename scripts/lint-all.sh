#!/bin/bash
# 运行所有质量检查
# Harness Engineering OS - 质量门禁

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Harness Engineering OS - 检查"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

FAILED=0

# 架构检查
echo "## 架构检查"
echo "---"
for check in scripts/checks/arch/*.sh; do
    if [ -f "$check" ]; then
        echo "运行: $(basename $check)"
        if bash "$check" >/dev/null 2>&1; then
            echo "✅ 通过"
        else
            echo "❌ 失败"
            FAILED=1
        fi
    fi
done
echo ""

# 代码检查
echo "## 代码检查"
echo "---"
for check in scripts/checks/code/*.sh; do
    if [ -f "$check" ]; then
        echo "运行: $(basename $check)"
        if bash "$check" >/dev/null 2>&1; then
            echo "✅ 通过"
        else
            echo "❌ 失败"
            FAILED=1
        fi
    fi
done
echo ""

# QA 检查
echo "## QA 检查"
echo "---"
for check in scripts/checks/qa/*.sh; do
    if [ -f "$check" ]; then
        echo "运行: $(basename $check)"
        if bash "$check" >/dev/null 2>&1; then
            echo "✅ 通过"
        else
            echo "❌ 失败"
            FAILED=1
        fi
    fi
done
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $FAILED -eq 0 ]; then
    echo "✅ 所有检查通过"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 0
else
    echo "❌ 部分检查失败"
    echo "运行 'bash scripts/score.sh' 查看详细评分"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 1
fi