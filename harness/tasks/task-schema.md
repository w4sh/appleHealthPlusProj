# 任务模式定义

## 任务模式 (Schema)

所有任务必须遵循此结构:

### 必需字段

```yaml
id: "TASK-<编号>"
type: "feature" | "bugfix" | "refactor"
title: "简短标题"
description: "详细描述"
input: "输入/前置条件"
output: "输出/交付物"
constraints: "约束条件列表"
acceptance_criteria: "验收标准列表"
affected_modules: "受影响的模块"
priority: "P0" | "P1" | "P2" | "P3"
owner_role: "角色名称"
status: "pending" | "in_progress" | "completed" | "blocked"
created_at: "YYYY-MM-DD"
updated_at: "YYYY-MM-DD"
```

### 字段说明

#### id
- 格式: `TASK-<数字>`
- 唯一标识,不可重复
- 示例: `TASK-001`, `TASK-002`

#### type
- `feature`: 新功能开发
- `bugfix`: 缺陷修复
- `refactor`: 代码重构 (不改变功能)

#### priority
- `P0 (Critical)`: 阻塞性,立即处理
- `P1 (High)`: 重要,本周完成
- `P2 (Medium)`: 普通,本月完成
- `P3 (Low)`: 低优先级,有空再做

#### owner_role
- `coder`: 大多数实现任务
- `architect`: 架构设计任务
- `qa`: 质量验证任务
- `product-manager`: 需求定义任务

## 任务模板

### Feature 任务模板

```markdown
# TASK-<ID>: <标题>

## 元数据
- **类型**: feature
- **优先级**: P1
- **负责人**: coder
- **状态**: pending
- **创建日期**: 2026-03-19

## 用户故事
作为 <角色>, 我想要 <功能>, 以便于 <价值>

## 描述
<详细描述功能需求>

## 输入
- 原始数据: ...
- 依赖模块: ...
- 前置条件: ...

## 输出
- 实现的函数/类: ...
- 测试文件: ...
- 文档更新: ...

## 约束
- 必须遵循 INV-001 (数据完整性)
- 必须遵循 INV-005 (类型安全)
- 性能要求: ...

## 验收标准
- [ ] 可以解析 GPX 文件
- [ ] 提取坐标、时间戳、海拔
- [ ] 单元测试覆盖率 ≥ 80%
- [ ] 通过所有 lint 检查
- [ ] 文档完整

## 受影响的模块
- `src/ingestion/gpx_parser.py` (新增)
- `tests/unit/test_gpx_parser.py` (新增)
- `docs/arch/data-model.md` (更新)

## 技术方案
<如果需要架构决策,引用 ADR>

## 实现计划
1. 创建模块结构
2. 实现 GPX 解析逻辑
3. 编写单元测试
4. 集成到数据管道
5. 更新文档

## 相关任务
- 依赖: TASK-XXX
- 阻塞: TASK-YYY
```

### Bugfix 任务模板

```markdown
# TASK-<ID>: <标题>

## 元数据
- **类型**: bugfix
- **优先级**: P0
- **负责人**: coder
- **状态**: pending

## 问题描述
<描述 Bug 的现象>

## 复现步骤
1.
2.
3.

## 期望行为
<应该发生什么>

## 实际行为
<实际发生了什么>

## 根本原因
<分析根本原因>

## 输入
- Bug 报告/Issue: ...
- 复现数据: ...

## 输出
- 修复的代码: ...
- 回归测试: ...
- 文档更新 (如需要): ...

## 约束
- 不能破坏现有功能
- 必须添加回归测试

## 验收标准
- [ ] Bug 已修复
- [ ] 添加回归测试
- [ ] 所有测试通过
- [ ] 无副作用

## 受影响的模块
- <受影响的文件>

## 修复方案
<简述修复方案>

## 相关任务
- 相关 Issue: ISSUE-XXX
```

### Refactor 任务模板

```markdown
# TASK-<ID>: <标题>

## 元数据
- **类型**: refactor
- **优先级**: P2
- **负责人**: architect + coder
- **状态**: pending

## 重构原因
<为什么要重构>

## 当前问题
<当前代码的问题>

## 目标状态
<重构后应该达到的状态>

## 输入
- 现有代码: ...
- 性能基准: ...
- 已知问题: ...

## 输出
- 重构后的代码: ...
- 性能对比: ...
- 迁移指南 (如破坏性变更): ...

## 约束
- 不能改变外部接口 (除非有 ADR)
- 所有测试必须通过
- 性能不能退化

## 验收标准
- [ ] 代码更清晰
- [ ] 测试 100% 通过
- [ ] 性能未退化
- [ ] 文档已更新

## 受影响的模块
- <受影响的文件>

## 重构方案
<详细的重构方案>

## 回滚计划
<如果出问题如何回滚>

## 相关任务
- 相关 ADR: ADR-XXX
```

## 任务生命周期

```
pending → in_progress → completed
    ↓         ↓           ↑
  blocked  (failed) ────┘
```

### 状态转换规则

- `pending` → `in_progress`: 开始实现
- `in_progress` → `completed`: 验收通过
- `in_progress` → `pending`: 重新排队
- `in_progress` → `blocked`: 遇到阻塞
- `blocked` → `in_progress`: 阻塞解除
- `completed` → `pending`: 验收失败 (罕见)

## 任务质量检查

创建任务时检查:

- [ ] 所有必需字段已填写
- [ ] 验收标准可测试
- [ ] 约束条件明确
- [ ] 受影响模块已识别
- [ ] 依赖关系清晰
- [ ] 优先级合理
