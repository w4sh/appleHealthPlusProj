#!/bin/bash
# 代码格式检查
# 验证代码格式符合 black

set -e

echo "=== 检查代码格式 ==="

# 检查是否有 black
if ! command -v black &> /dev/null; then
    echo "⚠️  警告: black 未安装"
    echo "请运行: pip install black"
    exit 1
fi

# 如果有 src 或 tests 目录,检查格式
if [ -d "src" ] || [ -d "tests" ]; then
    echo "检查代码格式..."
    OUTPUT=$(black --check src/ tests/ 2>&1 || true)

    if [ -z "$OUTPUT" ]; then
        echo "✅ 代码格式符合 black"
        exit 0
    else
        echo "❌ 代码格式不符合 black"
        echo "运行 'black src/ tests/' 修复"
        exit 1
    fi
else
    echo "⚠️  警告: 源代码目录不存在"
    exit 0
fi
