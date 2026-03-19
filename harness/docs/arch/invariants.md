# 架构不变性

> 这些是项目生命周期内不可破坏的规则

## INV-1: 数据完整性

**规则**: 任何数据处理操作必须保留原始数据

**原因**: Apple Health 数据不可重现,一旦丢失无法恢复

**强制措施**:
- 脚本: `scripts/checks/arch/data-integrity.sh`
- 禁止修改 `raw/` 目录下的原始文件
- 所有处理操作必须复制数据到工作目录

**验证方法**:
```bash
# 原始文件哈希检查
sha256sum raw/export.xml > .export.sha256
sha256sum -c .export.sha256
```

---

## INV-2: Schema 优先

**规则**: 数据模型变更必须先更新 Schema,后更新代码

**原因**: 保证数据处理管道各组件之间的契约稳定性

**强制措施**:
- 脚本: `scripts/checks/arch/schema-first.sh`
- Schema 文件: `schemas/` 目录 (待创建)
- 代码必须从 Schema 文件读取结构定义

**验证方法**:
```bash
# Schema 定义必须存在
test -f schemas/health-data.schema.json || exit 1
```

---

## INV-3: 幂等性

**规则**: 所有数据处理操作必须是幂等的

**原因**: 支持重复执行、失败重试、增量更新

**强制措施**:
- 脚本: `scripts/checks/arch/idempotency.sh`
- 每次处理前检查输出状态
- 已处理的数据跳过或覆盖,永不追加

**验证方法**:
```bash
# 多次运行产生相同结果
python scripts/process.py
sha256sum output/processed.parquet
python scripts/process.py
sha256sum output/processed.parquet  # 必须相同
```

---

## INV-4: 可追溯性

**规则**: 每个数据输出必须记录来源和处理时间

**原因**: 问题排查、数据溯源、审计需求

**强制措施**:
- 脚本: `scripts/checks/arch/traceability.sh`
- 所有输出文件包含元数据
- 处理日志记录到 `logs/` 目录

**元数据结构**:
```json
{
  "source": "raw/export.xml",
  "processed_at": "2026-03-19T10:30:00Z",
  "schema_version": "1.0.0",
  "record_count": 123456
}
```

---

## INV-5: 类型安全

**规则**: 所有数据操作必须使用严格类型检查

**原因**: Apple Health 数据类型复杂,类型错误导致数据损坏

**强制措施**:
- 脚本: `scripts/checks/arch/type-safety.sh`
- 使用 Python Type Hints
- 运行时类型验证 (pydantic)

**验证方法**:
```bash
# 类型检查通过
mypy src/ --strict
```

---

## INV-6: 测试覆盖

**规则**: 核心数据处理逻辑必须有单元测试

**原因**: 数据处理逻辑复杂,错误代价高昂

**强制措施**:
- 脚本: `scripts/checks/code/test-coverage.sh`
- 最低覆盖率: 80%
- 关键路径: 100%

**验证方法**:
```bash
pytest --cov=src --cov-fail-under=80
```
