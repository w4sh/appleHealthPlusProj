#!/bin/bash
# INV-5: 类型安全检查
# 验证使用 Python 类型注解并通过 mypy 检查

set -e

echo "=== 检查类型安全 ==="

# 检查是否有 mypy
if ! command -v mypy &> /dev/null; then
    echo "⚠️  警告: mypy 未安装"
    echo "请运行: pip install mypy"
    exit 1
fi

# 如果有 src 目录,运行类型检查
if [ -d "src" ]; then
    echo "运行 mypy 严格模式检查..."
    if mypy src/ --strict 2>&1 | grep -q "Success"; then
        echo "✅ 类型检查通过"
        exit 0
    else
        echo "❌ 类型检查失败"
        mypy src/ --strict
        exit 1
    fi
else
    echo "⚠️  警告: src 目录不存在"
    echo "项目尚未有源代码"
    exit 0
fi
