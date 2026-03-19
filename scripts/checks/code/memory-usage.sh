#!/bin/bash
# 内存使用检查
# 验证大文件处理内存合理

set -e

echo "=== 检查内存使用模式 ==="

if [ ! -d "src" ]; then
    echo "⚠️  src 目录不存在"
    exit 0
fi

# 检查是否使用了流式处理 (iterparse)
if grep -r "iterparse\|streaming\|chunk" src/ 2>/dev/null | grep -q .; then
    echo "✅ 发现场式处理模式"
    exit 0
fi

# 检查是否使用 ET.parse (可能导致 OOM)
if grep -r "ET.parse\|ElementTree.*parse" src/ 2>/dev/null | grep -v "\.pyc" | grep -q .; then
    echo "⚠️  警告: 发现 ET.parse,可能导致大文件 OOM"
    echo "建议: 使用 ET.iterparse 进行流式处理"
    exit 1
fi

echo "⚠️  未发现明确的内存优化模式"
exit 0
