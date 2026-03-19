# 常见陷阱

## XML 解析陷阱

### PIT-1: 内存溢出
**问题**: Apple Health export.xml 可能很大 (>100MB),使用 `ET.parse()` 会全部加载到内存

**错误做法**:
```python
tree = ET.parse("export.xml")  # ❌ 可能 OOM
root = tree.getroot()
```

**正确做法**:
```python
for event, elem in ET.iterparse("export.xml"):  # ✅ 流式处理
    if elem.tag == "Record":
        process_record(elem)
        elem.clear()
```

**检测**:
- 监控内存使用: `ps aux | grep python`
- 脚本: `scripts/checks/code/memory-usage.sh`

---

### PIT-2: 时区处理
**问题**: Apple Health 时间戳包含时区信息,忽略会导致数据错误

**错误做法**:
```python
dt = datetime.fromisoformat("2026-03-19 10:30:00 +0800")  # ❌ 可能失败
```

**正确做法**:
```python
from datetime import datetime, timezone
from dateutil import parser

dt = parser.parse("2026-03-19 10:30:00 +0800")  # ✅ 自动处理时区
dt_utc = dt.astimezone(timezone.utc)  # 统一转为 UTC
```

**检测**:
- 脚本: `scripts/checks/code/timezone-check.sh`
- 检查所有时间字段是否有时区信息

---

## GPX 解析陷阱

### PIT-3: 精度丢失
**问题**: 经纬度使用 float 存储可能损失精度

**错误做法**:
```python
lat = float(point.attrib["lat"])  # ❌ 精度丢失
```

**正确做法**:
```python
from decimal import Decimal

lat = Decimal(point.attrib["lat"])  # ✅ 保持精度
# 或使用字符串直到计算时再转换
```

**检测**:
- 单元测试验证坐标精度
- 脚本: `scripts/checks/code/coordinate-precision.sh`

---

### PIT-4: 空间数据量过大
**问题**: GPX 点密度过高,处理缓慢

**优化策略**:
- 根据用途采样 (简化轨迹)
- 空间索引 (R-tree)
- 分片处理

---

## 数据验证陷阱

### PIT-5: 假设数据完整性
**问题**: 假设所有字段都存在,实际可能缺失

**错误做法**:
```python
value = record["value"]  # ❌ KeyError if missing
```

**正确做法**:
```python
value = record.get("value")  # ✅ 返回 None
# 或使用 Pydantic
from pydantic import BaseModel, Field

class Record(BaseModel):
    value: Optional[float] = None  # ✅ 明确可选
```

**检测**:
- 测试用例包含缺失字段
- Schema 明确标注 required/optional

---

### PIT-6: 数据类型不一致
**问题**: Apple Health 同一字段可能在不同版本使用不同类型

**示例**:
- `stepCount` 可能是 int 或 string
- `distance` 可能是公里或英里

**正确做法**:
```python
def safe_int(value: Any) -> Optional[int]:
    """Safely convert to int."""
    if isinstance(value, int):
        return value
    if isinstance(value, str):
        return int(value.strip())
    return None
```

---

## 存储陷阱

### PIT-7: 并发写入冲突
**问题**: 多个进程同时写入导致数据损坏

**正确做法**:
- 文件锁: `fcntl.flock()` 或 `portalocker`
- 原子写入: 先写临时文件,再 rename
```python
import tempfile
import os

tmp_file = tempfile.NamedTemporaryFile(delete=False)
try:
    process_data(tmp_file)
    os.replace(tmp_file.name, output_file)  # ✅ 原子操作
finally:
    if os.path.exists(tmp_file.name):
        os.unlink(tmp_file.name)
```

**检测**:
- 并发测试: 多进程同时运行
- 脚本: `scripts/checks/code/concurrency-safe.sh`

---

### PIT-8: 数据库锁定
**问题**: SQLite 长事务导致锁定

**正确做法**:
- 短事务: 快速提交
- WAL 模式: 允许并发读
```python
conn.execute("PRAGMA journal_mode=WAL")
conn.execute("PRAGMA busy_timeout=5000")
```

---

## 性能陷阱

### PIT-9: N+1 查询
**问题**: 在循环中执行查询

**错误做法**:
```python
for record in records:  # ❌ N 次查询
    metadata = db.query(f"SELECT * FROM meta WHERE id={record.id}")
```

**正确做法**:
```python
ids = [r.id for r in records]
metadata = db.query(f"SELECT * FROM meta WHERE id IN ({','.join(ids)})")  # ✅ 1 次查询
```

---

### PIT-10: 过早优化
**问题**: 在性能测试前优化

**正确做法**:
1. 先实现正确逻辑
2. 性能测试确定瓶颈
3. 针对性优化
4. 验证优化效果

---

## 可维护性陷阱

### PIT-11: 硬编码路径
**问题**: 路径写死在不同环境失效

**错误做法**:
```python
file = open("/Users/w4sh8899/data/export.xml")  # ❌
```

**正确做法**:
```python
from pathlib import Path

BASE_DIR = Path(__file__).parent.parent
RAW_DIR = BASE_DIR / "raw"
file = RAW_DIR / "export.xml"  # ✅ 相对路径
```

**检测**:
- 脚本: `scripts/checks/code/hardcoded-paths.sh`
- 正则: `['"]/Users/|['"]/home/`

---

### PIT-12: 忽略错误处理
**问题**: 异常被吞掉,掩盖真实问题

**错误做法**:
```python
try:
    process()
except:
    pass  # ❌ 静默失败
```

**正确做法**:
```python
try:
    process()
except SpecificError as e:
    logger.error("Processing failed", exc_info=True)
    raise  # ✅ 记录并重新抛出
```

---

## 新陷阱发现流程

1. 遇到问题 → 记录到本文档
2. 重复出现 → 升级为 Invariant
3. 创建检测脚本
4. 添加到 policy.yaml
