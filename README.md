# aihezu-guide

给已经在用官方 Codex，但考虑让 Claude 走第三方中转的人准备的简明说明。

## 适合谁看

- 已经在用官方 Codex，可能也在用官方 Gemini
- 只打算把第三方中转限制在 Claude
- 想先搞清楚风险和最小成本做法，再决定要不要用

## 文档导航

| 文件 | 内容 |
|------|------|
| [risk-assessment.md](./risk-assessment.md) | 风险判断：结论、一票否决、适用条件、它会改什么、执行前 Checklist |
| [setup-guide.md](./setup-guide.md) | 操作指南：备份、安装、验证、模型切换、VS Code 集成、回滚 |
| [troubleshooting.md](./troubleshooting.md) | 排查指南：按步骤验证 Cursor / Claude / Clash Verge 的问题，附结果记录模板 |
| [troubleshooting-short.md](./troubleshooting-short.md) | 亲友短版：更短的 step-by-step 排查清单和记录模板 |
| [test-records/](./test-records/) | 实测记录（按时间归档） |

**推荐阅读顺序**：先看 `risk-assessment.md` 做出 go/no-go 判断，再按 `setup-guide.md` 操作；遇到问题时按 `troubleshooting.md` 一步一步排查。

## 核心原则

- 只让它碰 Claude，不要碰 Codex / Gemini
- 有 HTTPS 才值得认真考虑
- 如果只有 HTTP + 裸 IP，原则上不要用
- 即使使用，也不要发送任何 credential 或敏感内容

## VS Code

仓库附带了一个启动脚本，从 `~/.claude/settings.json` 读取 Claude 中转配置，只注入到这一次 VS Code 进程，不污染全局 shell：

```bash
./start-vscode-claude-proxy.sh /path/to/project
```

---

这份仓库不是对任何第三方中转的背书，重点是帮助在实际操作前做风险判断和最小化配置。
