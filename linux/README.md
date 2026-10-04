# Linux 集成

详见 [构建说明](../docs/BUILD.md) 与 [验证状态](../docs/STATUS.md)。

原生工作台：`native/lantu-desktop.py`，安装后 `/usr/bin/lantu-desktop`。
静态资源：`/usr/share/lantu-desktop/web/`；本地 URL 为 `lantu://desktop/index.html`。

桥接仅开放固定的音量、静音、状态、设置和浏览器接口。网页无法提交任意 shell 命令；原生壳不加载外部网页，外部 HTTP / HTTPS URL 交给系统浏览器处理。
