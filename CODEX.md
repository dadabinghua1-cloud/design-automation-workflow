# Codex 协作说明

本仓库用于维护 Design Automation Workflow。Codex 在当前阶段负责流程文件、脚本、静态 UI 和文档维护，不负责直接生成最终设计图。

## 执行顺序

1. 创建或复制真实项目。
2. 放入主 KV、PPT、参考图、Logo 和可选尺寸表。
3. 运行项目结构检查。
4. 做需求检查和两遍确认。
5. 更新物料清单。
6. 生成单物料提示词。
7. 审核提示词。
8. 创建或检查出图队列。
9. 手动保存小批量视觉预览图到 `04_outputs/preview/`。
10. 运行输出保存检查和输出审核。
11. 运行 `scripts/deploy_ui.ps1` 刷新 GitHub Pages 静态数据。

## 当前边界

- 不接 Figma。
- 不接 Photoshop。
- 不自动调用图片生成 API。
- 不安装复杂前端依赖。
- UI 先做静态原型，功能可用优先。

## 提交说明建议

提交信息建议使用：

```text
feat: add static workflow UI
fix: update output review script
docs: update workflow guide
chore: prepare github pages
```

## PR 说明建议

PR 内容建议包含：

- 本次修改了哪些流程文件。
- 是否影响真实项目数据。
- 是否运行了检查脚本。
- GitHub Pages UI 是否已刷新。
