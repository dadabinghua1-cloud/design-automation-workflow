# 项目结构检查指南

本指南说明如何使用 `scripts/check_project.ps1` 检查真实设计项目是否符合 Design Automation Workflow 1.0 标准。

当前检查只覆盖项目结构、模板文件、关键输入素材、CSV 表头和 JSON 可读性。不接 Figma，不接 Photoshop，不安装依赖，不做图片生成。

## 为什么要做项目检查

真实项目开始后，最常见的问题是文件夹缺失、模板缺失、主 KV 没放、需求 PPT 没放、物料清单格式被改坏。项目检查脚本可以在填写需求检查前先发现这些基础问题。

这样做的好处：

- 确认项目是从标准模板创建的
- 确认关键文件夹和模板还在
- 确认主 KV、PPT 是否已经放入
- 提醒是否存在单独尺寸表
- 确认 `material_list.csv` 有标准表头
- 确认 `material_list.json` 可以被 PowerShell 正常读取
- 生成一份可追踪的检查报告

## 什么时候运行 check_project.ps1

建议在以下时机运行：

1. 用 `create_project.ps1` 或 `create_project.bat` 创建真实项目后。
2. 放入主 KV、PPT 等输入素材后。
3. 正式填写 `01_review/requirement_check.md` 之前。
4. 如果项目文件被移动、复制或多人修改过，也可以再次运行。

## 如何运行 check_project.ps1

在项目根目录打开 PowerShell，运行：

```powershell
.\scripts\check_project.ps1
```

然后输入要检查的项目名称，例如：

```text
20260611_威元活动物料延展
```

也可以直接带项目名运行：

```powershell
.\scripts\check_project.ps1 -InputProjectName "20260611_威元活动物料延展"
```

脚本默认检查：

```text
projects/20260611_威元活动物料延展/
```

如果 PowerShell 阻止脚本运行，可以在当前窗口临时允许本次运行：

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\check_project.ps1
```

这不会安装依赖，也不会连接任何设计软件。

## 检查报告在哪里

检查完成后，报告会生成在真实项目的：

```text
01_review/project_check_report.md
```

示例：

```text
projects/20260611_威元活动物料延展/01_review/project_check_report.md
```

## 哪些问题必须先解决

以下问题建议先解决，再进入需求检查：

- 项目文件夹不存在
- 必须文件夹缺失
- 必须模板文件缺失
- `00_input/kv/` 为空
- `00_input/ppt/` 为空
- `material_list.csv` 没有表头或表头不完整
- `material_list.json` 无法被正常读取

以下问题属于提醒，不一定阻断需求检查：

- `00_input/size_table/` 为空

尺寸表不是必需文件。如果需求 PPT 中已经包含完整尺寸、横竖版和物料说明，可以不放单独尺寸表。

如果 PPT 里的尺寸不完整，才需要在 `00_input/size_table/` 中补充 Excel、txt、图片尺寸表或其他尺寸说明文件。

## 检查通过后的下一步

检查通过后，下一步不是直接生成提示词或底图。

请先填写：

```text
01_review/requirement_check.md
```

需求检查完成后，再记录缺失信息、做第一遍确认和第二遍确认。只有两遍确认完成后，才进入提示词和底图延展阶段。
