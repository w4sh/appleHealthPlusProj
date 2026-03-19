# Apple Health Plus

基于 Harness Engineering OS 的个人 Apple Health 数据处理管道。

## 项目概述

这是一个**数据处理管道**项目,用于解析、转换、存储和查询 Apple Health 导出数据。

- **原始数据**: Apple Health `export.xml` 和 GPX 运动路线
- **技术栈**: Python + Web (未来)
- **使用场景**: 个人健康数据分析和趋势追踪

## 快速开始

### 前置要求

```bash
# Python 3.10+
python --version

# Git
git --version
```

### 初始化开发环境

```bash
# 1. 创建虚拟环境
python -m venv .venv
source .venv/bin/activate  # Linux/macOS
# .venv\Scripts\activate   # Windows

# 2. 安装依赖 (依赖文件待创建)
# pip install -r requirements.txt

# 3. 运行质量检查
bash scripts/lint-all.sh
bash scripts/score.sh
```

## Harness Engineering OS

本项目使用 **Harness Engineering OS** 进行工程化管理,确保代码质量和可维护性。

### 核心原则

1. **Agents have no memory** → 仓库是唯一的真实来源
2. **Do not instruct** → 通过结构化文档引导发现
3. **Do not rely on review** → 通过机械化约束强制
4. **Do not assume** → 定义明确的任务契约

### 文档导航

从 `AGENT.md` 开始,它提供了完整的文档导航。

### 质量门禁

所有代码变更必须通过质量门禁:

```bash
# 运行所有检查
bash scripts/lint-all.sh

# 计算质量评分 (70分及格)
bash scripts/score.sh
```

### 架构不变性

项目有 6 个核心不变性 (Invariants),必须严格遵守:

1. **INV-1**: 数据完整性 - 原始数据不可修改
2. **INV-2**: Schema 优先 - 数据模型先于代码
3. **INV-3**: 幂等性 - 重复执行产生相同结果
4. **INV-4**: 可追溯性 - 所有输出包含元数据
5. **INV-5**: 类型安全 - 严格类型检查
6. **INV-6**: 测试覆盖 - 核心逻辑必须有测试

详见: `harness/docs/arch/invariants.md`

## 项目结构

```
.
├── AGENT.md              # AI 导航入口
├── README.md             # 项目说明 (本文件)
├── SKILL.md              # Harness OS 定义
│
├── harness/              # Harness Engineering 系统
│   ├── workflow.md       # 工作流程
│   ├── docs/            # 知识库
│   │   ├── arch/        # 架构文档
│   │   ├── pm/          # 产品文档
│   │   ├── rd/          # 开发文档
│   │   └── qa/          # QA 文档
│   ├── roles/           # 角色定义
│   ├── tasks/           # 任务模式
│   └── runtime/         # 运行时规范
│
├── scripts/             # 工具脚本
│   ├── lint-all.sh      # 运行所有检查
│   ├── score.sh         # 计算质量评分
│   ├── checks/          # 具体检查脚本
│   └── policy/          # 质量策略定义
│
├── raw/                 # 原始数据 (只读)
│   ├── export.xml       # Apple Health 导出
│   └── workout-routes/  # GPX 运动路线
│
├── src/                 # 源代码 (待创建)
│   ├── ingestion/       # 数据摄入层
│   ├── transformation/  # 数据转换层
│   ├── storage/         # 数据存储层
│   └── export/          # 数据导出层
│
└── tests/               # 测试 (待创建)
    ├── unit/            # 单元测试
    └── integration/     # 集成测试
```

## 开发工作流

### 1. 定义任务

根据 `harness/tasks/task-schema.md` 创建任务文档。

### 2. 执行任务

参考 `harness/runtime/dispatcher.md`:

```bash
# 1. 加载上下文
cat harness/docs/arch/invariants.md

# 2. 执行任务
# (编码、测试...)

# 3. 运行检查
bash scripts/lint-all.sh

# 4. 查看评分
bash scripts/score.sh

# 5. 迭代优化
# (根据评分结果)
```

### 3. 质量验证

使用 `harness/docs/qa/quality-checklist.md` 进行自我验证。

### 4. 完成

确保:
- ✅ 所有检查通过
- ✅ 质量评分 ≥ 70
- ✅ 验收标准全部满足
- ✅ 文档已更新

## 常见陷阱

开发前请阅读 `harness/docs/rd/pitfalls.md`,避免常见错误:

- XML 解析内存溢出
- 时区处理错误
- 精度丢失
- 硬编码路径
- ...

## 当前状态

- ✅ Harness Engineering OS 已初始化
- ✅ 架构文档已完成
- ✅ 质量检查脚本已就绪
- ⏳ 数据模型设计 (进行中)
- ⏳ XML 解析实现 (待开始)

## 下一步

1. **设计数据模型** - 定义 Health Data Schema
2. **实现 XML 解析** - 解析 Apple Health export.xml
3. **实现 GPX 解析** - 解析运动路线
4. **建立存储层** - 选择数据库并实现存储
5. **实现导出功能** - 支持多种格式导出

## 贡献

这是一个个人项目,但欢迎参考 Harness Engineering OS 的方法。

## 许可证

MIT

---

**Harness Engineering OS v1.0** | 使项目可导航、约束驱动、自我改进
