# Apple Health Plus - 工作流

## 执行步骤

1. **定义任务** → 在 `harness/tasks/` 创建任务文件
2. **分发任务** → Runtime 根据任务类型路由到对应角色
3. **加载上下文** → 加载必要的约束和文档
4. **执行任务** → 按角色标准执行
5. **运行检查** → `bash scripts/lint-all.sh`
6. **计算评分** → `bash scripts/score.sh`
7. **迭代优化** → 根据评分决定继续或修复

## 任务路由

| 任务类型 | 负责角色 | 审批角色 |
|----------|----------|----------|
| feature  | coder   | code-reviewer |
| bugfix   | coder   | code-reviewer |
| refactor | architect + coder | architecture-reviewer |

## 约束加载策略

**始终加载**:
- `docs/arch/invariants.md`
- 任务定义文件

**条件加载**:
- 涉及架构变更 → `docs/arch/boundaries.md`
- 编写代码 → `docs/rd/dev-conventions.md`
- 已知问题 → `docs/rd/pitfalls.md`

## 质量门禁

执行完成后必须满足:
- 所有 lint 检查通过
- 质量评分 ≥ 基线分数
- 验收标准全部达成

## 升级机制

触发条件:
- 无法解决约束冲突
- 评分停滞或下降
- 遇到未记录的问题

处理:
- 咨询用户
- 记录到 `docs/qa/known-issues.md`
- 建议不变性更新
