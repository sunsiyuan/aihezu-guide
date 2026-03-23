# 快速排查：Cursor / Claude / Clash Verge

这是一份给亲友直接照着做的短版。一次只改一个变量，每一步都记录结果。

## 先记录当前状态

在 Clash Verge 里先记下：

- `System Proxy`：开 / 关
- `TUN`：开 / 关
- 模式：`Rule` / `Global` / `Direct`
- 当前节点

再执行：

```bash
scutil --proxy
env | rg 'HTTP_PROXY|HTTPS_PROXY|ALL_PROXY|http_proxy|https_proxy|all_proxy|ANTHROPIC|OPENAI'
rg -n 'proxy|PROXY|ANTHROPIC|OPENAI|clash|cursor|code' ~/.zshrc ~/.zprofile ~/.bashrc ~/.bash_profile 2>/dev/null
```

只保存结果，不要先分析。

## Step 1：先测默认状态

先不要改任何设置，直接测试：

### 浏览器

手工打开：

- `https://www.google.com`
- `https://chatgpt.com`
- `https://claude.ai`

记录：

- 能打开 / 不能打开
- 是否明显很慢

### 命令行

```bash
nslookup google.com
nslookup chatgpt.com
curl -I https://www.google.com
curl -I https://chatgpt.com
```

### Cursor 自带 Claude

记录：

- 能不能打开聊天
- 能不能选 Claude
- 能不能选 Opus
- 报错原文

### Claude Code 第三方中转

在 terminal 里执行：

```text
/status
/model sonnet
/status
```

如果要试 `opus`：

```text
/model opus
/status
```

记录：

- `sonnet` 是否可用
- `opus` 是否可用
- 是否报 400 / 402 / timeout

说明：

- 在当前案例里，`400` 和 `402` 都先按“额度相关问题”处理
- 所以这部分只记录，不作为当前网络排查主线

## Step 2：只开系统代理，不开 TUN

把模式固定成：

- `System Proxy = 开`
- `TUN = 关`

然后重复 Step 1 的全部测试。

重点看：

- Google 是否正常
- Cursor 自带 Claude 是否正常
- Cursor 是否能选 Opus
- Claude Code 第三方中转是否正常

## Step 3：只开 TUN，不开系统代理

把模式固定成：

- `System Proxy = 关`
- `TUN = 开`

再重复 Step 1 的全部测试。

重点看：

- Cursor 是否从“不行”变成“可以”
- Opus 是否从“不可选”变成“可选”
- Google 是否从“可以”变成“打不开”

如果是这样，通常说明：

- TUN 解决了 Cursor 的关键流量问题
- 但 TUN 引入了 Google 的 DNS / 规则问题

## Step 4：如果 Google 在 TUN 下打不开，再测 DNS 和规则

只在“开 TUN”的情况下执行：

```bash
nslookup google.com
nslookup www.google.com
nslookup gstatic.com
curl -I https://www.google.com
curl -I https://www.gstatic.com
curl -I https://chatgpt.com
```

然后在 Clash Verge 的日志 / 连接里查：

- `google.com`
- `gstatic.com`
- `googleapis.com`
- `chatgpt.com`
- `cursor`

记录：

- 命中的规则
- 出站是 `DIRECT` 还是代理节点
- 是否失败

快速判断：

- `nslookup` 就失败：优先怀疑 DNS
- Google 命中 `DIRECT`：优先怀疑规则
- Google 也走代理但还是失败：优先怀疑 DNS / 浏览器 Secure DNS / 节点兼容问题

## Step 5：如果 Cursor 只有 TUN 下才能用，再测启动方式

分别这样启动 Cursor：

```bash
cursor
```

和直接从 Dock / Finder 点开。

记录两种方式下：

- Cursor 自带 Claude 是否能用
- Opus 是否可选
- 报错是否不同

快速判断：

- terminal 启动能用，Dock 不行：更像继承环境不同
- 两种方式都只有 TUN 才行：更像系统代理没完整接管 Cursor 关键流量

## Step 6：当前案例里，400 / 402 不再作为主排查线

在当前案例里：

- `402` 已确认是额度问题
- `400` 也先按同一类问题处理

所以现在主排查只看两件事：

1. 为什么 Cursor 只有 TUN 下才正常
2. 为什么 TUN 下 Google 打不开

## 结果记录模板

直接复制下面这个模板填写：

```md
# 排查记录

## 当前模式
- System Proxy：
- TUN：
- Clash 模式：
- 当前节点：

## Shell 环境
- env 里是否有代理变量：
- env 里是否有 ANTHROPIC / OPENAI：
- shell 配置里是否有 proxy-on / proxy-off / alias：

## 默认状态
- Google：
- ChatGPT Web：
- Cursor 自带 Claude：
- Cursor Opus：
- Claude Code 第三方中转：

## 只开系统代理
- Google：
- ChatGPT Web：
- Cursor 自带 Claude：
- Cursor Opus：
- Claude Code 第三方中转：

## 只开 TUN
- Google：
- ChatGPT Web：
- Cursor 自带 Claude：
- Cursor Opus：
- Claude Code 第三方中转：

## DNS / curl
- nslookup google.com：
- nslookup chatgpt.com：
- curl -I https://www.google.com：
- curl -I https://chatgpt.com：

## Clash 日志
- google.com 命中规则：
- gstatic.com 命中规则：
- googleapis.com 命中规则：
- chatgpt.com 命中规则：
- cursor 相关流量命中规则：

## 报错原文
- Cursor：
- Claude Code terminal：
- VS Code / Cursor 集成：

## 结论
- 系统代理是否真的生效：
- TUN 是否解决了 Cursor：
- TUN 是否引入了 Google 问题：
- 更像 DNS / 规则 / 启动方式 / 中转兼容性 哪一类问题：
```
