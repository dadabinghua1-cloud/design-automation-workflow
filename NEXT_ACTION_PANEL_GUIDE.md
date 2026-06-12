# Next Action 指令面板指南

Next Action 指令面板用于把当前工作流状态转成一段可以复制给 Codex 的下一步操作指令。

## 为什么需要这个面板

Design Automation Workflow 的状态文件越来越多：需求检查、提示词、出图队列、输出登记、正式尺寸确认等都需要按顺序推进。

如果每次都由用户重新描述上下文，容易遗漏约束，例如：

- 不生成图片。
- 不接 API。
- 不接 Figma / Photoshop。
- 当前只处理正式尺寸确认。
- 图1、图4、图8还不是最终交付图。

Next Action 指令面板把这些信息整理成一段可复制指令，减少用户来回询问和复制成本。

## 当前版本怎么工作

当前 GitHub Pages 页面仍是静态页面。

它只做三件事：

1. 读取 `docs/data/app-data.json` 或 `docs/data/app-data.js` 中的 `nextAction`。
2. 在页面中显示推荐动作、原因、暂不建议做的事项。
3. 提供“复制指令”按钮，把 `codexCommand` 复制到剪贴板。

## 当前不能做什么

- 不能直接运行 Codex。
- 不能写回项目文件。
- 不能触发 GitHub Actions。
- 不能自动生成图片。
- 不能调用 OpenAI Images API。
- 不能接 Figma / Photoshop。

## 后续自动执行路线

如果后续要真正自动执行，可以进入 v1.3 / v1.4 再规划：

- GitHub Issues：点击后生成 Issue，作为任务队列。
- GitHub Actions `workflow_dispatch`：手动触发某个检查或生成流程。
- 后台服务：由服务读取项目状态并执行脚本。
- 本地桌面入口：由本地工具读取 nextAction 并调用 Codex。

当前阶段不做这些自动化，只保留可复制指令。

## 当前默认指令

当前建议先进入正式尺寸决策：

- 图1需要重制到 `1080x1920px`。
- 图4需要重制到 `2424x1242px`。
- 图8需要确认印刷规格、DPI、出血和安全区。

执行时仍需遵守：

- 不生成图片。
- 不接 API。
- 不接 Figma。
- 不接 Photoshop。
