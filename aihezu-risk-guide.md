# `aihezu` 使用前判断与使用注意事项

## 给亲友看的简版

- 如果你是这样的亲友：你已经在用官方 `Codex`，而且想继续保持官方使用，不想被这个工具改掉，那这份说明就是按这个前提写的。
- 如果你不是这个场景，也可以直接类比来看：哪个工具你已经在官方使用，就尽量不要让第三方脚本去改它；如果一定要改，只改你明确想切到第三方中转的那一个。
- `aihezu` 不是普通插件，它会改本机配置；在 `Claude` 场景下，还可能改系统 `hosts`。
- 如果你已经在用官方 `Codex`，就不要让它去改 `Codex`；如果你也在用官方 `Gemini`，同样不要让它去改 `Gemini`。
- 只要 `Claude` 走第三方中转，就默认认为：你发过去的内容、Claude 读到的文件、终端输出里的信息，都可能被第三方看到。
- 按这台机器的实测结果，`只改 base_url` 就已经会把主请求直接发到 `122.191.109.46:80`，目前没有证据表明必须改 `hosts`。
- 如果对方给的地址是 `http://122.191.109.46/api` 这种 `HTTP` 裸 IP，我不建议使用。
- 如果一定要用，只建议在没有密钥、没有客户数据、没有隐私内容的项目里用。

## 一句话结论

- 只让它碰 `Claude`，不要碰 `Codex` / `Gemini`。
- 有 `HTTPS` 才值得考虑。
- 如果只有 `HTTP + IP`，原则上不要用。
- 按当前实测，先停在“只改 `base_url`”这一步，不需要先改 `hosts`。
- 即使使用，也不要发送任何 credential 或敏感内容。

## 最小风险做法

先只改 `Claude` 配置，不清缓存，不改 `hosts`：

```bash
npx aihezu@2.8.8 config claude
```

只有在你确认确实需要它代改 `hosts` 时，才考虑：

```bash
sudo npx aihezu@2.8.8 install claude
```

按当前这台机器的实测结果，建议先停在第一步，因为主请求已经能直接到 `122.191.109.46:80`。

不要使用这些命令：

```bash
npx aihezu install
sudo npx aihezu install
npx aihezu install codex
npx aihezu install gemini
sudo npx aihezu install codex
sudo npx aihezu install gemini
```

## 执行前 Checklist

- [ ] 我只打算配置 `Claude`
- [ ] 我的 `Codex` 不会让这个工具修改
- [ ] 我的 `Gemini` 不会让这个工具修改
- [ ] 我已经备份 `~/.claude`
- [ ] 我已经备份 `/etc/hosts`
- [ ] 当前工作区里没有 `.env`、私钥、客户数据、生产配置
- [ ] 对方提供的是 `HTTPS` 地址，不是 `HTTP` 裸 IP
- [ ] 我会固定版本使用，例如 `npx aihezu@2.8.8 ...`
- [ ] 我知道改完后如何恢复 `~/.claude/settings.json` 和 `/etc/hosts`
- [ ] 我不会在这个通道里发送任何 credential
- [ ] 我不会在敏感项目中使用这个中转

### 手工备份命令

先备份 `~/.claude`：

```bash
cp -R ~/.claude ~/.claude.backup-$(date +%Y%m%d-%H%M%S)
```

再备份 `/etc/hosts`：

```bash
sudo cp /etc/hosts /etc/hosts.backup-$(date +%Y%m%d-%H%M%S)
```

如果想顺手确认备份是否成功：

```bash
ls -ld ~/.claude.backup-* /etc/hosts.backup-* 2>/dev/null
```

## 什么时候可以考虑用

- 你只打算给 `Claude` 接第三方中转。
- 你的 `Codex` 和 `Gemini` 会继续走官方。
- 你接受第三方中转能看到你发给 Claude 的内容。
- 你只会在低敏感、可暴露的项目里使用。
- 你已经备份好 `~/.claude` 和 `/etc/hosts`。
- 对方能提供 `HTTPS` 域名，而不是 `HTTP` 裸 IP。
- 你愿意固定版本运行，而不是每次执行最新版本。

## 什么时候不建议用

- 你会在这个通道里处理客户代码、公司内部项目、生产环境信息、故障日志、数据库结构或业务数据。
- 你的工作区里有 `.env`、SSH 私钥、云账号凭证、Cookie、JWT、数据库密码、`kubeconfig` 等敏感信息。
- 你不清楚它会改哪些本地配置。
- 你不能接受它修改 `hosts` 或清理 Claude 本地历史数据。
- 对方给你的地址是 `http://122.191.109.46/api` 这类明文地址。

## 一票否决条件

- 只提供 `HTTP`，不提供 `HTTPS`
- 要求你提交自己的官方 OpenAI / Anthropic / Google API key
- 要求你在敏感仓库、生产项目或客户项目中长期使用
- 要求你直接执行 `sudo npx aihezu install`，但不给清晰的恢复方案

## 它到底会做什么

- 下载并执行 npm 上当前版本的 `aihezu` CLI。
- 修改 `Claude`、`Codex`、`Gemini` 的用户级配置文件。
- 在 `Claude` 场景下，可能修改系统 `hosts`。
- 在部分场景下清理本地缓存和历史数据，并保留备份。

## 本地会改哪些东西

### `Claude`

- 改写 `~/.claude/settings.json`
- 清理 `~/.claude/` 下这些内容：
  - `history.jsonl`
  - `debug/`
  - `file-history/`
  - `session-env/`
  - `shell-snapshots/`
  - `statsig/`
  - `todos/`
- 备份并修改系统 `hosts`

### `Codex`

- 改写 `~/.codex/config.toml`
- 改写 `~/.codex/auth.json`
- 按当前版本代码，`install codex` 不会改 `hosts`
- 按当前版本代码，`install codex` 不会清缓存

