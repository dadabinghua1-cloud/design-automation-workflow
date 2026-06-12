# Design Automation Workflow UI 使用说明

当前 UI 是一个轻量静态原型，位于 `docs/`，可直接通过浏览器打开，也可作为 GitHub Pages 发布。

## 页面包含什么

- 项目状态：显示当前项目名称、工作流版本、提示词数量、视觉预览通过数量。
- 素材库：展示 `00_input/` 下的 KV、PPT、参考图、Logo、尺寸表等文件。
- 提示词中心：展示单物料提示词文件列表，点击后查看正文。
- 视觉预览：展示已保存到 `04_outputs/preview/` 的预览图。
- 输出登记：展示 `output_register.json` 中的状态、文件名、下一步动作。
- 项目队列：展示 `image_generation_queue.json` 中的待生成物料。

## 如何刷新 UI 数据

在仓库根目录运行：

```powershell
.\scripts\deploy_ui.ps1 -InputProjectName "20260611_真实小项目测试"
```

脚本会生成：

```text
docs/data/app-data.json
docs/assets/previews/
```

然后打开：

```text
docs/index.html
```

## 上传入口说明

当前页面中的上传按钮是流程提示入口，不会直接写入文件。真实素材仍需要放入项目目录：

| 素材 | 放入位置 |
| --- | --- |
| 主 KV | `00_input/kv/` |
| PPT | `00_input/ppt/` |
| 参考图 | `00_input/references/` |
| Logo | `00_input/logo/` |
| 尺寸表 | `00_input/size_table/` |

素材放好后，重新运行 `deploy_ui.ps1` 即可刷新页面展示。

## GitHub Pages 发布

仓库推送到 GitHub 后，可使用 `.github/workflows/pages.yml` 自动发布 `docs/`。

发布完成后访问：

```text
https://<你的用户名>.github.io/<仓库名>/
```

## 当前阶段限制

- 不直接上传文件到 GitHub。
- 不写回队列 Notes。
- 不调用图片生成 API。
- 不连接 Figma / Photoshop。
- UI 先验证流程可视化，后续再做视觉优化。
