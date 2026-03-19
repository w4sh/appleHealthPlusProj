#!/bin/bash
# 导入顺序检查
# 验证导入顺序符合 isort

set -e

echo "=== 检查导入顺序 ==="

# 检查是否有 isort
if ! command -v isort &> /dev/null; then
    echo "⚠️  警告: isort 未安装"
    echo "请运行: pip install isort"
    exit 1
fi

# 如果有 src 或 tests 目录,检查导入顺序
if [ -d "src" ] || [ -d "tests" ]; then
    echo "检查导入顺序..."
    if isort --check-only src/ tests/ 2>&1 | grep -q "ERROR"; then
        echo "❌ 导入顺序不符合 isort"
        echo "运行 'isort src/ tests/' 修复"
        exit 1
    else
        echo "✅ 导入顺序正确"
        exit 0
    fi
else
    echo "⚠️  警告: 源代码目录不存在"
    exit 0
fi
