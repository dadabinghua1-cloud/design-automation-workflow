# Design Automation Workflow UI Design Tokens

本 UI 采用 `awesome-design-md` 的设计说明方式：先定义设计原则、令牌和组件行为，再落到静态页面。

## 设计原则

- 清爽、简约、商业化。
- 用清晰状态帮助用户判断下一步。
- 默认暗色优先，同时支持浅色模式。
- 页面用于管理流程，不替代 Figma / Photoshop。

## 色彩

| Token | 用途 |
| --- | --- |
| `--bg` | 页面背景 |
| `--panel` | 面板背景 |
| `--text` | 主文字 |
| `--muted` | 次级文字 |
| `--line` | 分隔线 |
| `--accent` | 主要操作与高亮 |
| `--success` | 通过状态 |
| `--warning` | 待确认状态 |
| `--danger` | 缺失或阻断 |

## 组件

- Topbar：项目名、版本、主题切换。
- Status Card：展示版本、项目、通过数量、待处理数量。
- Data Card：提示词、队列、输出登记等列表。
- Preview Grid：视觉预览缩略图。
- Table：输出登记和队列。

## 交互

- 过滤状态只影响当前页面显示，不写回文件。
- 上传入口是后续能力预留，当前作为目录提示。
- 队列 Notes 编辑 UI 只做前端演示，真正写回仍由脚本或后续 API 完成。
