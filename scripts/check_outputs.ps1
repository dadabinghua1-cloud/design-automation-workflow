param(
    [string]$InputProjectName
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$projectsPath = Join-Path $root "projects"

function New-RegisterRecordFromQueueItem {
    param([object]$Item)

    [pscustomobject]@{
        id = [string]$Item.id
        figure = [string]$Item.figure
        material_name = [string]$Item.material_name
        file_name = [string]$Item.output_file
        version = "v01"
        output_path = "04_outputs/preview/$($Item.output_file)"
        source_prompt = [string]$Item.prompt_file
        status = "已保存预览图，待输出审核"
        review_comment = "ChatGPT 内部视觉测试通过，已保存到 preview"
        next_action = "进行输出审核"
    }
}

Write-Host ""
Write-Host "Design Automation Workflow - 预览图保存检查"
Write-Host ""

$projectName = $InputProjectName
if ([string]::IsNullOrWhiteSpace($projectName)) {
    $projectName = Read-Host "请输入项目名称"
}
$projectName = $projectName.Trim()

if ([string]::IsNullOrWhiteSpace($projectName)) {
    Write-Host "项目名称不能为空。"
    exit 1
}

$projectPath = Join-Path $projectsPath $projectName
$outputsPath = Join-Path $projectPath "04_outputs"
$previewPath = Join-Path $outputsPath "preview"
$queuePath = Join-Path $outputsPath "image_generation_queue.json"
$registerJsonPath = Join-Path $outputsPath "output_register.json"
$registerCsvPath = Join-Path $outputsPath "output_register.csv"
$reportPath = Join-Path $outputsPath "output_check_report.md"

foreach ($requiredPath in @($projectPath, $previewPath, $queuePath, $registerJsonPath, $registerCsvPath)) {
    if (-not (Test-Path -LiteralPath $requiredPath)) {
        Write-Host "缺少必要路径或文件：$requiredPath"
        exit 1
    }
}

$queue = Get-Content -LiteralPath $queuePath -Raw -Encoding UTF8 | ConvertFrom-Json
$register = Get-Content -LiteralPath $registerJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
$registerCsv = @(Import-Csv -LiteralPath $registerCsvPath)
$queueItems = @($queue.items)

$checkRows = @()
foreach ($item in $queueItems) {
    $expectedPath = Join-Path $previewPath $item.output_file
    $exists = Test-Path -LiteralPath $expectedPath -PathType Leaf
    $checkRows += [pscustomobject]@{
        id = [string]$item.id
        figure = [string]$item.figure
        material_name = [string]$item.material_name
        output_file = [string]$item.output_file
        output_path = "04_outputs/preview/$($item.output_file)"
        prompt_file = [string]$item.prompt_file
        exists = $exists
        result = if ($exists) { "已保存" } else { "未找到" }
    }
}

$savedRows = @($checkRows | Where-Object { $_.exists })
$missingRows = @($checkRows | Where-Object { -not $_.exists })

$records = @($register.records)
foreach ($row in $savedRows) {
    $existingJson = @($records | Where-Object { $_.id -eq $row.id })[0]
    if ($null -eq $existingJson) {
        $queueItem = @($queueItems | Where-Object { $_.id -eq $row.id })[0]
        $records += New-RegisterRecordFromQueueItem -Item $queueItem
    }
    else {
        $existingJson.file_name = $row.output_file
        $existingJson.output_path = $row.output_path
        $existingJson.source_prompt = $row.prompt_file
        if ($existingJson.status -ne "视觉预览通过，待正式尺寸确认") {
            $existingJson.status = "已保存预览图，待输出审核"
            $existingJson.review_comment = "ChatGPT 内部视觉测试通过，已保存到 preview"
            $existingJson.next_action = "进行输出审核"
        }
    }

    $existingCsv = @($registerCsv | Where-Object { $_.id -eq $row.id })[0]
    if ($null -eq $existingCsv) {
        $queueItem = @($queueItems | Where-Object { $_.id -eq $row.id })[0]
        $registerCsv += New-RegisterRecordFromQueueItem -Item $queueItem
    }
    else {
        $existingCsv.file_name = $row.output_file
        $existingCsv.output_path = $row.output_path
        $existingCsv.source_prompt = $row.prompt_file
        if ($existingCsv.status -ne "视觉预览通过，待正式尺寸确认") {
            $existingCsv.status = "已保存预览图，待输出审核"
            $existingCsv.review_comment = "ChatGPT 内部视觉测试通过，已保存到 preview"
            $existingCsv.next_action = "进行输出审核"
        }
    }
}

$register.records = @($records | Sort-Object id)
$register | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $registerJsonPath -Encoding UTF8
$registerCsv | Sort-Object id | Export-Csv -LiteralPath $registerCsvPath -NoTypeInformation -Encoding UTF8

$checkTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$report = @()
$report += "# 输出保存检查报告"
$report += ""
$report += "## 检查时间"
$report += ""
$report += $checkTime
$report += ""
$report += "## 项目名称"
$report += ""
$report += $projectName
$report += ""
$report += "## preview 文件夹路径"
$report += ""
$report += $previewPath
$report += ""
$report += "## 队列中需要生成 / 保存的文件"
$report += ""
$report += "| 图号 | 物料名称 | 文件名 | 检查结果 |"
$report += "| --- | --- | --- | --- |"
foreach ($row in $checkRows) {
    $report += "| $($row.figure) | $($row.material_name) | $($row.output_file) | $($row.result) |"
}
$report += ""
$report += "## 已保存"
$report += ""
if ($savedRows.Count -eq 0) {
    $report += "- 暂未找到队列中的预览图文件。"
}
else {
    foreach ($row in $savedRows) {
        $report += "- $($row.figure)：$($row.material_name)"
    }
}
$report += ""
$report += "## 未保存"
$report += ""
if ($missingRows.Count -eq 0) {
    $report += "- 无缺失文件。"
}
else {
    foreach ($row in $missingRows) {
        $report += "- $($row.figure)：$($row.material_name)"
    }
}
$report += ""
$report += "## 是否可以进入小批量输出审核"
$report += ""
if ($savedRows.Count -gt 0) {
    $report += "可以对已保存的预览图进入输出审核。当前已保存 $($savedRows.Count) 个，未保存 $($missingRows.Count) 个。"
}
else {
    $report += "暂不可以。队列中的预览图均未保存。"
}
$report += ""
$report += "## 下一步建议"
$report += ""
if ($savedRows.Count -gt 0) {
    $report += "- 运行 review_outputs.ps1 审核所有状态为：已保存预览图，待输出审核 的项目。"
}
if ($missingRows.Count -gt 0) {
    $report += "- 手动保存未保存的预览图到 04_outputs/preview/。"
    $report += "- 文件名必须与队列中的 output_file 完全一致。"
}

$report | Set-Content -LiteralPath $reportPath -Encoding UTF8

Write-Host "检查完成。报告已生成："
Write-Host $reportPath
Write-Host "已保存 $($savedRows.Count) 个，未保存 $($missingRows.Count) 个；output_register 已按队列自动更新。"



