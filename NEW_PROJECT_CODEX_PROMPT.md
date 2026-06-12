# 新项目启动 Codex 指令模板

请基于当前 Design Automation Workflow 创建一个新的设计延展项目。

要求：

1. 使用 `project_template` 创建新项目文件夹。
2. 读取新项目中的主 KV、PPT、参考图、Logo 和可选尺寸表。
3. 先进入需求检查阶段，更新 `01_review/requirement_check.md`。
4. 如果有缺失信息，先更新 `01_review/missing_info.md`。
5. 不要直接生成图片。
6. 不要接 OpenAI Images API 或其他绘画模型 API。
7. 不要接 Figma / Photoshop。
8. 先生成第一版物料清单 `material_list.csv/json`，状态标记为待确认。
9. 等用户完成第一遍确认和第二遍确认后，再生成单物料提示词。
10. 当前阶段只更新流程文件、清单、报告和状态，不进入正式出图。
