# Design Automation Workflow 状态总结

## 当前版本

Design Automation Workflow `v1.2-usable-draft-freeze`

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

- 图1：已决策为需要重制到 `1080x1920px`。
- 图4：已决策为需要重制到 `2424x1242px`。
- 图8：已决策为需要确认印刷规格、DPI、出血和安全区。

新增文件：

- `FINAL_SIZE_CONFIRMATION_GUIDE.md`
- `04_outputs/final_size_confirmation.csv`
- `04_outputs/final_size_confirmation.json`
- `scripts/check_final_size.ps1`
- `04_outputs/final_size_decision_report.md`

当前仍不能把图1、图4、图8标记为最终交付完成。图1和图4需要后续重制正式尺寸底图；图8需要先完成印刷规格确认。

## 正式尺寸执行准备状态

已进入正式尺寸执行准备阶段。本阶段只整理执行清单和状态文件，不生成图片，不调用 API，不接 Figma / Photoshop，不修改视觉风格。

执行准备结果：

- 图1：电子水牌，已整理为正式尺寸重制任务，目标尺寸 `1080x1920px`，状态为任务已整理，待后续执行。
- 图4：云相册三件套3，已整理为正式尺寸重制任务，目标尺寸 `2424x1242px`，状态为任务已整理，待后续执行。
- 图8：签到背景板，已列入印刷规格确认准备，等待用户补充 DPI、出血、安全区、交付格式和供应商要求。

新增文件：

- `04_outputs/final_size_execution_plan.csv`
- `04_outputs/final_size_execution_plan.json`
- `04_outputs/final_size_execution_status_report.md`
- `04_outputs/final_size_execution_tasks.csv`
- `04_outputs/final_size_execution_tasks.json`
- `04_outputs/final_size_execution_task_report.md`

当前仍未进入图片生成或设计软件处理。图1、图4只是任务已整理，尚未执行重制；图8仍等待用户补充印刷规格。

## v1.2-next-action-panel-draft 状态

已增加 Next Action 指令面板草稿。这是“下一步指令生成器”，用于把当前项目状态转换成可复制给 Codex 的操作指令。

当前能力：

- 显示推荐动作。
- 显示推荐原因。
- 显示当前暂不建议做的事项。
- 显示给 Codex 的下一步指令。
- 支持复制指令。

当前限制：

- 不自动运行 Codex。
- 不写回项目文件。
- 不触发 GitHub Actions。
- 不接 OpenAI Images API。
- 不接 Figma / Photoshop。
- 不是自动执行系统。

## v1.2-usable-draft-freeze 状态

当前已进入 v1.2 可使用草稿版收口阶段。这是一个设计师可实际使用的流程管理草稿版，不是完整自动化系统。

当前收口状态：

- GitHub Pages 静态管理台已上线。
- Next Action Panel 已完成。
- 正式尺寸确认流程已完成。
- 正式尺寸执行准备已完成。
- 正式尺寸执行任务整理已完成。
- 图1、图4已整理为正式尺寸重制任务，待后续执行。
- 图8为印刷规格补充任务，等待用户补充 DPI、出血、安全区、交付格式和供应商要求。
- 图9、图13暂时待测试。

当前仍不支持：

- 网页上传。
- 自动生成图片。
- 自动调用 Codex。
- OpenAI Images API 或其他绘画模型 API。
- Figma / Photoshop 自动化。

## v1.2-display-fix 状态

已修正 GitHub Pages 页面版本显示：顶部 Hero 区和版本卡片显示为 v1.2。  
这是页面版本显示修正，不是新功能发布。

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
- 当前已完成图1、图4、图8 的正式尺寸决策。下一步应等待用户确认是否开始重制图1、图4，并补充图8印刷规格。
- 当前已整理图1、图4正式尺寸重制任务。下一步应确认具体执行方式；图8仍需用户补充 DPI、出血、安全区、交付格式和供应商要求。
- Next Action 面板当前只用于复制指令；如需真正自动执行，后续可规划 GitHub Issues、`workflow_dispatch` 或后台服务。
