@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set "ROOT=%~dp0.."
set "TEMPLATE=%ROOT%\project_template"
set "PROJECTS=%ROOT%\projects"

echo.
echo Design Automation Workflow - 新项目创建工具
echo.

if not exist "%TEMPLATE%" (
  echo 未找到模板文件夹：%TEMPLATE%
  echo 请确认 project_template 文件夹存在。
  pause
  exit /b 1
)

if not exist "%PROJECTS%" (
  mkdir "%PROJECTS%"
)

set /p PROJECT_NAME=请输入项目名称：

if "%PROJECT_NAME%"=="" (
  echo 项目名称不能为空。
  pause
  exit /b 1
)

set "TARGET=%PROJECTS%\%PROJECT_NAME%"

if exist "%TARGET%" (
  echo.
  echo 项目已存在，不会覆盖：
  echo %TARGET%
  pause
  exit /b 1
)

xcopy "%TEMPLATE%" "%TARGET%" /E /I /H /K >nul

if errorlevel 1 (
  echo.
  echo 创建失败，请检查路径或文件权限。
  pause
  exit /b 1
)

echo.
echo 创建完成。
echo 新项目路径：
echo %TARGET%
echo.
echo 下一步：请先填写 01_review\requirement_check.md，不要直接开始生成。
pause