### `Gemini`

- 改写 `~/.gemini/.env`
- 某些情况下会写入 `~/.gemini/settings.json`
- 清理 `~/.gemini/cache/`
- 清理 `~/.gemini/logs/`

## 为什么 `hosts` 不是重点，重点是“中转”

- 第三方中转的本质不是“改 `hosts`”。
- 中转的本质是：你的请求先发给第三方，再由第三方代转发。
- `hosts` 只是某些客户端场景下，为了拦截官方域名、阻断直连或配合代理而加的辅助机制。
- 对你来说，真正要警惕的是“后续流量经过第三方”，不是 `hosts` 这件事本身。

## 为什么 `HTTP + IP` 风险更高

- `HTTP` 不是加密传输。
- 你发出的内容理论上可能被网络路径上的其他节点看到。
- 你很难确认自己连接的是不是目标服务端。
- 中间人劫持、流量篡改、内容窃听的风险都更高。
- 这类地址不适合发送任何 credential，也不适合处理敏感代码或敏感文本。

## 使用时必须注意的事项

- 把通过该中转使用的 `Claude` 视为非官方、非私密链路。
- 不要在对话里粘贴任何正式环境凭证。
- 不要发送 API key、Cookie、JWT、数据库密码、云账号密钥、SSH 私钥。
- 不要让 Claude 读取包含敏感配置的文件。
- 不要在工作区里保留真实 `.env` 或其他密钥文件。
- 不要在带客户数据、内部代码、生产日志的目录中使用。
- 不要让它分析包含个人隐私或商业机密的文档。
- 如果必须用，优先只在公开代码、测试项目、演示项目里使用。
- 一旦误发敏感信息，立即轮换相关凭证。

## 为什么不要让它碰 `Codex` 或 `Gemini`

- 你的 `Codex` 现在是官方直连，没有必要为了 Claude 的中转去改写 `~/.codex/config.toml` 和 `~/.codex/auth.json`。
- 如果你也在用官方 `Gemini`，同理没有必要改写 `~/.gemini/.env`。
- 把第三方影响范围限制在 `Claude`，可以把风险控制在单一工具内，避免污染你其他官方客户端配置。

## 运行后要检查什么

- 检查 `~/.claude/settings.json` 中写入的 `ANTHROPIC_BASE_URL`
- 检查 `/etc/hosts` 是否只新增了预期条目
- 确认 `Codex` 和 `Gemini` 配置未被改动
- 确认没有清理掉你仍然需要的本地历史或缓存
- 在正式使用前，先用一个低敏感项目验证行为

## 本次实测记录

### 实测结论

- 已执行：

```bash
npx aihezu@2.8.8 config claude
```

- 本次只改了 `Claude` 配置，没有改 `hosts`
- 已创建 `~/.claude/settings.json`
- 抓包时观察到主请求直接发往 `122.191.109.46:80`
- 本次抓包里没有看到去 `api.anthropic.com` 或 `statsig.anthropic.com` 的连接
- 按这次结果看，`只改 base_url` 已经可以完成基本连通性验证，当前没有证据表明必须修改 `hosts`
- 但目标仍然是 `HTTP` 的 `80` 端口，所以链路仍应视为明文高风险链路

### 抓包结论怎么理解

- 这次验证说明：当前至少主请求已经在走第三方地址，而不是官方 Anthropic 域名
- 因此，现阶段不应默认认为“必须改 `hosts` 才能用”
- 只有在后续复测中明确发现仍然访问 `api.anthropic.com`、或功能上确实因为官方域名访问导致失败时，才需要重新评估 `hosts`

### 本机网络环境说明

- 本机配置了 `Clash Verge`
- 当前代理走日本节点
- 本地代理端口是 `7897`

### `Clash Verge` 这件事会不会影响判断

- 会影响的部分：
  - 出口 IP 可能不是你本机真实公网 IP
  - 服务端看到的来源地区和网络环境可能是日本节点
  - 某些连通性、风控、地区限制问题可能与代理节点有关
- 不会改变的核心结论：
  - 这次测试里，主请求目标确实是 `122.191.109.46:80`
  - 这次测试里，没有看到请求去官方 Anthropic 域名
  - 所以“当前不需要为了基本连通性先改 `hosts`”这个判断仍然成立

### 额外风险提示

- `Clash Verge` 不会把 `HTTP` 目标自动变成 `HTTPS`
- 即使你本机走了代理，目标地址本身仍然是 `HTTP`
- 这意味着这条链路依然不适合发送任何 credential、敏感代码、客户数据或生产信息
- 如果继续测试，仍然只建议在低敏感项目中进行

## 回滚思路

- 恢复 `~/.claude/settings.json` 备份
- 恢复 `/etc/hosts` 备份
- 删除 `aihezu` 添加的 `hosts` 条目
- 验证 `Claude` 是否恢复到你原本的连接方式

## 最终建议

### 对于已经在用官方 `Codex` 或官方 `Gemini`，但没有用官方 `Claude` 的情况

- 可以只把第三方中转限制在 `Claude` 上，前提是你明确接受第三方中转的可见性风险。
- 不要让它修改 `Codex` 或 `Gemini` 的配置。
- 始终显式指定 `claude`，不要使用不带服务名的交互式命令。
- 优先使用 `config claude`，只有在确实需要时才考虑 `install claude`。
- 如果服务地址仍然是 `http://122.191.109.46/api` 这类 `HTTP` 地址，则不建议使用，即使只用于 `Claude` 也是高风险。
- 如果只能提供 `HTTP` 裸 IP，我的建议是放弃使用，或者仅在完全隔离、无任何敏感内容的临时环境中测试。
