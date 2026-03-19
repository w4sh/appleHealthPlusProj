#!/bin/bash
# INV-6: 测试覆盖率检查
# 验证核心逻辑有足够的测试覆盖

set -e

echo "=== 检查测试覆盖率 ==="

# 检查是否有测试目录
if [ ! -d "tests" ]; then
    echo "⚠️  警告: 测试目录不存在"
    echo "测试覆盖率: 0%"
    exit 1
fi

# 检查是否有 pytest
if ! command -v pytest &> /dev/null; then
    echo "⚠️  警告: pytest 未安装"
    echo "请运行: pip install pytest pytest-cov"
    exit 1
fi

# 如果有 src 目录,运行覆盖率测试
if [ -d "src" ]; then
    echo "运行测试并计算覆盖率..."
    if pytest --cov=src --cov-fail-under=80 -q; then
        echo "✅ 测试覆盖率 ≥ 80%"
        exit 0
    else
        EXIT_CODE=$?
        echo "❌ 测试覆盖率 < 80%"
        exit $EXIT_CODE
    fi
else
    echo "⚠️  警告: src 目录不存在"
    echo "项目尚未有源代码"
    exit 0
fi
