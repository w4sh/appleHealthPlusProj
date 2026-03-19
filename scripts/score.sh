#!/bin/bash
# 质量评分计算
# 根据 policy.yaml 计算项目质量评分

set -e

echo "=== 计算质量评分 ==="
echo ""

# 评分权重 (根据 policy.yaml)
ARCH_WEIGHT=40
CODE_WEIGHT=30
QA_WEIGHT=20
DOCS_WEIGHT=10

# 初始化分数
ARCH_SCORE=0
CODE_SCORE=0
QA_SCORE=0
DOCS_SCORE=0

echo "## 架构检查 (权重 $ARCH_WEIGHT%)"
echo "---"

# INV-1: 数据完整性 (10 分)
if [ -f "scripts/checks/arch/data-integrity.sh" ]; then
    if bash scripts/checks/arch/data-integrity.sh >/dev/null 2>&1; then
        echo "✅ 数据完整性: 10/10"
        ARCH_SCORE=$((ARCH_SCORE + 10))
    else
        echo "❌ 数据完整性: 0/10"
    fi
else
    echo "⚠️  数据完整性: 检查脚本未实现"
fi

# INV-2: Schema 优先 (8 分)
if [ -f "scripts/checks/arch/schema-first.sh" ]; then
    if bash scripts/checks/arch/schema-first.sh >/dev/null 2>&1; then
        echo "✅ Schema 优先: 8/8"
        ARCH_SCORE=$((ARCH_SCORE + 8))
    else
        echo "❌ Schema 优先: 0/8"
    fi
else
    echo "⚠️  Schema 优先: 检查脚本未实现"
    ARCH_SCORE=$((ARCH_SCORE + 4))  # 给部分分
fi

# INV-3: 幂等性 (8 分)
if [ -f "scripts/checks/arch/idempotency.sh" ]; then
    if bash scripts/checks/arch/idempotency.sh >/dev/null 2>&1; then
        echo "✅ 幂等性: 8/8"
        ARCH_SCORE=$((ARCH_SCORE + 8))
    else
        echo "❌ 幂等性: 0/8"
    fi
else
    echo "⚠️  幂等性: 检查脚本未实现"
    ARCH_SCORE=$((ARCH_SCORE + 4))
fi

# INV-4: 可追溯性 (7 分)
if [ -f "scripts/checks/arch/traceability.sh" ]; then
    if bash scripts/checks/arch/traceability.sh >/dev/null 2>&1; then
        echo "✅ 可追溯性: 7/7"
        ARCH_SCORE=$((ARCH_SCORE + 7))
    else
        echo "❌ 可追溯性: 0/7"
    fi
else
    echo "⚠️  可追溯性: 检查脚本未实现"
    ARCH_SCORE=$((ARCH_SCORE + 3))
fi

# INV-5: 类型安全 (7 分)
if [ -f "scripts/checks/arch/type-safety.sh" ]; then
    if bash scripts/checks/arch/type-safety.sh >/dev/null 2>&1; then
        echo "✅ 类型安全: 7/7"
        ARCH_SCORE=$((ARCH_SCORE + 7))
    else
        echo "❌ 类型安全: 0/7"
    fi
else
    echo "⚠️  类型安全: 检查脚本未实现"
    ARCH_SCORE=$((ARCH_SCORE + 3))
fi

echo ""
echo "架构小计: $ARCH_SCORE/40"
echo ""

echo "## 代码检查 (权重 $CODE_WEIGHT%)"
echo "---"

# 测试覆盖率 (15 分)
if [ -f "scripts/checks/code/test-coverage.sh" ]; then
    if bash scripts/checks/code/test-coverage.sh >/dev/null 2>&1; then
        echo "✅ 测试覆盖率: 15/15"
        CODE_SCORE=$((CODE_SCORE + 15))
    else
        echo "❌ 测试覆盖率: 0/15"
    fi
else
    echo "⚠️  测试覆盖率: 检查脚本未实现或未达标"
    CODE_SCORE=$((CODE_SCORE + 5))
fi

# 类型检查 (10 分)
if [ -f "scripts/checks/code/type-check.sh" ]; then
    if bash scripts/checks/code/type-check.sh >/dev/null 2>&1; then
        echo "✅ 类型检查: 10/10"
        CODE_SCORE=$((CODE_SCORE + 10))
    else
        echo "❌ 类型检查: 0/10"
    fi
else
    echo "⚠️  类型检查: 检查脚本未实现"
fi

