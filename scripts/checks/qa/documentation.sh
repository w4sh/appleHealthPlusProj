#!/bin/bash
# 文档完整性检查
# 验证公共接口有文档字符串

set -e

echo "=== 检查文档完整性 ==="

if [ ! -d "src" ]; then
    echo "⚠️  警告: src 目录不存在"
    exit 0
fi

# 检查公共函数是否有文档字符串
PUBLIC_FUNCTIONS=$(grep -r "^def [a-z_]" src/ --include="*.py" | grep -v "def _" | wc -l)

if [ "$PUBLIC_FUNCTIONS" -eq 0 ]; then
    echo "⚠️  警告: 未发现公共函数"
    exit 0
fi

# 统计有文档字符串的函数
DOCSTRINGS=$(grep -r '"""' src/ --include="*.py" | wc -l)

echo "公共函数: $PUBLIC_FUNCTIONS"
echo "文档字符串: $DOCSTRINGS"

# 简单启发式: 文档字符串应该 >= 函数数量 / 2
if [ "$DOCSTRINGS" -ge "$((PUBLIC_FUNCTIONS / 2))" ]; then
    echo "✅ 文档覆盖率良好"
    exit 0
else
    echo "⚠️  警告: 文档覆盖率较低"
    echo "建议为公共函数添加文档字符串"
    exit 0
fi
