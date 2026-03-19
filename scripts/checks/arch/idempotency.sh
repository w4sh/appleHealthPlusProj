#!/bin/bash
# INV-3: 幂等性检查
# 验证重复执行产生相同结果

set -e

echo "=== 检查幂等性 ==="

# 幂等性测试需要在实际运行时验证
# 这里只是提醒,实际验证需要在集成测试中进行

if [ ! -d "tests/integration" ]; then
    echo "⚠️  警告: 缺少幂等性集成测试"
    echo "建议: 在 tests/integration/ 中添加幂等性测试"
    exit 1
fi

# 检查是否有幂等性测试
if find tests/integration/ -name "*idempot*" -o -name "*idempotent*" 2>/dev/null | grep -q .; then
    echo "✅ 发现有幂等性测试"
    exit 0
else
    echo "⚠️  警告: 未发现幂等性测试"
    exit 1
fi
