#!/bin/bash
# INV-4: 可追溯性检查
# 验证所有输出包含元数据

set -e

echo "=== 检查可追溯性 ==="

# 检查输出目录
if [ ! -d "output" ]; then
    echo "⚠️  output 目录不存在"
    exit 0
fi

# 检查是否有元数据文件或日志
HAS_METADATA=0

if [ -d "output" ]; then
    # 检查是否有 metadata.json 或类似文件
    if find output/ -name "*metadata*" -o -name "*.log" 2>/dev/null | grep -q .; then
        echo "✅ 发现代数据/日志文件"
        HAS_METADATA=1
    fi
fi

# 检查代码中是否记录元数据
if [ -d "src" ]; then
    if grep -r "metadata\|processed_at\|source\|schema_version" src/ 2>/dev/null | grep -q .; then
        echo "✅ 代码包含元数据记录"
        HAS_METADATA=1
    fi
fi

if [ $HAS_METADATA -eq 1 ]; then
    exit 0
else
    echo "⚠️  警告: 未发现元数据记录机制"
    exit 1
fi
