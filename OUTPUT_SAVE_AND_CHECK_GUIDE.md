# 预览图保存与输出登记检查指南

本指南说明 Design Automation Workflow 1.1 中，ChatGPT 内部生图测试完成后，如何手动保存预览图并检查输出登记。

当前阶段不调用图片生成 API，不接 Figma，不接 Photoshop。

## 为什么要手动保存到 preview

ChatGPT 内部生图测试通常在对话中完成，图片不会自动保存到项目目录。为了让项目文件夹保留完整交付记录，需要用户手动把通过测试的图片保存到：

```text
projects/项目名称/04_outputs/preview/
```

这样后续才能进行输出审核、版本管理、客户预览和最终交付。

## 文件命名规则

预览图文件名必须和队列里的 `output_file` 一致。

标准格式：

```text
编号_物料名称_尺寸_v01.png
```

示例：

```text
01_电子水牌_1080x1920px_v01.png
04_云相册三件套3_2424x1242px_v01.png
```

## 如何运行 check_outputs.ps1

在项目根目录打开 PowerShell，运行：

```powershell
.\scripts\check_outputs.ps1 -InputProjectName "20260611_真实小项目测试"
```

也可以不带参数运行，按提示输入项目名称：

```powershell
.\scripts\check_outputs.ps1
```

## 如何查看 output_check_report.md

脚本运行后会生成：

```text
projects/项目名称/04_outputs/output_check_report.md
```

报告会显示：

- 检查时间
- 项目名称
- preview 文件夹路径
- 队列中需要保存的文件
- 已找到的文件
- 缺失的文件
- 图1和图4是否已保存
- 是否可以进入小批量输出审核
- 下一步建议

## 什么情况下可以更新 output_register

只有当对应图片文件已经真实存在于：

```text
04_outputs/preview/
```

并且文件名和 `image_generation_queue.json` 中的 `output_file` 完全一致时，才可以把登记状态更新为：

```text
已保存预览图，待输出审核
```

如果文件没找到，不能强行更新登记状态，只能在报告中提示用户手动保存。

## 为什么这是 API 自动出图前的必要验证

在接入 API 自动出图前，必须先验证人工流程是否稳定：

- 队列文件是否能准确描述要生成的图
- 输出文件名是否清晰
- preview 文件夹是否作为预览图唯一入口
- output_register 是否能记录状态和审核意见
- 缺失文件是否能被准确发现

这些规则稳定后，再做 API 自动保存和自动登记，才不容易把错误批量放大。

