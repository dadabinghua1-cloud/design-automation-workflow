param(
    [string]$InputProjectName
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$projectsPath = Join-Path $root "projects"

function Test-PixelSize {
    param(
        [string]$TargetSize,
        [string]$CurrentPixelSize
    )

    $pixelPattern = '^(?<w>\d+)x(?<h>\d+)px$'
    if ($TargetSize -notmatch $pixelPattern) {
        return [pscustomobject]@{
            Result = "需确认印刷规格"
            ReachesFinalSize = "否"
            Suggestion = "目标尺寸不是纯像素规格，需要后续确认 DPI、出血和实际交付规格。"
        }
    }

    if ($CurrentPixelSize -notmatch $pixelPattern) {
        return [pscustomobject]@{
            Result = "当前像素不可判断"
            ReachesFinalSize = "否"
            Suggestion = "当前像素格式无法与目标像素比较，需要人工确认。"
        }
    }

    $null = $TargetSize -match $pixelPattern
    $targetWidth = [int]$Matches["w"]
    $targetHeight = [int]$Matches["h"]

    $null = $CurrentPixelSize -match $pixelPattern
    $currentWidth = [int]$Matches["w"]
    $currentHeight = [int]$Matches["h"]

    if ($currentWidth -eq $targetWidth -and $currentHeight -eq $targetHeight) {
        return [pscustomobject]@{
            Result = "当前像素等于目标像素"
            ReachesFinalSize = "是"
            Suggestion = "可进入最终交付确认，但仍需人工复核内容和命名。"
        }
    }

    if ($currentWidth -lt $targetWidth -or $currentHeight -lt $targetHeight) {
        return [pscustomobject]@{
            Result = "当前像素小于目标像素"
            ReachesFinalSize = "否"
            Suggestion = "需要重制、放大或进入 PS / Figma 处理。"
        }
    }

    return [pscustomobject]@{
        Result = "当前像素不等于目标像素"
        ReachesFinalSize = "否"
        Suggestion = "需要人工确认裁切、缩放或重新导出方式。"
    }
}

Write-Host ""
Write-Host "Design Automation Workflow - 正式尺寸确认检查"
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
$confirmationPath = Join-Path $outputsPath "final_size_confirmation.json"
$reportPath = Join-Path $outputsPath "final_size_check_report.md"

if (-not (Test-Path -LiteralPath $projectPath)) {
    Write-Host "项目不存在：$projectPath"
    exit 1
}

if (-not (Test-Path -LiteralPath $confirmationPath)) {
    Write-Host "缺少正式尺寸确认文件：$confirmationPath"
    exit 1
}

$confirmation = Get-Content -LiteralPath $confirmationPath -Raw -Encoding UTF8 | ConvertFrom-Json
$items = @($confirmation.items)
$checkRows = @()

foreach ($item in $items) {
    $missingFields = @()
    if ([string]::IsNullOrWhiteSpace($item.target_size)) { $missingFields += "target_size" }
    if ([string]::IsNullOrWhiteSpace($item.current_pixel_size)) { $missingFields += "current_pixel_size" }
    if ([string]::IsNullOrWhiteSpace($item.current_status)) { $missingFields += "current_status" }

    $judgement = if ($missingFields.Count -eq 0) {
        Test-PixelSize -TargetSize $item.target_size -CurrentPixelSize $item.current_pixel_size
    }
    else {
        [pscustomobject]@{
            Result = "缺少必要字段：$($missingFields -join ', ')"
            ReachesFinalSize = "否"
            Suggestion = "先补齐正式尺寸确认表中的必要字段。"
        }
    }

    $checkRows += [pscustomobject]@{
        figure = [string]$item.figure
        material_name = [string]$item.material_name
        target_size = [string]$item.target_size
        current_pixel_size = [string]$item.current_pixel_size
        current_status = [string]$item.current_status
        size_decision = [string]$item.size_decision
        final_action = [string]$item.final_action
        reaches_final_size = [string]$judgement.ReachesFinalSize
        judgement = [string]$judgement.Result
        suggestion = [string]$judgement.Suggestion
        notes = [string]$item.notes
    }
}

$checkTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$report = @()
$report += "# 正式尺寸确认检查报告"
$report += ""
$report += "## 检查时间"
$report += ""
$report += $checkTime
$report += ""
$report += "## 项目名称"
$report += ""
$report += $projectName
$report += ""
$report += "## 当前待确认图片"
$report += ""
foreach ($row in $checkRows) {
    $report += "- $($row.figure)：$($row.material_name)"
}
$report += ""
$report += "## 尺寸检查结果"
$report += ""
$report += "| 图号 | 物料名称 | 目标尺寸 | 当前像素 | 当前状态 | 是否达到最终生产尺寸 | 判断 | 建议动作 |"
$report += "| --- | --- | --- | --- | --- | --- | --- | --- |"
foreach ($row in $checkRows) {
    $report += "| $($row.figure) | $($row.material_name) | $($row.target_size) | $($row.current_pixel_size) | $($row.current_status) | $($row.reaches_final_size) | $($row.judgement) | $($row.suggestion) |"
}
$report += ""
$report += "## 当前结论"
$report += ""
$report += "- 当前阶段不要自动判断为最终完成。"
$report += "- 视觉预览通过不等于最终交付完成。"
$report += "- 需要人工确认重制、放大、PS 处理或 Figma 处理方案。"
$report += ""
$report += "## 下一步建议"
$report += ""
$report += '- 更新 `final_size_confirmation.csv/json` 中的 `size_decision` 和 `final_action`。'
$report += "- 像素尺寸不达标的图片，确认是否重制或放大。"
$report += "- 印刷尺寸图片，确认 DPI、出血、安全区和实际交付规格。"

$report | Set-Content -LiteralPath $reportPath -Encoding UTF8

Write-Host "检查完成。报告已生成："
Write-Host $reportPath
Write-Host "待确认图片：$($checkRows.Count) 个。"
