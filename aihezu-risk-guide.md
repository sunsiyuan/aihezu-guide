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

## Quick Start

### 先完成最小配置

```bash
npx aihezu@2.8.8 config claude
```

确认 `~/.claude/settings.json` 已写入你要用的 `ANTHROPIC_BASE_URL` 和 `ANTHROPIC_AUTH_TOKEN`。

### 日常启动 Claude Code

```bash
claude
```

然后先看当前状态：

```text
/status
```

### 快速切到 Sonnet

在 Claude Code 里直接输入：

```text
/model sonnet
```

如果你想在启动时就指定：

```bash
claude --model sonnet
```

### 快速切到 Opus

在 Claude Code 里直接输入：

```text
/model opus
```

如果你想在启动时就指定：

```bash
claude --model opus
```

### 如果你想固定默认模型

不想每次手动切，可以只给这一个 Claude 启动链路设置：

```bash
ANTHROPIC_MODEL=sonnet claude
```

或：

```bash
ANTHROPIC_MODEL=opus claude
```

更长期一点，也可以在 Claude Code 的设置里配置 `model` 字段，或者用 shell alias 包一层，但不建议为了这个把第三方中转相关变量做成全局默认。

### 和这个中转场景相关的注意点

- 按 Anthropic 官方文档，Claude Code 支持 `/model <alias>`、`claude --model <alias>` 和 `ANTHROPIC_MODEL=<alias|name>` 这几种方式。
- 常用 alias 包括 `sonnet`、`opus`、`haiku`。
- 但在你的场景里，最终能不能切成功，还取决于这个第三方中转到底支持哪些模型。
- 所以最稳的验证方法是：
- 先 `/status`
- 再 `/model sonnet` 或 `/model opus`
- 发一个低敏感测试请求
- 看是否正常返回
- 如果 `opus` 切不过去，不一定是 Claude Code 本身的问题，也可能是中转没有开通或没有映射对应模型。

### 如果你想从这个 repo 里直接启动 VS Code

这个 repo 里附带了一个脚本：

[`start-vscode-claude-proxy.sh`](/Users/sun/Documents/aihezu-guide/start-vscode-claude-proxy.sh)

它会从 `~/.claude/settings.json` 读取当前的 `ANTHROPIC_BASE_URL`、`ANTHROPIC_AUTH_TOKEN` 和可选的 `model`，然后只把这些变量注入到这一次 VS Code 进程里。

用法：

```bash
./start-vscode-claude-proxy.sh /path/to/project
```

## 如何快速确认当前是不是你想要的 Claude 模型

### 最推荐的方法

不要先靠 prompt 猜，先直接看 Claude Code 自己的状态。

在 Claude Code 里执行：

```text
/status
```

如果你想切到 `opus`：

```text
/model opus
```

如果你想切到 `sonnet`：

```text
/model sonnet
```

切完后，再执行一次：

```text
/status
```

这是当前最直接、最低成本的验证方式。

### 可以辅助使用的测试 prompt

如果你只是想做一个很轻量的交叉检查，可以发：

```text
只回复两行：
1. 你当前声称的模型系列
2. 你当前声称的模型名称
不要解释，不要加别的内容。
```

但这个只能当参考，不能当证明。

### 为什么 prompt 只能算弱验证

- 第三方中转理论上可以把别的模型包装成 Claude 风格接口
- 模型回答“我是谁”本身也可能不可靠
- 所以“模型自报家门”不能证明后端一定是真正的 `Opus` 或 `Sonnet`

### 实用判断顺序

建议按这个顺序判断：

1. `/status`
2. `/model opus` 或 `/model sonnet`
3. 再 `/status`
4. 发一个低敏感测试请求
5. 如果中转服务端有面板或日志，再对照一次

### 现实里能确认到什么程度

如果这几步都正常，只能说明：

- 你当前在用的是 Claude Code 客户端
- 客户端当前配置声称在请求对应的 Claude 模型
- 中转至少接受了 Anthropic 风格的请求

