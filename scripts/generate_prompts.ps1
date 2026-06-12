param(
    [string]$InputProjectName
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$projectsPath = Join-Path $root "projects"

$requiredMaterialFields = @(
    "id",
    "name",
    "size",
    "ratio",
    "orientation",
    "output_type",
    "reserved_area",
    "keep_elements",
    "remove_elements"
)

function Get-SafeFileName {
    param([string]$Name)

    $safeName = $Name
    foreach ($char in [System.IO.Path]::GetInvalidFileNameChars()) {
        $safeName = $safeName.Replace($char, "_")
    }
    return $safeName.Trim()
}

function Get-FieldValue {
    param(
        [object]$Item,
        [string]$FieldName,
        [string]$DefaultValue = "未填写"
    )

    if ($null -eq $Item.PSObject.Properties[$FieldName]) {
        return $DefaultValue
    }

    $value = [string]$Item.$FieldName
    if ([string]::IsNullOrWhiteSpace($value)) {
        return $DefaultValue
    }

    return $value.Trim()
}

function Get-SpecialPromptRule {
    param(
        [string]$Name,
        [string]$ReservedArea
    )

    if ($Name -eq "签到背景板") {
        return "特殊规则：中部仅预留签到主题区，不生成签到字。"
    }
    if ($Name -eq "云摄影二维码立牌") {
        return "特殊规则：仅预留二维码区，不生成二维码。"
    }
    if ($Name -eq "指引KT板" -or $Name -eq "指引 KT 板") {
        return "特殊规则：仅预留文字区和箭头区，不生成文字和箭头。"
    }
    if ($Name -eq "倒计时牌") {
        return "特殊规则：仅预留倒计时数字和标题区，不生成倒计时文字和数字。"
    }
    if ($Name -eq "桌号牌") {
        return "特殊规则：预留桌号数字区，保留圆形裁切安全区，不生成桌号数字。"
    }
    if ($Name -eq "参会证") {
        return "特殊规则：预留姓名、单位、二维码或编号区，不生成姓名、单位、二维码和编号。"
    }
    if ($Name -eq "餐券") {
        return "特殊规则：预留餐券信息、编号或二维码区，不生成餐券文字、编号和二维码。"
    }

    return "特殊规则：无。"
}

Write-Host ""
Write-Host "Design Automation Workflow - 单物料提示词生成"
Write-Host ""

$projectName = $InputProjectName
if ([string]::IsNullOrWhiteSpace($projectName)) {
    $projectName = Read-Host "请输入真实项目名称"
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

$materialJsonPath = Join-Path $projectPath "02_material_list/material_list.json"
$masterPromptPath = Join-Path $projectPath "03_prompts/master_style_prompt.md"
$negativePromptPath = Join-Path $projectPath "03_prompts/negative_prompt.md"
$outputFolder = Join-Path $projectPath "03_prompts/per_material_prompts"
$reportPath = Join-Path $projectPath "03_prompts/prompt_generation_report.md"

$missingSourceFiles = @()
foreach ($path in @($materialJsonPath, $masterPromptPath, $negativePromptPath)) {
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        $missingSourceFiles += $path
    }
}

if (($missingSourceFiles | Measure-Object).Count -gt 0) {
    Write-Host ""
    Write-Host "缺少必要文件，无法生成提示词："
    foreach ($file in $missingSourceFiles) {
        Write-Host $file
    }
    exit 1
}

if (-not (Test-Path -LiteralPath $outputFolder -PathType Container)) {
    New-Item -ItemType Directory -Path $outputFolder | Out-Null
}

try {
    $materialData = Get-Content -LiteralPath $materialJsonPath -Raw -Encoding UTF8 | ConvertFrom-Json
}
catch {
    Write-Host ""
    Write-Host "material_list.json 无法读取，请先修复 JSON 格式。"
    Write-Host $_.Exception.Message
    exit 1
}

if ($null -eq $materialData.materials) {
    Write-Host ""
    Write-Host "material_list.json 中未找到 materials 数组。"
    exit 1
}

$materials = @($materialData.materials)
$masterPrompt = Get-Content -LiteralPath $masterPromptPath -Raw -Encoding UTF8
$negativePrompt = Get-Content -LiteralPath $negativePromptPath -Raw -Encoding UTF8

$generatedFiles = @()
$skippedMaterials = @()
$missingFieldRecords = @()
$index = 0

foreach ($material in $materials) {
    $index += 1

    $id = Get-FieldValue $material "id"
    $name = Get-FieldValue $material "name"
    $size = Get-FieldValue $material "size"
    $ratio = Get-FieldValue $material "ratio"
    $orientation = Get-FieldValue $material "orientation"
    $outputType = Get-FieldValue $material "output_type"
    $reservedArea = Get-FieldValue $material "reserved_area"
    $keepElements = Get-FieldValue $material "keep_elements"
    $removeElements = Get-FieldValue $material "remove_elements"
    $specialRule = Get-SpecialPromptRule $name $reservedArea

    $missingFields = @()
    foreach ($field in $requiredMaterialFields) {
        $value = Get-FieldValue $material $field ""
        if ([string]::IsNullOrWhiteSpace($value)) {
            $missingFields += $field
        }
    }

    if (($missingFields | Measure-Object).Count -gt 0) {
        $missingFieldRecords += [pscustomobject]@{
            Item = "图$index / $id / $name"
            Fields = ($missingFields -join "、")
        }
    }

    if ($id -eq "未填写" -or $name -eq "未填写" -or $size -eq "未填写") {
        $skippedMaterials += "图$index：缺少 id、name 或 size，已跳过。"
        continue
    }

    $recommendedOutputFileName = "$(Get-SafeFileName "$id`_$name`_$size`_v01.png")"
    $promptFileName = Get-SafeFileName "$id`_$name`_$size`_prompt.md"
    $promptFilePath = Join-Path $outputFolder $promptFileName

    $singlePrompt = @"
图$index：$name，$ratio $orientation，尺寸 $size。

基于主 KV 视觉语言延展为$name。画面需要保留主 KV 的色彩、光影、材质和空间层次。输出类型为底图，只做底图，不生成具体文字、二维码、Logo、箭头、地址和其他正式信息。

预留区域：$reservedArea。

后期添加规则：文字后期添加，二维码后期添加，Logo 后期添加，箭头后期添加，地址后期添加。

$specialRule

需要保留的元素：$keepElements。

需要去掉或不生成的元素：$removeElements。

整体需要高级、简约、商业化、干净、有留白，方便后期 PS / Figma 添加文字、Logo、二维码、箭头和地址。
"@

    $promptContent = @"
# 图$index：$name

## 基础信息

| 项目 | 内容 |
| --- | --- |
| 图几 | 图$index |
| 物料名称 | $name |
| 尺寸 | $size |
| 比例 | $ratio |
| 横版 / 竖版 | $orientation |
| 输出类型 | $outputType |
| 预留区域 | $reservedArea |
| 需要保留的元素 | $keepElements |
| 需要去掉或不生成的元素 | $removeElements |
| 推荐输出文件名 | $recommendedOutputFileName |

## 当前物料单独提示词

$singlePrompt

## 项目统一主风格提示词

$masterPrompt

## 统一负面提示词

$negativePrompt
"@

    $promptContent | Set-Content -LiteralPath $promptFilePath -Encoding UTF8
    $generatedFiles += [pscustomobject]@{
        Figure = "图$index"
        File = "03_prompts/per_material_prompts/$promptFileName"
    }
}

$checkTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$report = @()
$report += "# 提示词生成报告"
$report += ""
$report += "## 生成时间"
$report += ""
$report += $checkTime
$report += ""
$report += "## 项目名称"
$report += ""
$report += $projectName
$report += ""
$report += "## 读取物料数量"
$report += ""
$report += "共读取 $($materials.Count) 个物料。"
$report += ""
$report += "## 成功生成的提示词文件"
$report += ""
if (($generatedFiles | Measure-Object).Count -eq 0) {
    $report += "- 暂无成功生成的提示词文件。"
}
else {
    foreach ($file in $generatedFiles) {
        $report += "- $($file.Figure)：$($file.File)"
    }
}
$report += ""
$report += "## 是否有缺失字段"
$report += ""
if (($missingFieldRecords | Measure-Object).Count -eq 0) {
    $report += "- 未发现缺失字段。"
}
else {
    foreach ($record in $missingFieldRecords) {
        $report += "- $($record.Item)：缺少 $($record.Fields)"
    }
}
$report += ""
$report += "## 是否有跳过的物料"
$report += ""
if (($skippedMaterials | Measure-Object).Count -eq 0) {
    $report += "- 没有跳过的物料。"
}
else {
    foreach ($item in $skippedMaterials) {
        $report += "- $item"
    }
}
$report += ""
$report += "## 下一步建议"
$report += ""
$report += "- 人工检查每个单物料提示词是否符合客户需求。"
$report += "- 检查图1、图2、图3是否与客户预览顺序一致。"
$report += "- 如果发现尺寸、横竖版、预留区或输出类型不准确，先回到 02_material_list/material_list.json 修改，再重新运行本脚本。"
$report += "- 提示词生成后仍需人工确认，不要直接进入底图延展。"

$report | Set-Content -LiteralPath $reportPath -Encoding UTF8

Write-Host ""
Write-Host "提示词生成完成。"
Write-Host "读取物料数量：$($materials.Count)"
Write-Host "成功生成数量：$(($generatedFiles | Measure-Object).Count)"
Write-Host "生成目录："
Write-Host $outputFolder
Write-Host ""
Write-Host "生成报告："
Write-Host $reportPath






