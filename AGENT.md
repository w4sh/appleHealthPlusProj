# Apple Health Plus

AI-agent navigable project using Harness Engineering OS

## 快速导航

### 核心文档
- **工作流程** → `harness/workflow.md`
- **产品概述** → `harness/docs/pm/product-overview.md`

### 架构文档
- **不变性** → `harness/docs/arch/invariants.md` ⚠️ 必读
- **边界定义** → `harness/docs/arch/boundaries.md`

### 开发指南
- **开发规范** → `harness/docs/rd/dev-conventions.md`
- **常见陷阱** → `harness/docs/rd/pitfalls.md`

### 质量保证
- **质量清单** → `harness/docs/qa/quality-checklist.md`
- **已知问题** → `harness/docs/qa/known-issues.md`

### 任务执行
- **任务模式** → `harness/tasks/task-schema.md`
- **运行时** → `harness/runtime/dispatcher.md`

### 角色定义
- **产品经理** → `harness/roles/product-manager.md`
- **开发者** → `harness/roles/coder.md`
- **架构师** → `harness/roles/architect.md`
- **QA** → `harness/roles/qa.md`

## 质量门禁

```bash
# 运行所有检查
bash scripts/lint-all.sh

# 计算质量评分
bash scripts/score.sh
```

## 任务执行流程

1. 定义任务 (参考 `harness/tasks/task-schema.md`)
2. 分发到角色 (参考 `harness/runtime/dispatcher.md`)
3. 加载约束 (始终先读 `harness/docs/arch/invariants.md`)
4. 执行任务
5. 运行检查 (`bash scripts/lint-all.sh`)
6. 计算评分 (`bash scripts/score.sh`)
7. 迭代优化