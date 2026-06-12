# 新项目创建指南

本指南说明如何使用轻量脚本，从 `project_template/` 自动复制出一个真实设计项目文件夹。

当前阶段只做项目初始化，不接 Figma，不接 Photoshop，不安装依赖，不写插件，不做图片生成。

## 为什么真实项目要放在 projects/

`project_template/` 是标准模板，应保持干净，不直接放真实客户素材，也不直接在里面做项目。

真实项目统一放在 `projects/`，好处是：

- 每个项目都有独立文件夹
- 不会污染模板
- 方便归档和查找
- 方便后续批量管理多个项目
- 可以保留每个项目自己的需求检查、确认记录、物料清单和交付文件

推荐结构：

```text
projects/
├─ 20260611_威元活动物料延展/
├─ 20260620_品牌发布会设计延展/
└─ 20260701_展会活动物料延展/
```

## 如何用 create_project.bat 创建项目

适合直接双击使用。

操作步骤：

1. 打开根目录下的 `scripts/` 文件夹。
2. 双击 `create_project.bat`。
3. 按提示输入项目名称。
4. 示例输入：

```text
20260611_威元活动物料延展
```

脚本会自动复制：

```text
project_template/
```

到：

```text
projects/20260611_威元活动物料延展/
```

如果同名项目已经存在，脚本会提示“项目已存在”，并且不会覆盖原文件夹。

## 如何用 create_project.ps1 创建项目

适合在 PowerShell 中运行，后续也更方便升级。

操作步骤：

1. 在项目根目录打开 PowerShell。
2. 运行：

```powershell
.\scripts\create_project.ps1
```

3. 按提示输入项目名称。
4. 示例输入：

```text
20260611_威元活动物料延展
```

也可以直接带项目名运行：

```powershell
.\scripts\create_project.ps1 -InputProjectName "20260611_威元活动物料延展"
```

如果 PowerShell 阻止脚本运行，可以在当前窗口临时允许本次运行：

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\create_project.ps1
```

这不会安装依赖，也不会修改项目功能，只是允许当前 PowerShell 窗口运行本地脚本。

## 创建完成后素材放哪里

进入新建项目文件夹后，把素材放到对应位置：

| 素材 | 放入位置 |
| --- | --- |
| 主 KV | `00_input/kv/` |
| PPT / 需求文档 | `00_input/ppt/` |
| 参考图 | `00_input/references/` |
| Logo | `00_input/logo/` |
| 尺寸表 | `00_input/size_table/` |
| 二维码 | `00_input/references/` 或按项目备注单独说明 |

## 创建后不要直接开始生成

新项目创建完成后，不能直接开始生成提示词或底图。

必须先填写：

```text
01_review/requirement_check.md
```

原因是设计延展前必须先确认：

- 要做哪些物料
- 每个物料的尺寸
- 横版 / 竖版 / 方版
- 是否只做底图
- 文字、Logo、二维码、箭头、地址是否后期添加
- 是否缺少素材或客户确认

## 必须完成两遍确认

进入提示词和底图延展前，必须完成两遍确认：

第一遍确认：

- 检查需求是否完整
- 找出缺失信息
- 记录用户修改意见

第二遍确认：

- 确认修改意见已处理
- 确认最终物料清单
- 确认尺寸和横竖版
- 确认是否允许进入提示词和底图阶段

确认记录填写在：

```text
01_review/confirm_log.md
```

只有两遍确认完成后，才进入：

```text
03_prompts/
04_outputs/
05_delivery/
```
