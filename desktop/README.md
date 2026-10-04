# 澜图 OS 工作台

React + Vite 交互界面。项目总览见 [根目录 README](../README.md)。

```bash
npm ci
npm run dev -- --host 127.0.0.1
npm run build
npm run test:sites
```

浏览器中运行演示交互；Linux 原生壳通过 QWebChannel 注入受限的系统控制接口。文件和 AI 内容始终是示例，尚未接入真实模型。

`public/lantu-os-logo.png` 是用户选定的 A2 原图。`dist/client/` 为静态产物。保留的 `worker/` 与 `.openai/hosting.json` 是可选的网页托管适配，并非构建 Linux ISO 的运行依赖。
