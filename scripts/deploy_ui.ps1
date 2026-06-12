param(
    [string]$InputProjectName = "20260611_真实小项目测试"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$projectRoot = Join-Path $repoRoot "projects\$InputProjectName"
$docsRoot = Join-Path $repoRoot "docs"
$dataRoot = Join-Path $docsRoot "data"
$previewAssetsRoot = Join-Path $docsRoot "assets\previews"

if (-not (Test-Path $projectRoot)) {
    throw "项目不存在：$projectRoot"
}

New-Item -ItemType Directory -Force -Path $dataRoot, $previewAssetsRoot | Out-Null
Write-Host "开始汇总 UI 数据：$InputProjectName"

function Read-JsonFile {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return $null }
    return Get-Content -Path $Path -Raw -Encoding UTF8 | ConvertFrom-Json
}

function Get-RelativePath {
    param([string]$Path)
    $full = [System.IO.Path]::GetFullPath($Path)
    $root = [System.IO.Path]::GetFullPath($repoRoot)
    return $full.Substring($root.Length).TrimStart("\") -replace "\\", "/"
}

$queuePath = Join-Path $projectRoot "04_outputs\image_generation_queue.json"
$registerPath = Join-Path $projectRoot "04_outputs\output_register.json"
$reviewReportPath = Join-Path $projectRoot "04_outputs\output_review_report.md"
$checkReportPath = Join-Path $projectRoot "04_outputs\output_check_report.md"
$finalSizeConfirmationPath = Join-Path $projectRoot "04_outputs\final_size_confirmation.json"
$promptDir = Join-Path $projectRoot "03_prompts\per_material_prompts"
$inputRoot = Join-Path $projectRoot "00_input"
$previewRoot = Join-Path $projectRoot "04_outputs\preview"

$queue = Read-JsonFile -Path $queuePath
$register = Read-JsonFile -Path $registerPath
Write-Host "已读取队列和输出登记"
$queueItems = @()
if ($queue -and $queue.items) {
    $queueItems = @($queue.items | ForEach-Object {
        [PSCustomObject]@{
            id = [string]$_.id
            figure = [string]$_.figure
            material_name = [string]$_.material_name
            size = [string]$_.size
            orientation = [string]$_.orientation
            prompt_file = [string]$_.prompt_file
            output_file = [string]$_.output_file
            output_folder = [string]$_.output_folder
            status = [string]$_.status
            priority = [string]$_.priority
            notes = [string]$_.notes
        }
    })
}

$records = @()
if ($register -and $register.records) {
    $records = @($register.records | ForEach-Object {
        [PSCustomObject]@{
            id = [string]$_.id
            figure = [string]$_.figure
            material_name = [string]$_.material_name
            file_name = [string]$_.file_name
            version = [string]$_.version
            output_path = [string]$_.output_path
            source_prompt = [string]$_.source_prompt
            status = [string]$_.status
            review_comment = [string]$_.review_comment
            next_action = [string]$_.next_action
        }
    })
}

$finalSizeItems = @()
if (Test-Path $finalSizeConfirmationPath) {
    $finalSizeConfirmation = Read-JsonFile -Path $finalSizeConfirmationPath
    if ($finalSizeConfirmation -and $finalSizeConfirmation.items) {
        $finalSizeItems = @($finalSizeConfirmation.items | ForEach-Object {
            [PSCustomObject]@{
                figure = [string]$_.figure
                material_name = [string]$_.material_name
                target_size = [string]$_.target_size
                current_pixel_size = [string]$_.current_pixel_size
                current_status = [string]$_.current_status
                size_decision = [string]$_.size_decision
                final_action = [string]$_.final_action
                notes = [string]$_.notes
            }
        })
    }
}

$prompts = @()
if (Test-Path $promptDir) {
    $prompts = Get-ChildItem -Path $promptDir -Filter "*_prompt.md" -File |
        Sort-Object Name |
        ForEach-Object {
            [PSCustomObject]@{
                name = $_.Name
                path = Get-RelativePath $_.FullName
                content = [string](Get-Content -Path $_.FullName -Raw -Encoding UTF8)
            }
        }
}
Write-Host "已读取提示词：$($prompts.Count) 个"

$assets = @()
if (Test-Path $inputRoot) {
    $assets = Get-ChildItem -Path $inputRoot -Recurse -File |
        Sort-Object FullName |
        ForEach-Object {
            [PSCustomObject]@{
                name = $_.Name
                folder = (Split-Path -Leaf (Split-Path -Parent $_.FullName))
                path = Get-RelativePath $_.FullName
                type = $_.Extension.TrimStart(".")
            }
        }
}
Write-Host "已读取素材：$($assets.Count) 个"

$previews = @()
if (Test-Path $previewRoot) {
    $previews = Get-ChildItem -Path $previewRoot -Filter "*.png" -File |
        Sort-Object Name |
        ForEach-Object {
            $target = Join-Path $previewAssetsRoot $_.Name
            Copy-Item -Path $_.FullName -Destination $target -Force
            [PSCustomObject]@{
                name = $_.Name
                sourcePath = Get-RelativePath $_.FullName
                url = "assets/previews/$($_.Name)"
            }
        }
}
Write-Host "已同步预览图：$($previews.Count) 个"

$latestReviewReport = ""
if (Test-Path $reviewReportPath) {
    $latestReviewReport = [string](Get-Content -Path $reviewReportPath -Raw -Encoding UTF8)
}

$latestCheckReport = ""
if (Test-Path $checkReportPath) {
    $latestCheckReport = [string](Get-Content -Path $checkReportPath -Raw -Encoding UTF8)
}

$statusCounts = [PSCustomObject]@{
    queueTotal = $queueItems.Count
    promptTotal = $prompts.Count
    previewTotal = $previews.Count
    registerTotal = $records.Count
    visualPassed = (@($records | Where-Object { $_.status -like "*视觉预览通过*" })).Count
    waitingConfirm = (@($records | Where-Object { $_.status -like "*待正式尺寸确认*" })).Count
}

$nextAction = [PSCustomObject]@{
    title = "正式尺寸决策"
    stage = "v1.2-final-size-confirmation-draft"
    recommendation = "先确认图1、图4、图8的正式尺寸处理方式"
    reason = "图1、图4、图8已经视觉预览通过，但还不是最终生产尺寸"
    blockedActions = @(
        "暂不建议继续美化UI",
        "暂不建议接API自动出图",
        "暂不建议一次性生成全部15张"
    )
    codexCommand = "请基于当前项目更新 final_size_confirmation：图1需要重制到1080x1920px；图4需要重制到2424x1242px；图8需要确认印刷规格、DPI、出血和安全区。请更新 final_size_confirmation.csv/json、WORKFLOW_STATUS.md、docs/data/app-data.json，并生成尺寸决策报告。不要生成图片，不要接API，不要接Figma或Photoshop。"
}

$data = [PSCustomObject]@{
    generatedAt = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    workflowVersion = "1.1"
    projectName = $InputProjectName
    status = $statusCounts
    assets = $assets
    prompts = $prompts
    queue = $queueItems
    register = $records
    previews = $previews
    finalSizeConfirmation = $finalSizeItems
    nextAction = $nextAction
    reports = [PSCustomObject]@{
        outputCheck = $latestCheckReport
        outputReview = $latestReviewReport
    }
}

$json = $data | ConvertTo-Json -Depth 20
Write-Host "已生成 JSON 数据"
$outputPath = Join-Path $dataRoot "app-data.json"
[System.IO.File]::WriteAllText($outputPath, $json, [System.Text.UTF8Encoding]::new($false))

$jsOutputPath = Join-Path $dataRoot "app-data.js"
$jsContent = "window.WORKFLOW_DATA = $json;"
[System.IO.File]::WriteAllText($jsOutputPath, $jsContent, [System.Text.UTF8Encoding]::new($false))

Write-Host "UI 数据已生成：$outputPath"
Write-Host "本地静态数据已生成：$jsOutputPath"
Write-Host "预览资源已同步：$previewAssetsRoot"
