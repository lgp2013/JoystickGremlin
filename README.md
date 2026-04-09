# Joystick Gremlin 简体中文汉化版

## 项目说明

本仓库基于上游项目 [WhiteMagic/JoystickGremlin](https://github.com/WhiteMagic/JoystickGremlin) 进行维护。

上游项目是一个运行在 Windows 平台上的摇杆映射与输入编排工具，可以把物理摇杆、油门、踏板、键盘、鼠标等输入，经过模式切换、条件判断、宏、曲线、插件等处理后，映射到 vJoy、键盘、鼠标等输出设备。

本仓库的主要工作不是重写功能，而是在尽量保持上游行为和结构不变的前提下，为项目补充和维护简体中文界面，方便中文用户直接使用、学习和继续维护。

## 本仓库主要做了什么

- 为主界面、常用弹窗、设置页面和大量动作插件页面补充了简体中文翻译
- 增加了运行时翻译加载逻辑，使程序可以直接加载中文翻译资源
- 修复了部分未命中翻译时显示为空白的问题
- 修复了部分旧配置在设置页面中因字段缺失而导致内容不显示的问题
- 调整了部分下拉框的显示逻辑，实现“界面显示中文，内部配置值保持英文”，避免破坏原有配置兼容性
- 在打包配置中加入翻译资源，使生成的 exe 可以直接带中文界面

## 上游项目

- 上游仓库：[WhiteMagic/JoystickGremlin](https://github.com/WhiteMagic/JoystickGremlin)
- 上游文档：[Joystick Gremlin Manual](https://whitemagic.github.io/JoystickGremlin/)

如果你需要了解原始功能设计、使用方式、脚本能力、插件机制或后续版本更新，应该以上游项目为准。本仓库主要聚焦汉化与少量为汉化服务的兼容性修正。

## 适用环境

- 操作系统：Windows
- Python：建议 3.13
- 图形界面：PySide6 / QML
- 虚拟设备依赖：vJoy

Joystick Gremlin 的核心用途依赖 Windows 输入设备生态和 vJoy，因此不适合在 Linux 或 macOS 上直接运行。

## 运行方式

### 直接运行源码

```powershell
cd "C:\path\to\JoystickGremlin"
py -3.13 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -U pip
pip install PySide6 PyInstaller pywin32 jsonschema miniaudio
python joystick_gremlin.py
```

### 打包为 exe

```powershell
cd "C:\path\to\JoystickGremlin"
py -3.13 -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -U pip
pip install PySide6 PyInstaller pywin32 jsonschema miniaudio
pyinstaller -y --clean joystick_gremlin.spec
```

打包产物默认位于：

```text
dist/joystick_gremlin/joystick_gremlin.exe
```

## 汉化文件说明

汉化相关的核心文件包括：

- `translations/joystick_gremlin_zh_CN.ts`
- `gremlin/i18n.py`
- `gremlin/ui/action_model.py`
- `gremlin/ui/option.py`
- `joystick_gremlin.py`
- `joystick_gremlin.spec`

其中：

- `translations/joystick_gremlin_zh_CN.ts` 是简体中文翻译词条文件
- `gremlin/i18n.py` 负责运行时加载翻译
- `action_model.py` 和 `option.py` 负责把部分动态生成的菜单、选项、分组、动作名接入翻译
- `joystick_gremlin.spec` 负责把翻译资源打包进 exe

更详细的维护说明见：

- [TRANSLATION_ZH_CN.md](TRANSLATION_ZH_CN.md)

## 后续更新怎么处理

如果上游项目后续更新，本仓库建议按下面的思路维护：

1. 从上游仓库同步最新代码
2. 保留并合并本仓库的汉化相关改动
3. 检查新页面、新动作、新设置项是否新增英文文本
4. 更新 `translations/joystick_gremlin_zh_CN.ts`
5. 重新运行程序并打包验证

如果上游只是新增了一些文案，很多时候只需要补充翻译文件即可；如果上游修改了界面结构、动态模型或启动流程，则需要少量代码跟进。

## 开发与贡献

如果你要继续维护这个汉化版，建议优先遵循下面的原则：

- 功能逻辑尽量跟随上游
- 汉化优先通过翻译层完成，不随意改动业务逻辑
- 如果必须改代码，优先做与翻译加载、动态文本显示、兼容性相关的最小修改
- 每次同步上游后都重新检查设置页、动作菜单、插件页面和打包结果

## 免责声明

本仓库是基于上游项目的非官方简体中文汉化维护版本。

- 原始功能、设计和主要版权归上游项目作者及其贡献者所有
- 本仓库新增内容主要为汉化、文档整理和少量兼容性调整
- 如需提交通用功能修复或新特性，建议同时关注上游仓库的实现与演进
