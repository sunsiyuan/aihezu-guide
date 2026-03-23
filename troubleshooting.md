# 排查指南：Cursor / Claude / Clash Verge

这份文档只解决一件事：把问题拆开，按顺序验证，不要一开始就混着猜。

适用场景：

- Cursor 自带 Claude / Opus 在不同代理模式下表现不一致
- Claude Code 第三方中转能否使用不稳定
- Clash Verge 开 TUN 后部分网站异常，例如 Google 打不开，但其他网站能打开

## 使用原则

- 一次只改一个变量
- 每一步都记录结果
- 先测 `系统代理模式`
- 再测 `TUN 模式`
- `Cursor 自带 Claude` 和 `Claude Code 第三方中转` 分开测
- 浏览器问题和 Cursor 问题分开测

## 开始前

先准备好这几个命令会用到：

```bash
scutil --proxy
nslookup google.com
curl -I https://www.google.com
curl -I https://chatgpt.com
env | rg 'HTTP_PROXY|HTTPS_PROXY|ALL_PROXY|http_proxy|https_proxy|all_proxy|ANTHROPIC|OPENAI'
rg -n 'proxy|PROXY|ANTHROPIC|OPENAI|clash|cursor|code' ~/.zshrc ~/.zprofile ~/.bashrc ~/.bash_profile 2>/dev/null
```

如果你有像 `proxy-on` / `proxy-off` 这类 shell 函数，也一起记下来，但不要先把整份 `~/.zshrc` 发给别人。

## Step 1：记录当前环境

先不要改任何设置，直接记录当前状态。

### 1.1 记录当前代理模式

在 Clash Verge 里记录：

- `System Proxy` 是开还是关
- `TUN` 是开还是关
- 当前是 `Rule` / `Global` / `Direct`
- 当前节点名称

### 1.2 记录系统代理状态

```bash
scutil --proxy
```

记录这些是否启用：

- `HTTPEnable`
- `HTTPSEnable`
- `SOCKSEnable`
- `ProxyAutoConfigEnable`

### 1.3 记录当前 shell 环境

```bash
env | rg 'HTTP_PROXY|HTTPS_PROXY|ALL_PROXY|http_proxy|https_proxy|all_proxy|ANTHROPIC|OPENAI'
```

如果这里是空的，说明当前 shell 没有代理或模型相关环境变量。

### 1.4 记录 shell 配置里的相关片段

```bash
rg -n 'proxy|PROXY|ANTHROPIC|OPENAI|clash|cursor|code' ~/.zshrc ~/.zprofile ~/.bashrc ~/.bash_profile 2>/dev/null
```

这里只记录相关片段，不要贴整份配置文件。

### 1.5 记录应用启动方式

记录：

- Cursor 是从 Dock/Finder 打开的，还是从 terminal 启动的
- Claude Code 是直接在 terminal 里运行，还是从 VS Code / Cursor 集成里运行

## Step 2：做基线测试

先在“你当前的默认状态”下跑一遍最小测试。

### 2.1 浏览器测试

手工打开这几个地址：

- `https://www.google.com`
- `https://chatgpt.com`
- `https://claude.ai`

记录：

- 能打开 / 不能打开
- 是否很慢
- 是否报证书错误
- 是否跳地区限制

### 2.2 命令行测试

```bash
nslookup google.com
nslookup chatgpt.com
curl -I https://www.google.com
curl -I https://chatgpt.com
```

记录：

- `nslookup` 是否成功
- `curl` 是否成功
- 返回码 / 超时 / 连接失败

### 2.3 Cursor 自带 Claude 测试

记录：

- 是否能打开聊天
- 是否能选 Claude
- 是否能选 Opus
- 是否报错
- 报错原文是什么

### 2.4 Claude Code 第三方中转测试

在 terminal 中测试：

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
- 报错原文是什么

## Step 3：只开系统代理，不开 TUN

现在把模式固定成：

- `System Proxy = 开`
- `TUN = 关`

然后重复 Step 2 的全部测试。

重点记录：

- Google 能不能打开
- ChatGPT Web 能不能打开
- Cursor 自带 Claude 能不能用
- Cursor 能不能选 Opus
- Claude Code 第三方中转能不能用

## Step 4：只开 TUN，不开系统代理

现在把模式固定成：

- `System Proxy = 关`
- `TUN = 开`

再重复 Step 2 的全部测试。

重点记录：

- Cursor 是否从“不行”变成“可以”
- Opus 是否从“不可选”变成“可选”
- Google 是否从“可以”变成“打不开”

如果是这样，通常说明：

- TUN 解决了 Cursor 的关键流量问题
- 但 TUN 引入了 Google 的 DNS / 规则问题

## Step 5：如果 Google 在 TUN 下打不开，继续拆 DNS 和规则

只在“开 TUN”这个模式下做下面的测试。

