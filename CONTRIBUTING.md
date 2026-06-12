# Contributing

欢迎基于 Design Automation Workflow 继续扩展流程、脚本和静态 UI。

## 修改原则

- 优先保持项目模板稳定。
- 脚本应尽量轻量，不安装额外依赖。
- 真实项目输出图不要默认提交到仓库。
- 图片生成、Figma、Photoshop 接入应放在后续版本中单独设计。

## 推荐检查

修改后建议运行：

```powershell
.\scripts\check_project.ps1 -InputProjectName "20260611_真实小项目测试"
.\scripts\generate_prompts.ps1 -InputProjectName "20260611_真实小项目测试"
.\scripts\check_outputs.ps1 -InputProjectName "20260611_真实小项目测试"
.\scripts\review_outputs.ps1 -InputProjectName "20260611_真实小项目测试"
.\scripts\deploy_ui.ps1 -InputProjectName "20260611_真实小项目测试"
```

## 分支和提交

建议主分支使用 `main`。提交信息保持清晰，例如：

```text
feat: add static github pages ui
docs: update output workflow guide
fix: detect all queued preview outputs
```
