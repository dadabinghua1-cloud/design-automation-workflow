param(
    [string]$InputProjectName
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$templatePath = Join-Path $root "project_template"
$projectsPath = Join-Path $root "projects"

Write-Host ""
Write-Host "Design Automation Workflow - 新项目创建工具"
Write-Host ""

if (-not (Test-Path -LiteralPath $templatePath -PathType Container)) {
    Write-Host "未找到模板文件夹：$templatePath"
    Write-Host "请确认 project_template 文件夹存在。"
    exit 1
}

if (-not (Test-Path -LiteralPath $projectsPath -PathType Container)) {
    New-Item -ItemType Directory -Path $projectsPath | Out-Null
}

$projectName = $InputProjectName
if ([string]::IsNullOrWhiteSpace($projectName)) {
    $projectName = Read-Host "请输入项目名称"
}
$projectName = $projectName.Trim()

if ([string]::IsNullOrWhiteSpace($projectName)) {
    Write-Host "项目名称不能为空。"
    exit 1
}

$invalidChars = [System.IO.Path]::GetInvalidFileNameChars()
if ($projectName.IndexOfAny($invalidChars) -ge 0) {
    Write-Host "项目名称包含 Windows 文件夹不支持的字符，请修改后重试。"
    exit 1
}

$targetPath = Join-Path $projectsPath $projectName

if (Test-Path -LiteralPath $targetPath) {
    Write-Host ""
    Write-Host "项目已存在，不会覆盖："
    Write-Host $targetPath
    exit 1
}

Copy-Item -LiteralPath $templatePath -Destination $targetPath -Recurse

Write-Host ""
Write-Host "创建完成。"
Write-Host "新项目路径："
Write-Host $targetPath
Write-Host ""
Write-Host "下一步：请先填写 01_review/requirement_check.md，不要直接开始生成。"




