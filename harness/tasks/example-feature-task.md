# TASK-001: 实现 Apple Health XML Parser

## 元数据
- **类型**: feature
- **优先级**: P1
- **负责人**: coder
- **状态**: pending
- **创建日期**: 2026-03-19
- **预计完成**: 2026-03-26

## 用户故事
作为 个人用户,我想要解析 Apple Health export.xml,以便于将健康数据转换为结构化格式进行分析。

## 描述

实现 Apple Health export.xml 的解析器,提取关键健康记录类型:
- 活动记录 (Steps, Distance, Flights Climbed)
- 心率数据 (Heart Rate)
- 睡眠分析 (Sleep Analysis)
- 体重记录 (Weight)
- 锻炼记录 (Workout)

### 技术要求

1. **流式解析**: 使用 `xml.etree.ElementTree.iterparse` 避免内存溢出
2. **Schema 定义**: 使用 Pydantic 定义数据模型
3. **类型安全**: 严格的类型注解,mypy 检查通过
4. **错误处理**: 优雅处理损坏的 XML 和缺失字段

## 输入

**前置条件**:
- 原始数据: `raw/export.xml` 存在
- 依赖模块: `src/models/schema.py` 已定义

**参考文档**:
- `harness/docs/arch/invariants.md` - INV-1, INV-5, INV-6
- `harness/docs/rd/dev-conventions.md` - 开发规范
- `harness/docs/rd/pitfalls.md` - PIT-1, PIT-5, PIT-6

## 输出

**交付物**:
1. `src/ingestion/parser.py` - XML 解析实现
2. `src/models/schema.py` - Pydantic 数据模型
3. `tests/unit/test_parser.py` - 单元测试
4. `tests/fixtures/sample_export.xml` - 测试数据

**文档更新**:
- `README.md` - 添加使用说明
- (如有需要) 更新架构文档

## 约束

### 必须遵守的不变性

- **INV-1**: 数据完整性 - 不修改 `raw/export.xml`
- **INV-2**: Schema 优先 - 先定义 Pydantic 模型
- **INV-5**: 类型安全 - 使用 Type Hints
- **INV-6**: 测试覆盖 - 核心逻辑覆盖率 ≥ 80%

### 技术约束

- 使用 `xml.etree.ElementTree.iterparse` 流式处理
- 所有公共函数必须有类型注解
- 所有公共函数必须有文档字符串
- 使用 `pathlib.Path` 处理文件路径
- 时区统一转换为 UTC

### 性能约束

- 处理 100MB XML 文件内存 < 1GB
- 处理时间 < 2 分钟

## 验收标准

- [ ] **AC-1**: 可以解析 Apple Health export.xml
- [ ] **AC-2**: 提取至少 5 种记录类型
- [ ] **AC-3**: 单元测试覆盖率 ≥ 80%
- [ ] **AC-4**: `mypy src/ --strict` 通过
- [ ] **AC-5**: `bash scripts/lint-all.sh` 全部通过
- [ ] **AC-6**: `bash scripts/score.sh` 评分 ≥ 70
- [ ] **AC-7**: 文档字符串完整
- [ ] **AC-8**: 通过已知的陷阱检查 (PIT-1, PIT-5, PIT-6)

## 受影响的模块

**新增**:
- `src/ingestion/__init__.py`
- `src/ingestion/parser.py`
- `src/models/__init__.py`
- `src/models/schema.py`
- `tests/unit/test_parser.py`
- `tests/fixtures/sample_export.xml`

**更新**:
- `README.md`

## 实现计划

### Phase 1: Schema 设计 (1 天)
1. 分析 Apple Health XML 结构
2. 定义 Pydantic 模型
3. 编写 Schema 测试

### Phase 2: Parser 实现 (2 天)
1. 实现 XML 流式解析
2. 实现记录提取逻辑
3. 实现错误处理
4. 编写单元测试

### Phase 3: 集成和优化 (1 天)
1. 性能测试和优化
2. 完善错误处理
3. 文档完善
4. 质量检查

### Phase 4: 验证 (1 天)
1. 运行完整测试套件
2. 运行 lint 检查
3. 计算质量评分
4. 修复问题

## 相关任务

- **依赖**: 无 (这是第一个任务)
- **阻塞**: TASK-002 (数据转换层)
- **相关**: TASK-003 (GPX Parser)

## 技术方案

### Pydantic Schema 结构

```python
from datetime import datetime
from typing import Optional, Literal
from pydantic import BaseModel, Field

class HealthRecord(BaseModel):
    """基础健康记录. """
    type: str
    value: float
    unit: str
    source_name: str
    start_date: datetime
    end_date: Optional[datetime] = None

    class Config:
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }

class StepRecord(HealthRecord):
    """步数记录. """
    type: Literal["StepCount"] = "StepCount"

class HeartRateRecord(HealthRecord):
    """心率记录. """
    type: Literal["HeartRate"] = "HeartRate"
```

### Parser 接口

```python
def parse_export(file_path: Path) -> list[HealthRecord]:
    """解析 Apple Health export.xml.

    Args:
        file_path: XML 文件路径

    Returns:
        健康记录列表

    Raises:
        ParsingError: XML 格式错误
        ValidationError: 数据验证失败
    """
    ...
```

## 质量目标

- 测试覆盖率: ≥ 85%
- mypy 检查: 通过
- pylint 评分: ≥ 8.0
- 质量评分: ≥ 75

---

**创建人**: System
**审批状态**: 待审批
