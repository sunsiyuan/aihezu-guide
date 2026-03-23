# aihezu-guide

给已经在用官方 `Codex`，但考虑让 `Claude` 走第三方中转的人准备的一份简明说明。

这份仓库主要回答 4 个问题：

- `aihezu` 这个配置方式大概会带来什么风险
- 什么时候只改 `base_url` 就够了，什么时候才需要考虑 `hosts`
- 在 VS Code 里怎么更稳地使用，而不是把变量全局写进 `~/.zshrc`
- 如何快速切 `Opus` / `Sonnet`，以及怎么确认当前模型

## 适合谁看

- 已经在用官方 `Codex`
- 可能也在用官方 `Gemini`
- 只打算把第三方中转限制在 `Claude`
- 想先搞清楚风险和最小成本做法，再决定要不要用

## 快速开始

先看完整说明：

- [aihezu-risk-guide.md](./aihezu-risk-guide.md)

如果你只想先用最小风险方式测试：

```bash
npx aihezu@2.8.8 config claude
```

按这台机器的实测结果，先停在这一步即可；当前没有证据表明必须先改 `hosts`。

## VS Code

仓库里附带了一个启动脚本：

- [start-vscode-claude-proxy.sh](./start-vscode-claude-proxy.sh)

用法：

```bash
./start-vscode-claude-proxy.sh /path/to/project
```

它会从 `~/.claude/settings.json` 读取 Claude 中转配置，只注入到这一次 VS Code 进程，不污染全局 shell。

## 当前结论

- 只让它碰 `Claude`，不要碰 `Codex` / `Gemini`
- 有 `HTTPS` 才值得认真考虑
- 如果只有 `HTTP + IP`，原则上不要用
- 即使使用，也不要发送任何 credential 或敏感内容

## 说明

- 这份仓库不是对任何第三方中转的背书
- 重点是帮助使用者在实际操作前做风险判断和最小化配置
