# aihezu 使用前风险判断

## 结论

- 只让它碰 Claude，不要碰 Codex / Gemini。
- 有 HTTPS 才值得认真考虑；只有 HTTP + 裸 IP，原则上不要用。
- 只改 `base_url`（`config claude`）就够用，当前没有证据表明必须先改 hosts。
- 即使使用，也不要发送任何 credential 或敏感内容。
- 接受的前提：你发给 Claude 的内容、Claude 读到的文件，默认可能被第三方看到。

## 一票否决条件

满足以下任意一条，停止使用：

- 对方只提供 HTTP，不提供 HTTPS
- 要求你提交自己的官方 OpenAI / Anthropic / Google API key
- 要求你在敏感仓库、生产项目或客户项目中长期使用
- 要求你直接执行 `sudo npx aihezu install`，但不给清晰的恢复方案

## 适用条件

可以考虑使用，当且仅当全部成立：

- 只配置 Claude，Codex 和 Gemini 继续走官方
- 明确接受第三方中转的可见性风险
- 只在低敏感、可暴露的项目里使用
- 已备份 `~/.claude` 和 `/etc/hosts`
- 对方能提供 HTTPS 域名，而不是 HTTP 裸 IP
- 固定版本运行（如 `npx aihezu@2.8.8 ...`）

不建议使用，若满足以下任意一条：

- 工作区里有 `.env`、SSH 私钥、云账号凭证、Cookie、JWT、数据库密码、`kubeconfig` 等
- 会处理客户代码、公司内部项目、生产环境信息、故障日志、数据库结构
- 不清楚它会改哪些本地配置
- 不能接受它修改 hosts 或清理 Claude 本地历史数据

## 它会改什么

### Claude（`config claude` / `install claude`）

- 改写 `~/.claude/settings.json`
- `install claude` 还会：
  - 清理 `~/.claude/` 下的 `history.jsonl`、`debug/`、`file-history/`、`session-env/`、`shell-snapshots/`、`statsig/`、`todos/`
  - 备份并修改系统 hosts

### Codex（`install codex`）

- 改写 `~/.codex/config.toml` 和 `~/.codex/auth.json`
- 不改 hosts，不清缓存

### Gemini（`install gemini`）

- 改写 `~/.gemini/.env`，某些情况下写入 `~/.gemini/settings.json`
- 清理 `~/.gemini/cache/` 和 `~/.gemini/logs/`

---

## 背景说明

### 中转的本质不是"改 hosts"

hosts 只是某些客户端场景下，为了拦截官方域名、配合代理而加的辅助机制。真正要警惕的是"后续流量经过第三方"——只改 `base_url` 就已经把主请求直接发给了第三方，和 hosts 无关。

### 为什么 HTTP + 裸 IP 风险更高

- HTTP 不加密，网络路径上的节点理论上都能看到内容
- 无法验证你连接的是不是目标服务端
- 中间人劫持、流量篡改的风险更高
- 这类地址不适合发送任何 credential，也不适合处理敏感代码或敏感文本

### 为什么不要让它碰 Codex 或 Gemini

如果你的 Codex / Gemini 走的是官方直连，就没有必要为了 Claude 的中转去改写它们的配置。把第三方影响范围限制在 Claude，可以把风险控制在单一工具内。

## 执行前 Checklist

确认全部勾选后，再执行任何命令：

- [ ] 我只打算配置 Claude，不会让这个工具修改 Codex 或 Gemini
- [ ] 已备份 `~/.claude`（命令见 [setup-guide.md](./setup-guide.md#备份)）
- [ ] 已备份 `/etc/hosts`
- [ ] 当前工作区里没有 `.env`、私钥、客户数据、生产配置
- [ ] 对方提供的是 HTTPS 地址，不是 HTTP 裸 IP
- [ ] 我会固定版本使用（如 `npx aihezu@2.8.8 ...`）
- [ ] 我知道改完后如何恢复（见 [setup-guide.md](./setup-guide.md#回滚)）
- [ ] 我不会在这个通道里发送任何 credential
- [ ] 我不会在敏感项目中使用这个中转
