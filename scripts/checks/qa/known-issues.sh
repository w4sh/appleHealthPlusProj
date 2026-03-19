#!/bin/bash
# 已知问题检查
# 验证无未修复的严重问题

set -e

echo "=== 检查已知问题 ==="

# 检查 known-issues.md 是否存在
if [ ! -f "harness/docs/qa/known-issues.md" ]; then
    echo "⚠️  警告: known-issues.md 不存在"
    exit 0
fi

# 检查是否有 Critical 或 Open 的 High 严重级别问题
if grep -E "Critical.*Open|High.*Open" harness/docs/qa/known-issues.md >/dev/null 2>&1; then
    echo "❌ 发现有未修复的严重问题:"
    grep -E "ISSUE-.*:|严重级别.*Critical|严重级别.*High" harness/docs/qa/known-issues.md | head -10
    exit 1
else
    echo "✅ 无未修复的严重问题"
    exit 0
fi
