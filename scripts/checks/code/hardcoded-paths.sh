#!/bin/bash
# 检查硬编码路径
# 查找源代码中的硬编码绝对路径

set -e

echo "=== 检查硬编码路径 ==="

if [ ! -d "src" ]; then
    echo "⚠️  警告: src 目录不存在"
    exit 0
fi

# 查找常见的硬编码路径模式
PATTERNS=(
    '["'"'"']/Users/'
    '["'"'"']/home/'
    '["'"'"']/var/'
    '["'"'"']/tmp/'
    'r"["'"'"'][/Users/'
    'r"["'"'"'][/home/'
)

HAS_VIOLATIONS=0

for pattern in "${PATTERNS[@]}"; do
    if grep -r "$pattern" src/ 2>/dev/null | grep -v "\.sha256" | grep -v "Binary" > /dev/null; then
        echo "❌ 发现硬编码路径:"
        grep -rn "$pattern" src/ 2>/dev/null | grep -v "\.sha256" | grep -v "Binary" | head -5
        HAS_VIOLATIONS=1
    fi
done

if [ $HAS_VIOLATIONS -eq 0 ]; then
    echo "✅ 未发现硬编码路径"
    exit 0
else
    echo ""
    echo "请使用 pathlib.Path 和相对路径"
    exit 1
fi
