# 实测记录：2025-03 初次配置

## 环境

- 本机配置了 Clash Verge，出口走日本节点，本地代理端口 7897
- 执行命令：`npx aihezu@2.8.8 config claude`

## 结果

- 只改了 `~/.claude/settings.json`，没有改 hosts
- 抓包观察到主请求直接发往 `122.191.109.46:80`
- 没有看到去 `api.anthropic.com` 或 `statsig.anthropic.com` 的连接

## 结论

只改 `base_url` 已经完成基本连通性，当前不需要先改 hosts。

目标地址是 HTTP 80 端口（明文），所以链路仍应视为高风险，不适合发送任何 credential 或敏感内容。

## Clash Verge 对本次判断的影响

| 方面 | 影响 |
|------|------|
| 出口 IP | 是日本节点，不是本机真实公网 IP |
| 连通性结论 | 不影响——主请求目标确实是 `122.191.109.46:80` |
| 是否改变 HTTP 风险 | 不改变——代理不会把 HTTP 目标自动升级为 HTTPS |
