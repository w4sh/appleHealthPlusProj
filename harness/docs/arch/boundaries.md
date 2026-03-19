# 架构边界

## 模块划分

```
src/
├── ingestion/      # 数据摄入层
│   ├── parser.py   # XML/GPX 解析
│   └── validator.py # 数据验证
│
├── transformation/ # 数据转换层
│   ├── normalizer.py  # 数据标准化
│   ├── enrichment.py  # 数据增强
│   └── aggregator.py  # 数据聚合
│
├── storage/        # 数据存储层
│   ├── database.py    # 数据库操作
│   └── index.py       # 索引管理
│
├── export/         # 数据导出层
│   ├── formatter.py   # 格式转换
│   └── api.py         # 查询接口
│
└── models/         # 数据模型
    ├── schema.py      # Pydantic 模型
    └── types.py       # 类型定义
```

## 依赖规则

### 单向依赖
```
ingestion → models
transformation → ingestion → models
storage → transformation → models
export → storage → models
```

**禁止**:
- 上层模块依赖下层模块的实现细节
- 跨层级调用 (如 export 直接调用 ingestion)
- 循环依赖

### 接口隔离

每个模块只暴露必要的公共接口:
- `src/ingestion/__init__.py`: 只导出 `parse_export()`, `parse_gpx()`
- `src/transformation/__init__.py`: 只导出 `transform()`, `enrich()`
- 内部函数使用 `_` 前缀标记为私有

## 数据流边界

```
Raw Data (read-only)
    ↓
Ingestion (parse + validate)
    ↓
Structured Data (internal format)
    ↓
Transformation (normalize + enrich)
    ↓
Processed Data (storage format)
    ↓
Storage (persist)
    ↓
Export (format + serve)
    ↓
Consumer
```

**禁止**:
- 跳过验证直接处理原始数据
- 在存储层进行业务逻辑转换
- 在导出层修改数据内容

## 技术栈边界

### 当前使用
- **Python 3.10+**: 核心语言
- **Pydantic**: 数据验证和类型安全
- **Pandas**: 数据处理 (待定)
- **SQLite/PostgreSQL**: 数据存储 (待定)

### 暂不引入
- **Web 框架**: 后续再考虑 FastAPI/Flask
- **前端**: 当前仅 CLI 工具
- **云服务**: 纯本地部署
- **大数据工具**: 数据量小,不需要 Spark/Hadoop

## 外部接口边界

### 输入接口
- Apple Health export.xml (标准格式)
- GPX files (标准格式)

### 输出接口
- Structured files (JSON, CSV, Parquet)
- Python API (函数调用)
- CLI commands (后续)

**不承诺**:
- Apple Health API 实时同步 (超出范围)
- 第三方数据源集成
- 实时数据推送