# Lint (8 分)
if [ -f "scripts/checks/code/lint.sh" ]; then
    if bash scripts/checks/code/lint.sh >/dev/null 2>&1; then
        echo "✅ 代码规范: 8/8"
        CODE_SCORE=$((CODE_SCORE + 8))
    else
        echo "❌ 代码规范: 0/8"
    fi
else
    echo "⚠️  代码规范: 检查脚本未实现"
    CODE_SCORE=$((CODE_SCORE + 4))
fi

# 格式检查 (5 分)
if [ -f "scripts/checks/code/format.sh" ]; then
    if bash scripts/checks/code/format.sh >/dev/null 2>&1; then
        echo "✅ 代码格式: 5/5"
        CODE_SCORE=$((CODE_SCORE + 5))
    else
        echo "⚠️  代码格式: 不符合 (可自动修复)"
        CODE_SCORE=$((CODE_SCORE + 2))
    fi
fi

# 硬编码路径 (5 分)
if [ -f "scripts/checks/code/hardcoded-paths.sh" ]; then
    if bash scripts/checks/code/hardcoded-paths.sh >/dev/null 2>&1; then
        echo "✅ 无硬编码路径: 5/5"
        CODE_SCORE=$((CODE_SCORE + 5))
    else
        echo "❌ 发现硬编码路径: 0/5"
    fi
else
    echo "⚠️  硬编码路径: 检查脚本未实现"
    CODE_SCORE=$((CODE_SCORE + 2))
fi

echo ""
echo "代码小计: $CODE_SCORE/30"
echo ""

echo "## QA 检查 (权重 $QA_WEIGHT%)"
echo "---"

# 文档完整性 (5 分)
if [ -f "scripts/checks/qa/documentation.sh" ]; then
    if bash scripts/checks/qa/documentation.sh >/dev/null 2>&1; then
        echo "✅ 文档完整: 5/5"
        QA_SCORE=$((QA_SCORE + 5))
    else
        echo "⚠️  文档: 不完整"
        QA_SCORE=$((QA_SCORE + 2))
    fi
else
    echo "⚠️  文档检查: 检查脚本未实现"
    QA_SCORE=$((QA_SCORE + 2))
fi

# 已知问题 (5 分)
if [ -f "scripts/checks/qa/known-issues.sh" ]; then
    if bash scripts/checks/qa/known-issues.sh >/dev/null 2>&1; then
        echo "✅ 无严重问题: 5/5"
        QA_SCORE=$((QA_SCORE + 5))
    else
        echo "❌ 有未修复的严重问题"
    fi
else
    echo "⚠️  已知问题: 检查脚本未实现"
    QA_SCORE=$((QA_SCORE + 3))
fi

echo ""
echo "QA 小计: $QA_SCORE/10"
echo ""

# 文档评分 (手动评估)
echo "## 文档检查 (权重 $DOCS_WEIGHT%)"
echo "---"

if [ -f "README.md" ]; then
    echo "✅ README 存在"
    DOCS_SCORE=$((DOCS_SCORE + 5))
else
    echo "⚠️  缺少 README"
fi

if [ -d "harness/docs" ]; then
    echo "✅ 架构文档存在"
    DOCS_SCORE=$((DOCS_SCORE + 5))
else
    echo "⚠️  缺少架构文档"
fi

echo ""
echo "文档小计: $DOCS_SCORE/10"
echo ""

# 计算总分
TOTAL_SCORE=$(echo "scale=1; ($ARCH_SCORE * $ARCH_WEIGHT + $CODE_SCORE * $CODE_WEIGHT + $QA_SCORE * $QA_WEIGHT + $DOCS_SCORE * $DOCS_WEIGHT) / 100" | bc)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "总评分: $TOTAL_SCORE/100"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 评级
if (( $(echo "$TOTAL_SCORE >= 90" | bc -l) )); then
    echo "评级: 优秀 ⭐⭐⭐⭐⭐"
elif (( $(echo "$TOTAL_SCORE >= 80" | bc -l) )); then
    echo "评级: 良好 ⭐⭐⭐⭐"
elif (( $(echo "$TOTAL_SCORE >= 70" | bc -l) )); then
    echo "评级: 及格 ⭐⭐⭐"
else
    echo "评级: 不及格 ⭐"
fi

echo ""

# 质量门禁
BASELINE=70.0
if (( $(echo "$TOTAL_SCORE >= $BASELINE" | bc -l) )); then
    echo "✅ 质量门禁通过 (≥ $BASELINE)"
    exit 0
else
    echo "❌ 质量门禁失败 (< $BASELINE)"
    exit 1
fi
