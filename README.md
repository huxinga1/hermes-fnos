# Hermes AI Agent — fnOS Native Application (.fpk)

> **⚠️ 重要声明：本仓库仅为 fnOS 打包层**
>
> 本 `.fpk` 应用是对以下两个上游项目的 **fnOS 原生封装**，并非独立项目：
> - 🤖 **[NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent)** — 自进化 AI 智能体核心
> - 🖥️ **[nesquena/hermes-webui](https://github.com/nesquena/hermes-webui)** — Hermes Agent 的 Web 管理界面
>
> 本仓库**不包含**这两个项目的源码，安装时从 GitHub 动态下载最新版本。

## 项目定位

| 组件 | 来源 | 说明 |
|------|------|------|
| **AI 智能体** | [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) | 通过 pip 安装到 venv |
| **Web 界面** | [nesquena/hermes-webui](https://github.com/nesquena/hermes-webui) | 安装时 git clone |
| **fpk 打包层** | 本仓库 | fpk 元数据 + 生命周期脚本 |

本仓库只负责：
- 将上述两个项目打包成 fnOS 可识别的 `.fpk` 格式
- 处理 fnOS 安装/卸载/升级生命周期
- 解决国内网络访问 GitHub 的困难（多级镜像/代理兜底）
- 提供安装向导（pip 镜像、GitHub 代理、自定义数据路径）

**所有 AI 功能、WebUI 界面均由上游项目提供。**

## 🏗️ 项目结构

```
com.nousresearch.hermes/
├── manifest                    # 应用清单（appname, version, dep 等）
├── build-hermes-fpk.sh         # 构建脚本
├── cmd/
│   ├── main                    # 进程管理（start/stop/status/restart）
│   ├── install_callback        # ★ 核心安装逻辑（venv, pip, webui 下载）
│   ├── install_init            # 安装前检查
│   ├── uninstall_callback      # 卸载后清理
│   ├── uninstall_init          # 卸载前停止服务
│   ├── upgrade_callback        # 升级后恢复配置
│   ├── upgrade_init            # 升级前备份
│   ├── config_callback         # 配置变更后
│   └── config_init             # 配置变更前
├── config/
│   ├── privilege               # 运行权限
│   ├── resource                # 数据卷、端口配置
│   └── com.nousresearch.hermes.sc  # 防火墙规则
├── ui/
│   ├── config                  # 桌面入口配置
│   └── images/
│       ├── icon_64.png
│       └── icon_256.png
├── wizard/
│   ├── install                 # 安装向导
│   ├── config                  # 配置向导
│   ├── uninstall               # 卸载向导
│   └── upgrade                 # 升级向导
├── ICON.PNG                    # 64x64 图标
├── ICON_256.PNG                # 256x256 图标
└── README.md                   # 本文件
```

## 🎯 设计原则

- **纯原生**：不依赖 Docker，使用 fnOS 预装的 Python 3.12
- **在线安装**：安装时现场创建 venv，通过网络下载 hermes-agent 和 hermes-webui
- **多层网络兜底**：
  - **pip 镜像链**：阿里云 → 清华 TUNA → 中科大 USTC → 华为云 → 腾讯云 → 上海交大 → PyPI 官方
  - **GitHub 代理链**：ghproxy.com → coderkeeper → gitclone → ddlc → 直连
- **不捆绑源码**：fpk 仅含元数据和脚本（~30KB），业务代码安装时动态获取
- **自定义数据路径**：安装时可指定数据存放位置（如 `/vol3/hermes-data`）

## 🚀 构建

```bash
chmod +x build-hermes-fpk.sh
./build-hermes-fpk.sh              # 自动递增 patch 版本
./build-hermes-fpk.sh 0.2.0        # 指定新版本
./build-hermes-fpk.sh --noinc      # 保持当前版本
```

## 📦 安装

1. 从 [Releases](https://github.com/huxinga1/hermes-fnos/releases) 下载最新的 `.fpk` 文件
2. 在 fnOS → **应用中心** → **手动安装** → 选择 fpk 文件
3. 安装向导中：
   - 可自定义数据存储路径（可选）
   - 根据网络环境选择 pip 镜像源和 GitHub 代理
4. 安装完成后在应用中心启动

## 🌐 访问

| 方式 | 地址 |
|------|------|
| **内网** | `http://NAS_IP:8787` |
| **fnOS 穿透** | 应用中心提供的官方隧道链接 |
| **桌面入口** | 应用图标 → 新窗口打开 |

## 🔄 在线自升级

两个组件均支持在线升级：

- **WebUI**：通过 WebUI 管理界面的 `scripts/upgrade-webui.sh` 触发
- **Agent**：通过 `cmd/agent-upgrade` 脚本（支持多层 pip 镜像兜底）
- **fpk 本体**：下载新版 fpk 在应用中心手动升级

## 📚 上游项目

| 项目 | 用途 | 安装方式 |
|------|------|----------|
| [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) | AI 智能体核心（pip 包: `hermes-agent`） | `pip install hermes-agent` |
| [nesquena/hermes-webui](https://github.com/nesquena/hermes-webui) | Web 管理界面（Flask 应用） | `git clone` → `pip install -r requirements.txt` |

本仓库仅负责编排上述两个项目的 fnOS 集成部署。

## ⚙️ 技术栈

| 组件 | 版本/规格 |
|------|-----------|
| **Hermes Agent** | 最新 PyPI (install 时动态获取) |
| **Hermes WebUI** | 最新 GitHub release (install 时动态获取) |
| **fnOS Python** | 3.12（系统预装） |
| **fnpack** | v1.2.0（fnOS 打包工具） |

## 📜 许可

本仓库（fpk 打包层）为 fnOS 社区贡献的开源项目。上游项目遵循其各自的许可证。

- [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent) — Apache 2.0
- [nesquena/hermes-webui](https://github.com/nesquena/hermes-webui) — 请查阅其仓库
