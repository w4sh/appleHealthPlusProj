#!/bin/bash
# INV-5: 类型安全检查
# 验证使用严格类型检查

set -e

echo "=== 检查类型安全 ==="

# 此检查与 code/type-check.sh 类似
# 但更侧重于架构层面: 是否使用 Pydantic 等

if [ ! -d "src" ]; then
    echo "⚠️  src 目录不存在"
    exit 0
fi

# 检查是否使用 Pydantic
if grep -r "from pydantic import\|from pydantic import" src/ 2>/dev/null | grep -q .; then
    echo "✅ 使用 Pydantic 进行类型验证"
    exit 0
fi

# 检查是否有类型注解
TYPE_HINTS=$(find src/ -name "*.py" -exec grep -l "def.*->.*:" {} \; 2>/dev/null | wc -l)

if [ "$TYPE_HINTS" -gt 0 ]; then
    echo "✅ 发现类型注解"
    exit 0
else
    echo "⚠️  警告: 未发现类型注解"
    exit 1
fi
