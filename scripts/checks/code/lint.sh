#!/bin/bash
# 代码规范检查
# 运行 pylint 和 flake8

set -e

echo "=== 检查代码规范 ==="

HAS_ERRORS=0

# 运行 pylint
if command -v pylint &> /dev/null; then
    if [ -d "src" ]; then
        echo "运行 pylint..."
        if pylint src/ --fail-under=8.0 -q; then
            echo "✅ pylint 检查通过"
        else
            echo "❌ pylint 检查失败"
            HAS_ERRORS=1
        fi
    fi
else
    echo "⚠️  pylint 未安装,跳过"
fi

# 运行 flake8
if command -v flake8 &> /dev/null; then
    if [ -d "src" ]; then
        echo "运行 flake8..."
        if flake8 src/ --max-line-length=100; then
            echo "✅ flake8 检查通过"
        else
            echo "❌ flake8 检查失败"
            HAS_ERRORS=1
        fi
    fi
else
    echo "⚠️  flake8 未安装,跳过"
fi

if [ $HAS_ERRORS -eq 1 ]; then
    exit 1
fi

exit 0
