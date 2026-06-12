# Design Automation Workflow 状态总结

## 当前版本

Design Automation Workflow 1.1 + `v1.2-ui-usability-draft`

## 已完成模块

- 项目模板
- 一键创建项目
- 项目结构检查
- 需求检查
- 两遍确认
- 物料清单
- 提示词生成
- 提示词审核
- 小批量测试计划
- 出图队列
- 输出登记
- 预览图保存检查
- 输出审核
- GitHub Pages 静态 UI

## GitHub Pages 静态 UI 状态

GitHub Pages 静态 UI 已完成 1.1 查看型管理台验收，可用于查看项目状态、素材、提示词、视觉预览和输出登记。

当前 UI 只负责展示，不自动上传文件、不自动运行脚本、不自动生成图片、不自动调用 Codex，也不接 Figma / Photoshop。数据刷新仍通过 `scripts/deploy_ui.ps1` 完成。

## v1.2-ui-usability-draft 状态

已进入 UI 可用性优化草稿阶段。此次优化不是完整 v1.2 功能发布，只改善 GitHub Pages 静态 UI 的信息清晰度。

本次补充：

- 当前项目状态区。
- 下一步建议卡片。
- 上传按钮占位说明。
- 视觉预览图的目标尺寸、实际像素、状态和最终交付提示。
- 输出登记表的状态、备注、下一步分列展示。
- 项目队列的已完成 / 待处理状态。
- 当前版本能力说明。

## v1.2-final-size-confirmation-draft 状态

当前进入正式尺寸确认流程草稿阶段。这不是完整自动出图功能，也不调用图片生成 API。

图1、图4、图8 已视觉预览通过，但不是最终交付完成。当前需要确认：

- 是否需要重制。
- 是否需要放大。
- 是否需要进入 PS 处理。
- 是否需要进入 Figma 处理。
- 印刷 / 大尺寸物料是否需要确认 DPI、出血、安全区和实际交付规格。

新增文件：

- `FINAL_SIZE_CONFIRMATION_GUIDE.md`
- `04_outputs/final_size_confirmation.csv`
- `04_outputs/final_size_confirmation.json`
- `scripts/check_final_size.ps1`

## 当前已跑通的真实项目

```text
20260611_真实小项目测试
```

## 当前已视觉测试通过的图片

- 图1：电子水牌
- 图4：云相册三件套3
- 图8：签到背景板

当前状态：

```text
视觉预览通过，待正式尺寸确认
```

## 当前未完成的测试图片

- 图9：云摄影二维码立牌
- 图13：桌号牌

## 当前未解决问题

- ChatGPT 生成图实际像素不一定等于目标尺寸。
- 目前仍需手动保存图片到 preview。
- Codex 暂未接 OpenAI Images API。
- 暂未接 Figma / Photoshop。
- 视觉审核仍需人工判断。

## 下一步建议

- 继续测试图9、图13。
- 或先做正式尺寸确认流程。
- 暂不建议直接批量生成 15 张。
- 暂不建议马上接 Figma / Photoshop。
- UI 先验证静态展示流程，再做视觉优化。
- `v1.2-ui-usability-draft` 完成后，优先考虑正式尺寸确认流程，再考虑 API 自动出图。
- 当前优先完成图1、图4、图8 的正式尺寸决策，再考虑继续出图或 API 自动出图。
