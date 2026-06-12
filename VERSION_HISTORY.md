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

## v1.2-ui-usability-draft：UI 可用性优化草稿

这是 UI 可用性优化，不是完整 v1.2 功能发布。

优化内容：

- 增加当前项目状态区。
- 增加下一步建议卡片。
- 明确上传按钮只是占位。
- 优化视觉预览区，显示图号、物料名称、状态、实际像素、目标尺寸和是否最终交付。
- 优化输出登记表，拆分状态、审核备注和下一步动作。
- 优化项目队列，区分已完成和待处理。
- 增加当前版本能力说明。

仍不包含：

- OpenAI Images API。
- 网页上传。
- 自动生成图片。
- 自动保存图片。
- Figma / Photoshop 接入。

## v1.2-final-size-confirmation-draft：正式尺寸确认流程草稿

这是正式尺寸确认流程草稿，不是完整自动出图功能。

新增内容：

- 正式尺寸确认指南。
- `final_size_confirmation.csv`。
- `final_size_confirmation.json`。
- `check_final_size.ps1`。
- `final_size_check_report.md`。

目标：

- 区分视觉预览图和最终交付图。
- 记录图1、图4、图8 的目标尺寸和当前像素。
- 判断是否达到最终生产尺寸。
- 给出重制、放大、PS 处理、Figma 处理或印刷规格确认建议。

仍不包含：

- 自动生成图片。
- 自动放大图片。
- OpenAI Images API。
- Figma / Photoshop 自动化。

## v1.2-next-action-panel-draft：下一步指令生成器草稿

这是“下一步指令生成器”草稿，用于减少用户来回询问和复制成本，但还不是自动执行系统。

新增内容：

- `nextAction` 静态数据结构。
- GitHub Pages 页面中的 Next Action 指令面板。
- 推荐动作、推荐原因、暂不建议事项展示。
- 可复制给 Codex 的指令文本框。
- 复制指令按钮。
- `NEXT_ACTION_PANEL_GUIDE.md`。

仍不包含：

- 自动运行 Codex。
- 后台写入。
- GitHub Actions 自动触发。
- OpenAI Images API。
- Figma / Photoshop 接入。

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
