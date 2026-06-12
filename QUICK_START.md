# 快速开始

这是一份最短操作流程，适合每次新建真实设计延展项目时使用。

## 1. 创建真实项目

```powershell
.\scripts\create_project.ps1
```

输入项目名称，例如：

```text
20260611_真实小项目测试
```

项目会创建到：

```text
projects/项目名称/
```

## 2. 放入素材

| 素材 | 放入位置 |
| --- | --- |
| 主 KV | `00_input/kv/` |
| 需求 PPT | `00_input/ppt/` |
| 参考图 | `00_input/references/` |
| Logo | `00_input/logo/` |
| 单独尺寸表 | 如果有，放入 `00_input/size_table/`；如果尺寸已在 PPT 里，可以不放 |

## 3. 运行项目检查

```powershell
.\scripts\check_project.ps1 -InputProjectName "项目名称"
```

查看报告：

```text
projects/项目名称/01_review/project_check_report.md
```

## 4. 填写需求检查

打开并填写：

```text
01_review/requirement_check.md
```

重点确认物料、尺寸、方向、是否只做底图、预留区和缺失信息。

## 5. 记录缺失信息

打开：

```text
01_review/missing_info.md
```

把缺尺寸、缺参考图、缺 Logo、横竖版不明确等问题写清楚。

## 6. 做第一遍确认

在：

```text
01_review/confirm_log.md
```

记录第一遍确认结果和用户修改意见。

## 7. 做第二遍确认

第二遍确认用于锁定最终执行清单。确认完成前，不进入正式延展。

## 8. 更新物料清单

更新：

```text
02_material_list/material_list.csv
02_material_list/material_list.json
```

## 9. 生成提示词

```powershell
.\scripts\generate_prompts.ps1 -InputProjectName "项目名称"
```

生成位置：

```text
03_prompts/per_material_prompts/
```

## 10. 审核提示词

确认每个提示词都写清楚：

- 只做底图。
- 不生成文字、二维码、Logo、箭头、地址。
- 预留区明确。
- 推荐输出文件名正确。

## 11. 小批量生成视觉预览

先测试 3-5 张关键物料，不建议一开始生成全部 15 张。

当前不调用 API，视觉图由用户在 ChatGPT 或其他工具中测试后手动保存。

## 12. 保存预览图

保存到：

```text
04_outputs/preview/
```

命名规则：

```text
编号_物料名称_尺寸_v01.png
```

## 13. 检查输出保存

```powershell
.\scripts\check_outputs.ps1 -InputProjectName "项目名称"
```

查看：

```text
04_outputs/output_check_report.md
```

## 14. 审核输出

```powershell
.\scripts\review_outputs.ps1 -InputProjectName "项目名称"
```

查看：

```text
04_outputs/output_review_report.md
```

通过的小样只能标记为：

```text
视觉预览通过，待正式尺寸确认
```

不要直接标记为最终交付完成。

## 15. 刷新静态 UI

```powershell
.\scripts\deploy_ui.ps1 -InputProjectName "项目名称"
```

然后打开：

```text
docs/index.html
```

## 当前推荐使用方式

先创建真实项目，放入 KV / PPT，做项目检查和需求检查，完成两遍确认，再生成并审核提示词。小批量生成 3-5 张视觉预览后，手动保存到 `preview`，运行 `check_outputs` 和 `review_outputs`，通过后再扩展到更多物料。
