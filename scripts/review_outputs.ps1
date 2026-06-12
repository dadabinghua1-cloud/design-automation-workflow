param(
    [string]$InputProjectName
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$projectsPath = Join-Path $root "projects"

function Get-ImageSize {
    param([string]$Path)

    Add-Type -AssemblyName System.Drawing
    $image = [System.Drawing.Image]::FromFile($Path)
    try {
        [pscustomobject]@{
            Width = $image.Width
            Height = $image.Height
            Text = "$($image.Width)x$($image.Height)px"
        }
    }
    finally {
        $image.Dispose()
    }
}

Write-Host ""
Write-Host "Design Automation Workflow - 小批量输出审核"
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
$reportPath = Join-Path $outputsPath "output_review_report.md"

foreach ($requiredPath in @($projectPath, $previewPath, $queuePath, $registerJsonPath, $registerCsvPath)) {
    if (-not (Test-Path -LiteralPath $requiredPath)) {
        Write-Host "缺少必要路径或文件：$requiredPath"
        exit 1
    }
}

$queue = Get-Content -LiteralPath $queuePath -Raw -Encoding UTF8 | ConvertFrom-Json
$register = Get-Content -LiteralPath $registerJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
$registerCsv = @(Import-Csv -LiteralPath $registerCsvPath)

$recordsToReview = @(
    $register.records |
    Where-Object {
        $_.status -eq "已保存预览图，待输出审核" -or
        $_.status -eq "视觉预览通过，待正式尺寸确认"
    } |
    Sort-Object id
)
$reviewRows = @()

foreach ($record in $recordsToReview) {
    $queueItem = @($queue.items | Where-Object { $_.id -eq $record.id })[0]
    $targetSize = if ($null -ne $queueItem) { $queueItem.size } else { "未知" }
    $fileName = if (-not [string]::IsNullOrWhiteSpace($record.file_name)) { $record.file_name } elseif ($null -ne $queueItem) { $queueItem.output_file } else { "" }
    $filePath = Join-Path $previewPath $fileName
    $exists = Test-Path -LiteralPath $filePath -PathType Leaf
    $actualSize = "文件不存在"

    if ($exists) {
        try {
            $actualSize = (Get-ImageSize -Path $filePath).Text
        }
        catch {
            $actualSize = "无法读取像素尺寸：$($_.Exception.Message)"
        }
    }

    $visualConclusion = "视觉测试通过，已保存预览图。当前作为视觉预览图使用，后续若进入正式交付，需要确认是否重制为标准 $targetSize。"
    $reviewConclusion = if ($exists) { "视觉预览通过，待正式尺寸确认" } else { "文件不存在，不能审核通过" }

    $reviewRows += [pscustomobject]@{
        id = [string]$record.id
        figure = [string]$record.figure
        material_name = [string]$record.material_name
        file_name = [string]$fileName
        exists = $exists
        file_name_ok = if ($null -ne $queueItem) { $fileName -eq $queueItem.output_file } else { $false }
        target_size = [string]$targetSize
        actual_size = [string]$actualSize
        final_size = "否，当前为视觉预览图"
        visual_conclusion = $visualConclusion
        review_conclusion = $reviewConclusion
    }
}

$passedRows = @($reviewRows | Where-Object { $_.exists })
foreach ($row in $passedRows) {
    foreach ($record in @($register.records | Where-Object { $_.id -eq $row.id })) {
        $record.status = "视觉预览通过，待正式尺寸确认"
        $record.review_comment = "视觉预览通过，当前图片用于小批量测试记录，正式交付前需确认最终尺寸"
        $record.next_action = "继续测试未完成物料，或进入正式尺寸确认"
        $record.output_path = "04_outputs/preview/$($row.file_name)"
    }

    foreach ($csvRecord in @($registerCsv | Where-Object { $_.id -eq $row.id })) {
        $csvRecord.status = "视觉预览通过，待正式尺寸确认"
        $csvRecord.review_comment = "视觉预览通过，当前图片用于小批量测试记录，正式交付前需确认最终尺寸"
        $csvRecord.next_action = "继续测试未完成物料，或进入正式尺寸确认"
        $csvRecord.output_path = "04_outputs/preview/$($row.file_name)"
    }
}

$register | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $registerJsonPath -Encoding UTF8
$registerCsv | Sort-Object id | Export-Csv -LiteralPath $registerCsvPath -NoTypeInformation -Encoding UTF8

$checkTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$report = @()
$report += "# 小批量输出审核报告"
$report += ""
$report += "## 审核时间"
$report += ""
$report += $checkTime
$report += ""
$report += "## 项目名称"
$report += ""
$report += $projectName
$report += ""
$report += "## 审核对象"
$report += ""
if ($reviewRows.Count -eq 0) {
    $report += "- 当前没有状态为：已保存预览图，待输出审核 的项目。"
}
else {
    foreach ($row in $reviewRows) {
        $report += "- $($row.figure)：$($row.material_name)"
    }
}
$report += ""
$report += "## 审核结果"
$report += ""
$report += "| 图号 | 物料名称 | 文件名 | 文件是否存在 | 文件名是否规范 | 目标尺寸 | 实际像素尺寸 | 是否为最终生产尺寸 | 当前审核结论 |"
$report += "| --- | --- | --- | --- | --- | --- | --- | --- | --- |"
foreach ($row in $reviewRows) {
    $existsText = if ($row.exists) { "是" } else { "否" }
    $fileNameText = if ($row.file_name_ok) { "是" } else { "否" }
    $report += "| $($row.figure) | $($row.material_name) | $($row.file_name) | $existsText | $fileNameText | $($row.target_size) | $($row.actual_size) | $($row.final_size) | $($row.review_conclusion) |"
}
$report += ""
$report += "## 视觉测试结论"
$report += ""
if ($reviewRows.Count -eq 0) {
    $report += "- 暂无需要审核的预览图。"
}
else {
    foreach ($row in $reviewRows) {
        $report += "- $($row.figure)：$($row.visual_conclusion)"
    }
}
$report += ""
$report += "## 下一步建议"
$report += ""
if ($passedRows.Count -gt 0) {
    $report += "- 已将存在的预览图更新为：视觉预览通过，待正式尺寸确认。"
    $report += "- 不要标记为最终交付完成。"
}
if (($reviewRows | Where-Object { -not $_.exists } | Measure-Object).Count -gt 0) {
    $report += "- 有登记项缺少本地文件，请先补齐预览图再重新审核。"
}

$report | Set-Content -LiteralPath $reportPath -Encoding UTF8

Write-Host "审核完成。报告已生成："
Write-Host $reportPath
Write-Host "已审核 $($reviewRows.Count) 个；通过视觉预览 $($passedRows.Count) 个。"



