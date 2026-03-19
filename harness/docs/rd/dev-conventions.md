# 开发规范

## 代码风格

### Python 遵循 PEP 8
```bash
# 格式化工具
black src/ tests/
isort src/ tests/

# Lint 工具
pylint src/ tests/
flake8 src/ tests/
```

### 类型注解
- 所有公共函数必须有类型注解
- 使用 `mypy --strict` 检查
```python
def parse_export(file_path: Path) -> HealthData:
    """Parse Apple Health export XML."""
    ...
```

### 文档字符串
- Google 风格或 NumPy 风格
- 所有公共模块、类、函数必须有文档
```python
def calculate_pace(distance_km: float, duration_min: float) -> float:
    """Calculate running pace in min/km.

    Args:
        distance_km: Distance in kilometers
        duration_min: Duration in minutes

    Returns:
        Pace in minutes per kilometer

    Raises:
        ValueError: If distance is zero or negative
    """
    ...
```

## 项目结构约定

### 导入顺序
```python
# 1. 标准库
import xml.etree.ElementTree as ET
from datetime import datetime
from pathlib import Path

# 2. 第三方库
import pydantic
from gpxparser import GPXParser

# 3. 本地模块
from src.models.schema import HealthData
from src.ingestion.parser import parse_export
```

### 配置管理
- 环境变量: 使用 `.env` 文件
- 配置对象: 使用 Pydantic Settings
```python
from pydantic import BaseSettings

class Config(BaseSettings):
    raw_data_dir: Path = Path("raw")
    output_dir: Path = Path("output")
    log_level: str = "INFO"

    class Config:
        env_file = ".env"
```

### 日志规范
```python
import logging

logger = logging.getLogger(__name__)

# 使用结构化日志
logger.info("Processing export file", extra={"file": str(file_path), "size": file_size})
logger.error("Failed to parse XML", exc_info=True)
```

## 测试规范

### 测试组织
```
tests/
├── unit/           # 单元测试
│   ├── test_parser.py
│   └── test_transform.py
├── integration/    # 集成测试
│   └── test_pipeline.py
└── fixtures/       # 测试数据
    ├── sample_export.xml
    └── sample_route.gpx
```

### 命名约定
- 测试文件: `test_<module>.py`
- 测试函数: `test_<function>_<scenario>`
```python
def test_parse_export_success():
    """Test successful export parsing."""
    ...

def test_parse_export_invalid_xml_raises_error():
    """Test parsing invalid XML raises error."""
    ...
```

### Fixture 使用
```python
import pytest

@pytest.fixture
def sample_export():
    """Load sample Apple Health export."""
    return Path("tests/fixtures/sample_export.xml")

def test_parse_export(sample_export):
    result = parse_export(sample_export)
    assert len(result.records) > 0
```

## 错误处理

### 自定义异常
```python
class HealthDataError(Exception):
    """Base exception for health data processing."""

class ParsingError(HealthDataError):
    """Raised when parsing fails."""

class ValidationError(HealthDataError):
    """Raised when validation fails."""
```

### 异常处理策略
```python
# 不要捕获所有异常
try:
    data = parse_export(file)
except Exception:  # ❌ 错误
    pass

# 明确捕获特定异常
try:
    data = parse_export(file)
except ParsingError as e:
    logger.error("Parse failed", exc_info=True)
    raise
```

## 性能考虑

### 大文件处理
- 使用流式处理,不一次性加载全部内容
```python
import xml.etree.ElementTree as ET

for event, elem in ET.iterparse(source):
    if elem.tag == "Record":
        process_record(elem)
        elem.clear()  # 释放内存
```

### 缓存策略
- 中间结果缓存到 `cache/` 目录
- 使用文件哈希作为缓存键
```python
cache_key = hashlib.md5(str(file_path).encode()).hexdigest()
cache_file = cache_dir / f"{cache_key}.pkl"
```

## Git 约定

### Commit 消息
```
<type>(<scope>): <subject>

<body>

<footer>
```

类型:
- `feat`: 新功能
- `fix`: Bug 修复
- `refactor`: 重构
- `docs`: 文档更新
- `test`: 测试相关
- `chore`: 构建/工具

示例:
```
feat(ingestion): add GPX route parser

Implement parser for workout route files.
Extracts coordinates, elevation, and timestamps.

Closes #12
```

### Branch 命名
- `feature/ingestion-gpx`
- `fix/transform-date-parse`
- `refactor/schema-v2`
