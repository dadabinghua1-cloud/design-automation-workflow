# 版本历史

## v1.0：流程工程闭环

完成项目创建、项目结构检查、需求检查、两遍确认、物料清单、提示词生成和提示词审核。

## v1.1：出图队列与输出管理

增加 `image_generation_queue.json`、`output_register`、`check_outputs.ps1`、`review_outputs.ps1` 和视觉预览通过状态。

## v1.1-ui：GitHub 仓库与静态可视化 UI

增加：

- GitHub Actions CI。
- GitHub Pages 部署配置。
- `docs/` 静态 UI。
- `scripts/deploy_ui.ps1` 数据刷新脚本。
- 素材、提示词、视觉预览、输出登记、项目队列的页面展示。

## v1.2 计划：正式尺寸确认与 API 自动出图

计划包含：

- 正式尺寸确认流程。
- 批量输出审核。
- 可能接入 OpenAI Images API。
- API 生成图片后自动保存到 `04_outputs/preview/`。
- 自动更新 `output_register`。

## v2.0 计划：Figma / Photoshop 半自动化接入

计划包含：

- Figma 半自动化接入。
- Photoshop 半自动化接入。
- 可编辑文件整理。
- `04_outputs/ps_ready/` 工作流完善。
- 正式交付文件自动检查。
