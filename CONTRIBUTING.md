# 参与澜图 OS

欢迎修复问题、改进中文体验、测试真实设备，或完善构建和安装流程。

1. 先阅读 README 的当前能力及限制；涉及大功能时先开 Issue 讨论。
2. 从 `main` 建分支，保持改动聚焦；不要提交 ISO、构建缓存、个人文件、密钥、设备密码或原始用户日志。
3. 网页变更执行 `cd desktop && npm ci && npm run build && npm run test:sites`。
4. 原生桥接变更在 Debian 上执行 `python3 linux/tests/test_bridge.py`。不得把任意 shell 命令、文件路径或远程网页直接暴露给 QWebChannel。
5. 镜像变更运行 `bash -n linux/*.sh scripts/*.sh` 并按 BUILD.md 构建；记录实际验证范围。
6. PR 写明问题、解决方式、验证结果及仍未覆盖的条件。提交的自有内容按 GPL-3.0-or-later 授权。

硬件报告请写明 CPU、GPU、网卡型号、启动方式、版本及重现步骤。删除序列号、MAC、个人账号和网络密码后再上传日志。
