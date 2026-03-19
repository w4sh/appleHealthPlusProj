#!/bin/bash
# INV-1: 数据完整性检查
# 验证原始数据未被修改

set -e

echo "=== 检查数据完整性 ==="

# 检查原始文件是否存在
if [ ! -f "raw/export.xml" ]; then
    echo "❌ 错误: raw/export.xml 不存在"
    exit 1
fi

# 检查是否有哈希文件
HASH_FILE=".export.sha256"
if [ -f "$HASH_FILE" ]; then
    echo "检查文件哈希..."
    if sha256sum -c "$HASH_FILE" > /dev/null 2>&1; then
        echo "✅ 原始数据未被修改"
        exit 0
    else
        echo "❌ 错误: 原始数据已被修改!"
        echo "请恢复 raw/export.xml 或更新哈希"
        exit 1
    fi
else
    echo "⚠️  警告: 未找到哈希文件"
    echo "创建新的哈希文件..."
    sha256sum raw/export.xml > "$HASH_FILE"
    echo "✅ 已创建哈希文件"
    exit 0
fi
