# 图片输出队列与管理工作流

本文件说明 Design Automation Workflow 1.1 的“出图队列与输出管理”模块。当前模块只管理队列、文件命名和输出登记，不调用图片生成 API，不接 Figma，不接 Photoshop。

## 为什么需要 image_generation_queue.json

`image_generation_queue.json` 用于记录后续需要生成的图片队列。它把“要生成哪张图、用哪个提示词、输出到哪里、当前状态是什么”整理成结构化数据。

这样做的好处：

- 避免一次性处理全部物料导致混乱。
- 明确小批量测试范围。
- 让每张图都能追溯到对应提示词。
- 后续如果接入自动出图脚本，可以直接读取队列。
- 方便按状态管理：待生成、已生成、待修改、通过、归档。

## 为什么需要 output_register

`output_register.csv` 和 `output_register.json` 用于记录已经生成或测试过的图片。

它记录：

- 图号和物料名称
- 文件名和版本号
- 输出路径
- 来源提示词
- 当前状态
- 审核意见
- 下一步动作

CSV 方便人工查看和编辑，JSON 方便后续自动化脚本读取。

## ChatGPT 内部生图和 API 自动生图的区别

ChatGPT 内部生图通常是在对话中完成视觉测试，图片不会自动落到项目文件夹里。测试通过后，需要人工把图片保存到项目的 `04_outputs/preview/` 文件夹，并更新 `output_register`。

API 自动生图是后续可能升级的方式。脚本会读取 `image_generation_queue.json`，调用图片生成接口，并自动把图片保存到指定输出目录，同时更新 `output_register`。

当前 1.1 阶段不接 API，只建立规则和文件结构。

## ChatGPT 生图后如何手动保存到 preview

1. 在 ChatGPT 内部完成小批量视觉测试。
2. 确认图片可接受。
3. 按命名规范保存到：

```text
projects/项目名称/04_outputs/preview/
```

4. 文件命名使用：

```text
编号_物料名称_尺寸_v01.png
```

示例：

```text
01_电子水牌_1080x1920px_v01.png
04_云相册三件套3_2424x1242px_v01.png
```

5. 保存后更新：

```text
04_outputs/output_register.csv
04_outputs/output_register.json
```

## 后续如果接 OpenAI Images API，图片应该自动保存到哪里

如果后续接入 OpenAI Images API，脚本应自动读取：

```text
04_outputs/image_generation_queue.json
```

并将生成图片保存到队列中指定的：

```text
04_outputs/preview/
```

通过审核后，再复制或移动到：

```text
04_outputs/final/
```

如需后续处理文件，可另存到：

```text
04_outputs/ps_ready/
```

## 为什么暂时不直接接 Figma / Photoshop

当前阶段的关键目标是先把需求、提示词、队列、输出文件和审核记录跑顺。直接接 Figma / Photoshop 会增加复杂度，也会让问题难以定位。

先保证以下内容稳定，再考虑接设计工具：

- 物料清单稳定
- 提示词稳定
- 出图队列稳定
- 输出命名稳定
- 预览图和最终图的流转规则稳定

## 为什么不一次性生成 15 张

15 张物料包含竖版、横版、方形、大背景、二维码区、裁切安全区等不同场景。一次性生成会让风格偏差、预留区错误和尺寸适配问题同时出现，返工成本高。

建议先测试 5 张：

- 图1：电子水牌
- 图4：云相册三件套3
- 图8：签到背景板
- 图9：云摄影二维码立牌
- 图13：桌号牌

这 5 张覆盖主要风险点。小批量通过后，再扩展到全部物料。