但这仍然不能 100% 证明第三方后端一定就是原生官方 `Opus` / `Sonnet`。最终可信度还是取决于你对这个中转的信任程度。

## VS Code 集成建议

### 如果是我，我会怎么配

- 先不往 `~/.zshrc` 里写 `ANTHROPIC_BASE_URL` 和 `ANTHROPIC_AUTH_TOKEN`
- 先保留 `~/.claude/settings.json` 里的配置，直接试 VS Code 扩展能不能读取
- 只有在扩展确实读不到时，才考虑用“启动这一次 VS Code 进程时临时带环境变量”的方式
- 在这个 repo 里，优先可以直接用 [`start-vscode-claude-proxy.sh`](/Users/sun/Documents/aihezu-guide/start-vscode-claude-proxy.sh)
- 不建议把第三方中转地址和 key 做成长期全局环境变量

### 推荐顺序

1. 安装 VS Code 的 `Claude Code` 扩展
2. 保持当前 `~/.claude/settings.json` 配置不变
3. 直接在 VS Code 里执行 `Claude: Start Chat`
4. 如果能正常工作，就停在这里
5. 如果扩展读不到配置，先用这个 repo 里的启动脚本
6. 如果你不想用脚本，再用临时启动命令

### 推荐脚本方式

```bash
./start-vscode-claude-proxy.sh /path/to/project
```

这个脚本会：

- 从 `~/.claude/settings.json` 读取当前配置
- 自动带上 `ANTHROPIC_BASE_URL`
- 自动带上 `ANTHROPIC_AUTH_TOKEN`
- 如果设置文件里已经有 `model`，也会一并带上
- 只影响这一次启动出来的 VS Code 进程

### 临时启动当前这次 VS Code 的方式

```bash
ANTHROPIC_BASE_URL="http://122.191.109.46/api" \
ANTHROPIC_AUTH_TOKEN="你的key" \
code /path/to/project
```

这条命令的特点是：

- 只影响这一次启动出来的 VS Code 进程
- 不会把变量长期写进 `~/.zshrc`
- 不会默认污染你之后所有 shell 和其他 Anthropic 相关工具

### 不推荐的方式

不建议这样做：

```bash
echo 'export ANTHROPIC_BASE_URL="..."' >> ~/.zshrc
echo 'export ANTHROPIC_AUTH_TOKEN="..."' >> ~/.zshrc
source ~/.zshrc
```

原因是：

- 这是全局生效，不只是给 VS Code 用
- key 会长期明文留在 shell 配置文件里
- 以后其他工具也可能误用这个第三方链路
- 排查问题时更难判断到底是谁继承了这些环境变量

### 能不能写进 VS Code 的“默认启动配置”

如果你说的是 `.vscode/launch.json`，那不合适。

- `launch.json` 主要是给调试目标进程用的
- 它不是“启动 VS Code 自己”的默认配置
- Claude 扩展本身是否能拿到这些变量，关键在于 VS Code 应用进程启动时继承了什么环境

如果你想做成“默认但不全局污染”的方案，更稳的是下面两种：

- 写一个本地启动脚本，例如 `start-vscode-claude-proxy.sh`
- 做一个 shell alias，例如 `code-claude-proxy`

例如：

```bash
alias code-claude-proxy='ANTHROPIC_BASE_URL="http://122.191.109.46/api" ANTHROPIC_AUTH_TOKEN="你的key" code'
```

然后用：

```bash
code-claude-proxy /path/to/project
```

这比直接写进 `~/.zshrc` 的全局 `export` 更可控。

### 这一节的实际结论

- 先试 `~/.claude/settings.json`
- 不行再用“临时启动这次 VS Code”的方式
- 不建议把第三方中转变量做成系统长期默认环境
- 而且当前目标仍然是 `HTTP`，所以即便 VS Code 集成跑通，也仍然只建议在低敏感项目里使用

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
