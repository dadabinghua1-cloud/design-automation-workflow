param(
    [string]$InputProjectName
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$projectsPath = Join-Path $root "projects"

$requiredFolders = @(
    "00_input",
    "00_input/kv",
    "00_input/ppt",
    "00_input/references",
    "00_input/logo",
    "00_input/size_table",
    "01_review",
    "02_material_list",
    "03_prompts",
    "03_prompts/per_material_prompts",
    "04_outputs",
    "04_outputs/preview",
    "04_outputs/final",
    "04_outputs/ps_ready",
    "05_delivery",
    "99_archive"
)

$requiredFiles = @(
    "01_review/requirement_check.md",
    "01_review/missing_info.md",
    "01_review/confirm_log.md",
    "02_material_list/material_list.csv",
    "02_material_list/material_list.json",
    "03_prompts/master_style_prompt.md",
    "03_prompts/negative_prompt.md",
    "05_delivery/delivery_checklist.md",
    "05_delivery/naming_list.md",
    "05_delivery/client_preview_order.md"
)

$requiredCsvHeaders = @(
    "id",
    "name",
    "size",
    "ratio",
    "orientation",
    "output_type",
    "reserved_area",
    "keep_elements",
    "remove_elements",
    "priority",
    "status",
    "notes"
)

function Test-FolderHasFiles {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        return $false
    }

    $items = Get-ChildItem -LiteralPath $Path -File -ErrorAction SilentlyContinue
    return (($items | Measure-Object).Count -gt 0)
}

function Format-ResultTable {
    param(
        [array]$Rows,
        [string]$NameColumn
    )

    $lines = @("| 项目 | 结果 | 备注 |", "| --- | --- | --- |")
    foreach ($row in $Rows) {
        $lines += "| $($row.Name) | $($row.Result) | $($row.Note) |"
    }
    return $lines
}

Write-Host ""
Write-Host "Design Automation Workflow - 项目结构检查"
Write-Host ""

$projectName = $InputProjectName
if ([string]::IsNullOrWhiteSpace($projectName)) {
    $projectName = Read-Host "请输入要检查的项目名称"
}
$projectName = $projectName.Trim()

if ([string]::IsNullOrWhiteSpace($projectName)) {
    Write-Host "项目名称不能为空。"
    exit 1
}

$projectPath = Join-Path $projectsPath $projectName

if (-not (Test-Path -LiteralPath $projectPath -PathType Container)) {
    Write-Host ""
    Write-Host "项目不存在："
    Write-Host $projectPath
    Write-Host "请先用 scripts/create_project.ps1 或 scripts/create_project.bat 创建项目。"
    exit 1
}

$folderResults = foreach ($folder in $requiredFolders) {
    $fullPath = Join-Path $projectPath $folder
    if (Test-Path -LiteralPath $fullPath -PathType Container) {
        [pscustomobject]@{ Name = $folder; Result = "通过"; Note = "已存在" }
    }
    else {
        [pscustomobject]@{ Name = $folder; Result = "缺失"; Note = "需要补充文件夹" }
    }
}

$fileResults = foreach ($file in $requiredFiles) {
    $fullPath = Join-Path $projectPath $file
    if (Test-Path -LiteralPath $fullPath -PathType Leaf) {
        [pscustomobject]@{ Name = $file; Result = "通过"; Note = "已存在" }
    }
    else {
        [pscustomobject]@{ Name = $file; Result = "缺失"; Note = "需要补充模板文件" }
    }
}

$inputChecks = @(
    [pscustomobject]@{
        Name = "00_input/kv/"
        Result = if (Test-FolderHasFiles (Join-Path $projectPath "00_input/kv")) { "通过" } else { "为空" }
        Note = "必须补充主 KV"
    },
    [pscustomobject]@{
        Name = "00_input/ppt/"
        Result = if (Test-FolderHasFiles (Join-Path $projectPath "00_input/ppt")) { "通过" } else { "为空" }
        Note = "必须补充需求 PPT"
    },
    [pscustomobject]@{
        Name = "00_input/size_table/"
        Result = if (Test-FolderHasFiles (Join-Path $projectPath "00_input/size_table")) { "通过" } else { "提醒" }
        Note = if (Test-FolderHasFiles (Join-Path $projectPath "00_input/size_table")) { "已发现单独尺寸表" } else { "未发现单独尺寸表。如果需求 PPT 中已经包含尺寸、横竖版和物料说明，可以继续进入需求检查；否则需要补充尺寸信息。" }
    }
)

$csvPath = Join-Path $projectPath "02_material_list/material_list.csv"
$csvResult = "缺失"
$csvNote = "未找到 material_list.csv"

if (Test-Path -LiteralPath $csvPath -PathType Leaf) {
    $firstLine = Get-Content -LiteralPath $csvPath -Encoding UTF8 -TotalCount 1
    if ([string]::IsNullOrWhiteSpace($firstLine)) {
        $csvResult = "失败"
        $csvNote = "CSV 第一行为空，缺少表头"
    }
    else {
        $headers = $firstLine.Split(",") | ForEach-Object { $_.Trim() }
        $missingHeaders = $requiredCsvHeaders | Where-Object { $_ -notin $headers }
        if (($missingHeaders | Measure-Object).Count -eq 0) {
            $csvResult = "通过"
            $csvNote = "表头完整"
        }
        else {
            $csvResult = "失败"
            $csvNote = "缺少表头：" + ($missingHeaders -join "、")
        }
    }
}

