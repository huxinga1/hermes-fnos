# Hermes AI Agent — fnOS Native Application (.fpk)

Hermes AI Agent 的 fnOS 原生应用包。安装后可直接通过 WebUI 页面调用 Agent，支持在线自升级。

## 项目结构

```
com.nousresearch.hermes/
├── manifest                    # 应用清单（appname, version, dep 等）
├── build-hermes-fpk.sh         # 构建脚本
├── cmd/
│   ├── main                    # 进程管理（start/stop/status/restart）
│   ├── install_init            # 安装前检查
│   ├── install_callback        # ★ 核心安装逻辑（venv, pip, webui 下载）
│   ├── uninstall_init          # 卸载前停止服务
│   ├── uninstall_callback      # 卸载后清理
│   ├── upgrade_init            # 升级前备份
│   ├── upgrade_callback        # 升级后恢复配置
│   ├── config_init             # 配置变更前
│   └── config_callback         # 配置变更后
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
│   ├── install                 # 安装向导（选镜像/代理/端口）
│   └── config                  # 配置向导
├── app.tgz                     # 运行辅助脚本（解压到安装目录）
├── ICON.PNG                    # 64x64 图标
└── ICON_256.PNG                # 256x256 图标
```

## 设计原则

- **纯原生**：不依赖 Docker，使用 fnOS 预装的 Python 3.12
- **在线安装**：安装时现场创建 venv，通过网络下载 hermes-agent 和 hermes-webui
- **多层网络兜底**：pip 镜像链（阿里云→清华→中科大→华为云→腾讯云→交大→官方）
                        GitHub 代理链（ghproxy→coderkeeper→gitclone→ddlc→直连）
- **不捆绑源码**：fpk 仅含元数据和脚本（~26KB），业务代码安装时动态获取

## 构建

```bash
chmod +x build-hermes-fpk.sh
./build-hermes-fpk.sh              # 使用当前版本
./build-hermes-fpk.sh 0.2.0        # 指定新版本
```

## 安装

1. 将生成的 `com.nousresearch.hermes.fpk` 复制到 fnOS 设备
2. 在 fnOS 应用中心 → 手动安装 → 选择 fpk 文件
3. 安装向导中可根据网络环境选择 pip 镜像和 GitHub 代理
4. 安装完成后在应用中心启动

## 访问

启动后通过 `http://NAS_IP:8787` 访问 Hermes WebUI。

## 自升级

WebUI 附带升级脚本（`scripts/upgrade-webui.sh`），可通过 WebUI 管理界面触发在线升级。

## 技术栈

- **Hermes Agent**: v0.15.2 — [GitHub](https://github.com/NousResearch/hermes-agent)
- **Hermes WebUI**: v0.51.185 — [GitHub](https://github.com/nesquena/hermes-webui)
- **fnOS Python**: 3.12（预装）
- **打包工具**: fnpack v1.2.0