### 5.1 再看 DNS

```bash
nslookup google.com
nslookup www.google.com
nslookup gstatic.com
nslookup chatgpt.com
```

判断：

- 如果 `nslookup` 就失败，优先怀疑 DNS
- 如果 `nslookup` 正常，但浏览器 / `curl` 还是不通，优先怀疑规则或路由

### 5.2 再看 curl

```bash
curl -I https://www.google.com
curl -I https://www.gstatic.com
curl -I https://chatgpt.com
```

判断：

- Google 系列都不通，但 ChatGPT 通，通常是 Google 域名族规则或 DNS 有问题

### 5.3 看 Clash Verge 日志 / 连接

在 Clash Verge 里搜索这些域名：

- `google.com`
- `www.google.com`
- `gstatic.com`
- `googleapis.com`
- `chatgpt.com`
- `cursor`

记录每条流量：

- 命中的规则
- 出站是 `DIRECT` 还是代理节点
- 是否失败

判断：

- 如果 Google 命中 `DIRECT`，而 ChatGPT 走代理，通常就是规则问题
- 如果 Google 也走代理，但还是失败，更像 DNS / 浏览器 Secure DNS / 节点兼容问题

## Step 6：如果 Cursor 只有 TUN 下才能用，再测启动方式

现在只测 Cursor，不测浏览器。

分别用两种方式启动 Cursor：

### 6.1 从 terminal 启动

```bash
cursor
```

### 6.2 从 Dock / Finder 启动

记录每种方式下：

- Cursor 自带 Claude 是否能用
- Claude / Opus 是否可选
- 报错是否不同

判断：

- terminal 启动能用，Dock 启动不行：更像应用继承环境不同
- 两种方式都只有 TUN 才行：更像系统代理没有完整接管 Cursor 关键流量

## Step 7：如果 Claude Code 第三方中转报 400 / 402，单独拆开看

不要和 Cursor 自带 Claude 混在一起。

### 7.1 如果报 402

优先检查：

- 是否日额度超了
- 是否周额度还在
- 当前模型是不是 `opus`

先试：

```text
/model sonnet
/status
```

如果 `sonnet` 正常、`opus` 不正常，优先怀疑模型权限或额度问题。

### 7.2 如果 terminal 正常，但 VS Code / Cursor 集成报 400

优先怀疑：

- IDE 集成请求格式和 terminal 不同
- 中转只部分兼容 Claude Code CLI，不完全兼容 IDE 集成
- VS Code / Cursor 没有读到同一套配置

这时记录：

- terminal 是否正常
- VS Code / Cursor 是否报 400
- 两边启动方式是否相同

## Step 8：汇总结论时，只回答这几个问题

排查结束后，不要一股脑贴现象，先归纳成这 6 个判断：

- 系统代理模式下，浏览器是否正常
- 系统代理模式下，Cursor 是否正常
- TUN 模式下，Cursor 是否恢复
- TUN 模式下，Google 是否异常
- Claude Code 第三方中转是否正常
- 400 / 402 是只在 IDE 集成出现，还是 terminal 也出现

## 结果记录模板

把下面这个模板直接复制下来填：

```md
# 排查记录

## 当前模式
- System Proxy：
- TUN：
- Clash 模式：Rule / Global / Direct
- 当前节点：

## Shell 环境
- env 里是否有 HTTP_PROXY / HTTPS_PROXY / ALL_PROXY：
- env 里是否有 ANTHROPIC / OPENAI：
- shell 配置里是否有 proxy-on / proxy-off / alias：

## 应用启动方式
- Cursor：Dock / terminal
- Claude Code：terminal / VS Code / Cursor

## 基线结果
- Google：
- ChatGPT Web：
- Claude Web：
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

## 报错
- Cursor 报错原文：
- Claude Code terminal 报错原文：
- VS Code / Cursor 集成报错原文：

## 总结
- 系统代理是否真的生效：
- TUN 是否解决了 Cursor：
- TUN 是否引入了 Google 问题：
- 更像 DNS / 规则 / 启动方式 / 中转兼容性 哪一类问题：
```

## 先给的通用判断

如果现象是这样：

- 系统代理模式下 Cursor 不稳定
- 开 TUN 后 Cursor 恢复
- 但 Google 打不开

那优先怀疑：

1. 系统代理没有完整接管 Cursor 的关键流量
2. TUN 模式下 Google 的 DNS / 规则有问题

如果现象是这样：

- Claude Code terminal 正常
- VS Code / Cursor 集成报 400

那优先怀疑：

1. IDE 集成请求格式与 terminal 不同
2. 第三方中转只部分兼容 CLI，不完全兼容 IDE 集成

如果现象是这样：

- `402`
- 同时 `usage` 显示日额度超了

那优先怀疑：

1. 日额度撞线
2. `opus` / 长会话 / 大上下文导致消耗过快