$jsonPath = Join-Path $projectPath "02_material_list/material_list.json"
$jsonResult = "缺失"
$jsonNote = "未找到 material_list.json"

if (Test-Path -LiteralPath $jsonPath -PathType Leaf) {
    try {
        Get-Content -LiteralPath $jsonPath -Raw -Encoding UTF8 | ConvertFrom-Json | Out-Null
        $jsonResult = "通过"
        $jsonNote = "PowerShell 可以正常读取 JSON"
    }
    catch {
        $jsonResult = "失败"
        $jsonNote = "JSON 无法读取：" + $_.Exception.Message.Replace("|", "/")
    }
}

$issues = @()
$issues += $folderResults | Where-Object { $_.Result -ne "通过" } | ForEach-Object { "缺少文件夹：$($_.Name)" }
$issues += $fileResults | Where-Object { $_.Result -ne "通过" } | ForEach-Object { "缺少文件：$($_.Name)" }
$issues += $inputChecks | Where-Object { $_.Name -eq "00_input/kv/" -and $_.Result -ne "通过" } | ForEach-Object { "必须补充主 KV：$($_.Name)" }
$issues += $inputChecks | Where-Object { $_.Name -eq "00_input/ppt/" -and $_.Result -ne "通过" } | ForEach-Object { "必须补充需求 PPT：$($_.Name)" }
if ($csvResult -ne "通过") { $issues += "CSV 检查未通过：$csvNote" }
if ($jsonResult -ne "通过") { $issues += "JSON 检查未通过：$jsonNote" }

$reminders = @()
$reminders += $inputChecks | Where-Object { $_.Name -eq "00_input/size_table/" -and $_.Result -ne "通过" } | ForEach-Object { $_.Note }

$canEnterRequirementCheck = (
    (($folderResults | Where-Object { $_.Result -ne "通过" } | Measure-Object).Count -eq 0) -and
    (($fileResults | Where-Object { $_.Result -ne "通过" } | Measure-Object).Count -eq 0) -and
    (($inputChecks | Where-Object { ($_.Name -eq "00_input/kv/" -or $_.Name -eq "00_input/ppt/") -and $_.Result -ne "通过" } | Measure-Object).Count -eq 0) -and
    ($csvResult -eq "通过") -and
    ($jsonResult -eq "通过")
)

$reportPath = Join-Path $projectPath "01_review/project_check_report.md"
$checkTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

$report = @()
$report += "# 项目结构检查报告"
$report += ""
$report += "## 检查时间"
$report += ""
$report += $checkTime
$report += ""
$report += "## 项目名称"
$report += ""
$report += $projectName
$report += ""
$report += "## 文件夹检查结果"
$report += ""
$report += Format-ResultTable $folderResults "Name"
$report += ""
$report += "## 文件检查结果"
$report += ""
$report += Format-ResultTable $fileResults "Name"
$report += ""
$report += "## 输入素材检查结果"
$report += ""
$report += Format-ResultTable $inputChecks "Name"
$report += ""
$report += "## CSV 检查结果"
$report += ""
$report += "| 文件 | 结果 | 备注 |"
$report += "| --- | --- | --- |"
$report += "| 02_material_list/material_list.csv | $csvResult | $csvNote |"
$report += ""
$report += "## JSON 检查结果"
$report += ""
$report += "| 文件 | 结果 | 备注 |"
$report += "| --- | --- | --- |"
$report += "| 02_material_list/material_list.json | $jsonResult | $jsonNote |"
$report += ""
$report += "## 是否可以进入需求检查阶段"
$report += ""
if ($canEnterRequirementCheck) {
    $report += "可以进入需求检查阶段。下一步填写 01_review/requirement_check.md。"
}
else {
    $report += "暂不建议进入需求检查阶段。请先处理下方需要补充的问题。"
}
$report += ""
$report += "## 需要补充的问题"
$report += ""
if (($issues | Measure-Object).Count -eq 0) {
    $report += "- 暂无结构性问题。"
}
else {
    foreach ($issue in $issues) {
        $report += "- $issue"
    }
}
$report += ""
$report += "## 提醒事项"
$report += ""
if (($reminders | Measure-Object).Count -eq 0) {
    $report += "- 暂无提醒事项。"
}
else {
    foreach ($reminder in $reminders) {
        $report += "- $reminder"
    }
}

$report | Set-Content -LiteralPath $reportPath -Encoding UTF8

Write-Host ""
Write-Host "检查完成。"
Write-Host "检查报告已生成："
Write-Host $reportPath
Write-Host ""
if ($canEnterRequirementCheck) {
    Write-Host "结果：可以进入需求检查阶段。"
}
else {
    Write-Host "结果：请先处理报告中的补充问题。"
}






