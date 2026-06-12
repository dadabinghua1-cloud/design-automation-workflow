# Design Automation Workflow

Design Automation Workflow 是一个面向活动物料延展的轻量工作流仓库。它把主 KV、PPT、物料清单、提示词、出图队列、预览图和输出登记集中管理，帮助真实设计项目先把流程跑顺，再逐步接入自动化能力。

```text
当前版本：1.1
当前能力：流程管理 + 提示词生成 + 小批量出图队列 + 输出登记 + 静态可视化 UI
当前不包含：API 自动出图、Figma 自动化、Photoshop 自动化
```

## 目录说明

| 目录 | 用途 |
| --- | --- |
| `.github/workflows/` | GitHub Actions：脚本检查和 GitHub Pages 发布 |
| `docs/` | GitHub Pages 静态 UI |
| `api/` | 后续 API 自动出图预留入口 |
| `scripts/` | 项目创建、检查、提示词生成、输出检查、UI 数据刷新脚本 |
| `project_template/` | 新项目初始化模板 |
| `projects/` | 真实项目和测试项目 |
| `UI/` | 静态 UI 的组件说明和设计令牌 |
| `00_input/` ~ `99_archive/` | 工作流基础模板目录 |

## 快速开始

1. 创建真实项目：

```powershell
.\scripts\create_project.ps1
```

2. 放入素材：

| 素材 | 放入位置 |
| --- | --- |
| 主 KV | `00_input/kv/` |
| PPT | `00_input/ppt/` |
| 参考图 | `00_input/references/` |
| Logo | `00_input/logo/` |
| 单独尺寸表 | `00_input/size_table/`，如果尺寸已在 PPT 中可不放 |

3. 检查项目结构：

```powershell
.\scripts\check_project.ps1 -InputProjectName "项目名称"
```

4. 完成需求检查和两遍确认。

5. 生成提示词：

```powershell
.\scripts\generate_prompts.ps1 -InputProjectName "项目名称"
```

6. 保存预览图后检查输出：

```powershell
.\scripts\check_outputs.ps1 -InputProjectName "项目名称"
.\scripts\review_outputs.ps1 -InputProjectName "项目名称"
```

7. 刷新静态 UI：

```powershell
.\scripts\deploy_ui.ps1 -InputProjectName "项目名称"
```

然后打开：

```text
docs/index.html
```

## GitHub Pages UI

静态 UI 位于 `docs/`，不依赖复杂前端框架，当前重点是功能可用：

- 展示项目状态。
- 展示素材 / KV / PPT 文件列表。
- 展示单物料提示词列表和正文。
- 展示视觉预览图。
- 展示 `output_register` 输出登记表。
- 展示 `image_generation_queue` 项目队列。

发布到 GitHub 后，`pages.yml` 会把 `docs/` 部署为 GitHub Pages。

## 为什么要先做需求检查

设计延展最容易返工的原因通常不是画面细节，而是尺寸、方向、物料数量、预留区和素材缺失。先做需求检查，可以在生成提示词和底图之前确认：

- 做哪些物料。
- 每个物料尺寸和横竖版。
- 是否只做底图。
- 文字、Logo、二维码、箭头、地址是否后期添加。
- 哪些信息仍需用户确认。

## 为什么要确认两遍

第一遍确认用于发现问题和补齐信息。第二遍确认用于锁定最终执行清单。第二遍确认完成前，不建议生成最终提示词，也不建议进入底图延展。

## 默认只做底图规则

当前工作流默认只生成底图：

- 不生成正式文字。
- 不生成二维码。
- 不生成 Logo。
- 不生成箭头。
- 不生成地址。
- 不生成签到字、桌号数字等正式信息。

这些内容由用户后期在 PS / Figma 或其他设计工具中添加。

## 图号标注规则

客户预览和内部沟通统一使用图号，例如图1、图4、图8。真实图号顺序以项目内 `05_delivery/client_preview_order.md` 为准。

## Codex 的角色

Codex 负责维护流程、脚本、提示词、队列、输出登记和静态 UI。当前不直接连接 Figma / Photoshop，也不自动调用图片生成 API。

## 后续路线

- v1.2：正式尺寸确认、批量输出审核、可能接入 OpenAI Images API。
- v2.0：Figma / Photoshop 半自动化接入。
