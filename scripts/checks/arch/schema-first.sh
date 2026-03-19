#!/bin/bash
# INV-2: Schema 优先检查
# 验证数据模型从 Schema 定义

set -e

echo "=== 检查 Schema 优先 ==="

# 检查是否有 schemas 目录
if [ ! -d "schemas" ]; then
    echo "⚠️  警告: schemas 目录不存在"
    echo "提示: 创建 schemas/ 目录定义数据模型"
    exit 1
fi

# 检查是否有 schema 文件
SCHEMA_FILES=$(find schemas/ -name "*.json" -o -name "*.yaml" -o -name "*.py" 2>/dev/null | wc -l)

if [ "$SCHEMA_FILES" -eq 0 ]; then
    echo "⚠️  警告: 未发现 schema 文件"
    exit 1
fi

echo "✅ 发现 $SCHEMA_FILES 个 schema 文件"

# 如果有 src 目录,检查是否使用 schema
if [ -d "src" ]; then
    # 检查是否有从 schema 导入
    if grep -r "from.*models.*import\|from.*schema.*import" src/ >/dev/null 2>&1; then
        echo "✅ 代码从 Schema 导入"
        exit 0
    else
        echo "⚠️  警告: 代码未从 Schema 导入"
        exit 1
    fi
else
    echo "⚠️  src 目录不存在"
    exit 0
fi
